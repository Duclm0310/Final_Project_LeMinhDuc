const { EnergySummary } = require("../models");
const { Op } = require("sequelize");
const moment = require("moment-timezone");
const { getSummaryFromRedis, setHouseHourlySummary, rebuildHouseCache, buildRoomDevices } = require("./redis.service");
const redisClient = require("../config/redisClient");



exports.getSummary = async (level, refId, period, limit) => {
  const summaries = [];
  const now = moment().tz("Asia/Ho_Chi_Minh");
  const periodValues = [];

  // Tạo danh sách các mốc thời gian cần lấy
  for (let i = 0; i < limit; i++) {
    let periodValue = "";

    if (period === "hourly") {
      periodValue = now.clone().subtract(i, "hours").format("YYYY-MM-DD HH:00:00");
    } else if (period === "daily") {
      periodValue = now.clone().subtract(i, "days").format("YYYY-MM-DD");
    } else if (period === "weekly") {
      periodValue = now.clone().subtract(i, "weeks").format("YYYY-[W]WW");
    } else if (period === "monthly") {
      periodValue = now.clone().subtract(i, "months").format("YYYY-MM");
    }

    periodValues.push(periodValue);
  }

  // Tạo các keys Redis tương ứng
  const redisKeys = periodValues.map(pv => `${level}:${refId}:${pv}`);

  // Đọc Redis tất cả keys cùng lúc
  const redisResults = await Promise.all(redisKeys.map(key => getSummaryFromRedis(key)));

  const missingPeriods = [];

  // Kiểm tra Redis trả về gì
  redisResults.forEach((item, idx) => {
    if (item) {
      summaries.push({ period_value: periodValues[idx], ...item, source: "redis" });
    } else {
      missingPeriods.push(periodValues[idx]);
    }
  });

  // Nếu Redis thiếu, thì fallback DB
  if (missingPeriods.length > 0) {
    const dbResults = await EnergySummary.findAll({
      where: {
        reference_id: refId,
        summary_level: level,
        period_type: period,
        period_value: { [Op.in]: missingPeriods }
      },
      raw: true
    });

    // Map DB results thành object để dễ lookup
    const dbMap = {};
    dbResults.forEach(item => {
      dbMap[item.period_value] = item;
    });

    // Đổ data từ DB vào kết quả
    missingPeriods.forEach(pv => {
      if (dbMap[pv]) {
        summaries.push({ period_value: pv, ...dbMap[pv], source: "db" });
      } else {
        summaries.push({ period_value: pv, total_energy: 0, average_power: 0, peak_energy: 0, downtime_minutes: 60, source: "none" });
      }
    });
  }

  return summaries.reverse(); // Sắp xếp theo thời gian tăng dần
};

/**
 * Hàm tính tiền điện dựa trên tổng sản lượng điện tiêu thụ
 */
exports.getElectricityCost = async (level, refId, period, start, end) => {
  const now = moment().tz("Asia/Ho_Chi_Minh");  // Khai báo biến 'now'
  const startDate = moment(start).tz("Asia/Ho_Chi_Minh").startOf("month");
  const endDate = moment(end).tz("Asia/Ho_Chi_Minh");

  let totalEnergy = 0;

  const monthKey = `${level}:${refId}:${startDate.format("YYYY-MM")}`;
  const monthCache = await getSummaryFromRedis(monthKey);
  if (monthCache) {
    totalEnergy = monthCache.total_energy;
  } else {
    const dailyKeys = [];
    let tmp = startDate.clone();
    while (tmp.isBefore(endDate, "day")) {
      dailyKeys.push(tmp.format("YYYY-MM-DD"));
      tmp.add(1, "day");
    }

    // Đọc dữ liệu daily từ Redis
    const redisDailyKeys = dailyKeys.map(day => `${level}:${refId}:${day}`);
    const redisDailyResults = await Promise.all(redisDailyKeys.map(key => getSummaryFromRedis(key)));

    const missingDaily = [];

    redisDailyResults.forEach((item, idx) => {
      if (item) {
        totalEnergy += item.total_energy;
      } else {
        missingDaily.push(dailyKeys[idx]);
      }
    });

    // Nếu thiếu daily thì lấy từ DB
    if (missingDaily.length > 0) {
      const dailyDB = await EnergySummary.findAll({
        where: {
          reference_id: refId,
          summary_level: level,
          period_type: "daily",
          period_value: { [Op.in]: missingDaily }
        },
        raw: true
      });

      dailyDB.forEach(item => {
        totalEnergy += item.total_energy;
      });
    }

    // Xử lý phần ngày hiện tại (đang chạy, chưa kết thúc)
    const today = now.format("YYYY-MM-DD");
    const currentHours = [];

    for (let h = 0; h <= now.hour(); h++) {
      const hourKey = `${today} ${String(h).padStart(2, "0")}:00:00`;
      currentHours.push(hourKey);
    }

    const redisHourKeys = currentHours.map(hour => `${level}:${refId}:${hour}`);
    const redisHourResults = await Promise.all(redisHourKeys.map(key => getSummaryFromRedis(key)));

    const missingHours = [];

    redisHourResults.forEach((item, idx) => {
      if (item) {
        totalEnergy += item.total_energy;
      } else {
        missingHours.push(currentHours[idx]);
      }
    });

    // Nếu giờ nào còn thiếu, query DB
    if (missingHours.length > 0) {
      const hourlyDB = await EnergySummary.findAll({
        where: {
          reference_id: refId,
          summary_level: level,
          period_type: "hourly",
          period_value: { [Op.in]: missingHours }
        },
        raw: true
      });

      hourlyDB.forEach(item => {
        totalEnergy += item.total_energy;
      });
    }
  }

  const cost = calculateElectricityCost(totalEnergy);

  return { totalEnergy, cost };
};


/**
 * Hàm phụ: tính tiền điện theo sản lượng
 */
function calculateElectricityCost(totalEnergy) {
  const pricingTiers = [
    { limit: 50, price: 1893 },
    { limit: 50, price: 1956 },
    { limit: 100, price: 2271 },
    { limit: 100, price: 2860 },
    { limit: 100, price: 3197 },
    { limit: Infinity, price: 3302 },
  ];

  let cost = 0;
  let remaining = totalEnergy;

  for (const tier of pricingTiers) {
    const energy = Math.min(remaining, tier.limit);
    cost += energy * tier.price;
    remaining -= energy;
    if (remaining <= 0) break;
  }

  return cost;
}


// Lấy dữ liệu tổng hợp cho house, tính toán tổng năng lượng từ daily và hourly nếu không có dữ liệu cho monthly
exports.getHouseSummaryData = async (houseId, period, start, end) => {
  let totalEnergy = 0;
  let contributors = [];


  const summaryData = await exports.getSummary("house", houseId, period, 1);
  // console.log(`Fetched summary data from getSummary: ${JSON.stringify(summaryData)}`);

  if (summaryData.length > 0 && summaryData[0].total_energy > 0) {
    totalEnergy = summaryData[0].total_energy;
    // console.log(`Using cached summary data, totalEnergy: ${totalEnergy}`);
  } else {
    const data = await calculateHouseTemporaryEnergyConsumption(houseId, period);
    totalEnergy = data.totalEnergy;
    contributors = data.contributors;
    // console.log(`No cached summary found, calculating temporary energy consumption. TotalEnergy: ${totalEnergy}, Contributors: ${JSON.stringify(contributors)}`);
  }

  return { totalEnergy, contributors };
};

async function calculateHouseTemporaryEnergyConsumption(houseId, period) {
  const now = moment().tz("Asia/Ho_Chi_Minh");
  let totalEnergy = 0;
  let contributors = [];

  console.log(`Calculating temporary energy consumption for house: ${houseId}`);

  const startOfMonth = now.clone().startOf("month");
  const yesterday = now.clone().subtract(1, "day").endOf("day");

  // Lấy dữ liệu daily từ database
  const dailyResults = await EnergySummary.findAll({
    where: {
      reference_id: houseId,
      summary_level: "house",
      period_type: "daily",
      period_value: {
        [Op.between]: [startOfMonth.format("YYYY-MM-DD"), yesterday.format("YYYY-MM-DD")],
      },
    },
  });
  totalEnergy += dailyResults.reduce((sum, row) => sum + row.total_energy, 0);
  console.log(`Fetched daily energy data: Total Energy from daily results: ${totalEnergy}`);

  // Tính từ hourly (cho đến giờ hiện tại trong ngày hôm nay)
  for (let hour = 0; hour <= now.hour(); hour++) {
    const hourKey = `${now.format("YYYY-MM-DD")} ${String(hour).padStart(2, '0')}:00:00`;
    console.log(`Checking for hourly energy data at hour: ${hour}, hourKey: ${hourKey}`);

    const redisHour = await getSummaryFromRedis(`house:${houseId}:${hourKey}`);
    if (redisHour) {
      totalEnergy += redisHour.total_energy;
      console.log(`Found real-time data in Redis for hour ${hourKey}: ${redisHour.total_energy}`);
    } else {
      const dbHour = await EnergySummary.findOne({
        where: {
          reference_id: houseId,
          summary_level: "house",
          period_type: "hourly",
          period_value: hourKey,
        },
      });
      if (dbHour) {
        totalEnergy += dbHour.total_energy;
        console.log(`Found hourly data in DB for hour ${hourKey}: ${dbHour.total_energy}`);
      }
    }
  }

  
  let roomIds = await redisClient.smembers(`house:${houseId}:rooms`);
  if (!roomIds || roomIds.length === 0) {
    console.log(`❌ Data not found in Redis for house ${houseId}, rebuilding rooms...`);
    await rebuildHouseCache(houseId);
    roomIds = await redisClient.smembers(`house:${houseId}:rooms`);
  }



  console.log(`Room IDs in house ${houseId}: ${roomIds}`);
  
  for (const roomId of roomIds) {
    let roomEnergy = 0;
    const dailyResults = await EnergySummary.findAll({
      where: {
        reference_id: roomId,
        summary_level: "room",
        period_type: "daily",
        period_value: {
          [Op.between]: [startOfMonth.format("YYYY-MM-DD"), yesterday.format("YYYY-MM-DD")],
        },
      },
    });
    roomEnergy += dailyResults.reduce((sum, row) => sum + (row.total_energy || 0), 0);
    console.log(`Room ${roomId}: Total energy from daily data: ${roomEnergy}`);
  
    // 2. Tính tổng năng lượng của phòng theo giờ (hourly) từ Redis và Database
    for (let hour = 0; hour <= now.hour(); hour++) {
      const hourKey = `${now.format("YYYY-MM-DD")} ${String(hour).padStart(2, '0')}:00:00`;
      console.log(`Checking for hourly energy data for room ${roomId} at hour: ${hour}, hourKey: ${hourKey}`);
  
      // Kiểm tra Redis trước
      const redisRoomHour = await getSummaryFromRedis(`room:${roomId}:${hourKey}`);
      if (redisRoomHour) {
        roomEnergy += redisRoomHour.total_energy;
        console.log(`Found real-time data in Redis for room ${roomId} at hour ${hourKey}: ${redisRoomHour.total_energy}`);
      } else {
        // Nếu không có trong Redis, truy vấn trong DB
        const dbRoomHour = await EnergySummary.findOne({
          where: {
            reference_id: roomId,
            summary_level: "room",
            period_type: "hourly",
            period_value: hourKey,
          },
        });
        if (dbRoomHour) {
          roomEnergy += dbRoomHour.total_energy;
          console.log(`Found hourly data in DB for room ${roomId} at hour ${hourKey}: ${dbRoomHour.total_energy}`);
        }
      }
    }
  
    // 3. Cộng vào tổng năng lượng của nhà
    // totalEnergy += roomEnergy;
    contributors.push({ roomId, total_energy: roomEnergy });
    console.log(`Room ${roomId} contributed energy: ${roomEnergy}`);
  }
  
  console.log(`Total energy calculated for house ${houseId}: ${totalEnergy}`);
  console.log(`Contributors data for house ${houseId}: ${JSON.stringify(contributors)}`);
  return { totalEnergy, contributors };
}

// Lấy dữ liệu tổng hợp cho room, tính toán tổng năng lượng từ daily và hourly nếu không có dữ liệu cho monthly
exports.getRoomSummaryData = async (roomId, period, start, end) => {
  let totalEnergy = 0;
  let contributors = [];

  // console.log(`Fetching room summary data for roomId: ${roomId}, period: ${period}`);

  const summaryData = await exports.getSummary("room", roomId, period, 1);
  // console.log(`Fetched summary data from getSummary: ${JSON.stringify(summaryData)}`);

  if (summaryData.length > 0 && summaryData[0].total_energy > 0) {
    totalEnergy = summaryData[0].total_energy;
    // console.log(`Using cached summary data for room, totalEnergy: ${totalEnergy}`);
  } else {
    const data = await calculateRoomTemporaryEnergyConsumption(roomId, period);
    totalEnergy = data.totalEnergy;
    contributors = data.contributors;
    console.log(`No cached summary found for room, calculating temporary energy consumption. TotalEnergy: ${totalEnergy}, Contributors: ${JSON.stringify(contributors)}`);
  }

  return { totalEnergy, contributors };
};

async function calculateRoomTemporaryEnergyConsumption(roomId, period) {
  const now = moment().tz("Asia/Ho_Chi_Minh");
  let totalEnergy = 0;
  let contributors = [];

  console.log(`Calculating temporary energy consumption for room: ${roomId}`);

  const startOfMonth = now.clone().startOf("month");
  const yesterday = now.clone().subtract(1, "day").endOf("day");

  // Lấy dữ liệu daily từ database cho phòng
  const dailyResults = await EnergySummary.findAll({
    where: {
      reference_id: roomId,
      summary_level: "room",
      period_type: "daily",
      period_value: {
        [Op.between]: [startOfMonth.format("YYYY-MM-DD"), yesterday.format("YYYY-MM-DD")],
      },
    },
  });
  totalEnergy += dailyResults.reduce((sum, row) => sum + row.total_energy, 0);
  console.log(`Fetched daily energy data for room: ${roomId}, totalEnergy: ${totalEnergy}`);

  for (let hour = 0; hour <= now.hour(); hour++) {
    const hourKey = `${now.format("YYYY-MM-DD")} ${String(hour).padStart(2, '0')}:00:00`;
    console.log(`Checking for hourly energy data for room ${roomId} at hour: ${hour}, hourKey: ${hourKey}`);

    const redisHour = await getSummaryFromRedis(`room:${roomId}:${hourKey}`);
    if (redisHour) {
      totalEnergy += redisHour.total_energy;
      console.log(`Found real-time data in Redis for room ${roomId} at hour ${hourKey}: ${redisHour.total_energy}`);
    } else {
      const dbHour = await EnergySummary.findOne({
        where: {
          reference_id: roomId,
          summary_level: "room",
          period_type: "hourly",
          period_value: hourKey,
        },
      });
      if (dbHour) {
        totalEnergy += dbHour.total_energy;
        console.log(`Found hourly data in DB for room ${roomId} at hour ${hourKey}: ${dbHour.total_energy}`);
      }
    }
  }

  let roomDevices = await redisClient.smembers(`room:${roomId}:devices`);

  if (!roomDevices || roomDevices.length === 0) {
    console.log(`❌ Data not found in Redis for house ${roomId}, rebuilding rooms...`);
    await buildRoomDevices(roomId);  // Gọi hàm để lấy lại danh sách phòng và lưu vào Redis
    roomDevices = await redisClient.smembers(`room:${roomId}:devices`);
  }
  for (const deviceId of roomDevices) {
    let deviceEnergy = 0;

    const dailyResults = await EnergySummary.findAll({
      where: {
        reference_id: deviceId,
        summary_level: "device",
        period_type: "daily",
        period_value: {
          [Op.between]: [startOfMonth.format("YYYY-MM-DD"), yesterday.format("YYYY-MM-DD")],
        },
      },
    });
  
    deviceEnergy += dailyResults.reduce((sum, row) => sum + (row.total_energy || 0), 0);
    console.log(`Device ${deviceId}: Total energy from daily data: ${deviceEnergy}`);
  
    for (let hour = 0; hour <= now.hour(); hour++) {
      const hourKey = `${now.format("YYYY-MM-DD")} ${String(hour).padStart(2, '0')}:00:00`;
      console.log(`Checking for hourly energy data for device ${deviceId} at hour: ${hour}, hourKey: ${hourKey}`);

      const redisDeviceHour = await getSummaryFromRedis(`device:${deviceId}:${hourKey}`);
      if (redisDeviceHour) {
        deviceEnergy += redisDeviceHour.total_energy;
        console.log(`Found real-time data in Redis for device ${deviceId} at hour ${hourKey}: ${redisDeviceHour.total_energy}`);
      } else {
        const dbDeviceHour = await EnergySummary.findOne({
          where: {
            reference_id: deviceId,
            summary_level: "device",
            period_type: "hourly",
            period_value: hourKey,
          },
        });
        if (dbDeviceHour) {
          deviceEnergy += dbDeviceHour.total_energy;
          console.log(`Found hourly data in DB for device ${deviceId} at hour ${hourKey}: ${dbDeviceHour.total_energy}`);
        }
      }
    }

    // totalEnergy += deviceEnergy;
    contributors.push({ deviceId, total_energy: deviceEnergy });
    console.log(`Device ${deviceId} contributed energy: ${deviceEnergy}`);
  }
  console.log(`Total energy calculated for room ${roomId}: ${totalEnergy}`);
  console.log(`Contributors data for room ${roomId}: ${JSON.stringify(contributors)}`);
  return { totalEnergy, contributors };
}


