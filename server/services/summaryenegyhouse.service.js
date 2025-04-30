const { EnergySummary } = require("../models");
const { Op } = require("sequelize");
const moment = require("moment-timezone");
const { getSummaryFromRedis, setHouseHourlySummary, setHouseDailySummary, rebuildHouseCache } = require("./redis.service");
const redisClient = require("../config/redisClient");

// Lưu DB + Redis sau khi tổng hợp
async function saveOrUpdateHouseSummary(house_id, period_type, period_value, data) {
    const [summary, created] = await EnergySummary.findOrCreate({
        where: {
            reference_id: house_id,
            summary_level: "house",
            period_type,
            period_value,
        },
        defaults: data,
    });

    if (!created) {
        await summary.update(data);
        console.log(`[House Summary] Updated ${period_type} summary for house ${house_id}`);
    } else {
        console.log(`[House Summary] Created ${period_type} summary for house ${house_id}`);
    }
}

// Tổng hợp House
async function summarizeHouse({ house_id, period_type, period_value, start, end }) {
    let roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    if (!roomIds || roomIds.length === 0) {
        console.warn(`[Cache] No rooms cache for house ${house_id}, rebuilding...`);
        await rebuildHouseCache(house_id);
        roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    }

    if (!roomIds || roomIds.length === 0) {
        console.warn(`[House Summary] No rooms found for house ${house_id}`);
        return;
    }

    let period_keys = [];

    if (period_type === "hourly") {
        period_keys.push(start.format("YYYY-MM-DD HH:00:00"));
    } else if (period_type === "daily") {
        for (let i = 0; i < 24; i++) {
            period_keys.push(start.clone().add(i, 'hours').format("YYYY-MM-DD HH:00:00"));
        }
    } else if (period_type === "weekly") {
        for (let i = 0; i < 7; i++) {
            period_keys.push(start.clone().add(i, 'days').format("YYYY-MM-DD"));
        }
    } else if (period_type === "monthly") {
        const daysInMonth = start.daysInMonth();
        for (let i = 0; i < daysInMonth; i++) {
            period_keys.push(start.clone().add(i, 'days').format("YYYY-MM-DD"));
        }
    } else {
        console.warn(`[House Summary] Unknown period_type: ${period_type}`);
        return;
    }

    // Lấy dữ liệu từ cache Redis trước
    const summaries = await Promise.all(
        roomIds.flatMap(roomId => 
            period_keys.map(key => getSummaryFromRedis(`room:${roomId}:${key}`))
        )
    );

    const valid = summaries.filter(Boolean);

    if (valid.length === 0) {
        console.warn(`[House Summary] No room summaries found for house ${house_id}`);
        return;
    }

    // Tổng hợp lại
    const total_energy = valid.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = valid.reduce((sum, r) => sum + (r.average_power || 0), 0) / valid.length;
    const peak_energy = Math.max(...valid.map(r => r.peak_energy || 0));
    const downtime_minutes = valid.reduce((sum, r) => sum + (r.downtime_minutes || 0), 0);

    const summaryData = { total_energy, average_power, peak_energy, downtime_minutes };

    // Save DB + cache lại Redis
    await saveOrUpdateHouseSummary(house_id, period_type, period_value, summaryData);

    if (period_type === "hourly") {
        await setHouseHourlySummary(house_id, period_value, summaryData);
    } else if (period_type === "daily") {
        await setHouseDailySummary(house_id, period_value, summaryData);
    }
}

// Handler từng khung thời gian
async function handleHourlySummary(house_id, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("hour");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("hour");

    await summarizeHouse({
        house_id,
        period_type: "hourly",
        period_value: start.format("YYYY-MM-DD HH:00:00"),
        start,
        end,
    });
}

async function handleDailySummary(house_id, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("day");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("day");

    await summarizeHouse({
        house_id,
        period_type: "daily",
        period_value: start.format("YYYY-MM-DD"),
        start,
        end,
    });
}

async function handleWeeklySummary(house_id, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("isoWeek");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("isoWeek");

    await summarizeHouse({
        house_id,
        period_type: "weekly",
        period_value: start.format("YYYY-MM-DD"),
        start,
        end,
    });
}

async function handleMonthlySummary(house_id, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("month");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("month");

    await summarizeHouse({
        house_id,
        period_type: "monthly",
        period_value: start.format("YYYY-MM"),
        start,
        end,
    });
}

// Realtime tổng hợp nhanh 1 giờ
async function handleHouseHourlyRealtime(house_id, hourKey) {
    let roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    if (!roomIds || roomIds.length === 0) {
        await rebuildHouseCache(house_id);
        roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    }

    const summaries = await Promise.all(
        roomIds.map(id => getSummaryFromRedis(`room:${id}:${hourKey}`))
    );
    const valid = summaries.filter(Boolean);
    if (valid.length === 0) return;

    const total_energy = valid.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = valid.reduce((sum, r) => sum + (r.average_power || 0), 0) / valid.length;
    const peak_energy = Math.max(...valid.map(r => r.peak_energy || 0));
    const downtime_minutes = valid.reduce((sum, r) => sum + (r.downtime_minutes || 0), 0);

    await setHouseHourlySummary(house_id, hourKey, {
        total_energy,
        average_power,
        peak_energy,
        downtime_minutes
    });

    console.log(`[House] ✅ Cached house ${house_id} hourly summary ${hourKey}`);
}

module.exports = {
    handleHourlySummary,
    handleDailySummary,
    handleWeeklySummary,
    handleMonthlySummary,
    handleHouseHourlyRealtime,
};
