const { EnergySummary } = require("../models");
const { Op } = require("sequelize");
const moment = require("moment-timezone");
const { getSummaryFromRedis, buildRoomDevices, setRoomHourlySummary, setRoomDailySummary } = require("./redis.service");
const redisClient = require("../config/redisClient");


async function saveOrUpdateRoomSummary(room_id, period_type, period_value, data) {
    try {
        const [summary, created] = await EnergySummary.findOrCreate({
            where: {
                reference_id: room_id,
                summary_level: "room",
                period_type,
                period_value,
            },
            defaults: data,
        });

        if (!created) {
            await summary.update(data);
            console.log(`[Room Summary] 🔄 Updated ${period_type} summary for room ${room_id}`);
        } else {
            console.log(`[Room Summary] 🆕 Created ${period_type} summary for room ${room_id}`);
        }
    } catch (err) {
        console.error(`[Room Summary] ❌ Failed to save summary for room ${room_id} (${period_type} - ${period_value})`, err);
        throw err; // Optional: rethrow nếu muốn fail toàn bộ task
    }
}

// Lấy dữ liệu từ cache hoặc fallback DB
async function getSummariesFromCacheOrDB(deviceIds, period_type, period_keys) {
    const summaries = await Promise.all(
        deviceIds.flatMap(deviceId => 
            period_keys.map(key => 
                getSummaryFromRedis(`device:${deviceId}:${key}`)
            )
        )
    );
    
    const missing = [];
    for (let idx = 0; idx < summaries.length; idx++) {
        if (!summaries[idx]) {
            const deviceIdx = Math.floor(idx / period_keys.length);
            const keyIdx = idx % period_keys.length;
            missing.push({ deviceId: deviceIds[deviceIdx], period: period_keys[keyIdx] });
        }
    }

    if (missing.length > 0) {
        console.warn(`[Cache Miss] Fallback DB query for ${missing.length} missing device summaries`);
        
        const dbSummaries = await EnergySummary.findAll({
            where: {
                reference_id: { [Op.in]: missing.map(m => m.deviceId) },
                summary_level: "device",
                period_type,
                period_value: { [Op.in]: missing.map(m => m.period) }
            },
            raw: true,
        });

        dbSummaries.forEach(dbSum => {
            const idx = missing.findIndex(m => m.deviceId === dbSum.reference_id && m.period === dbSum.period_value);
            if (idx !== -1) {
                summaries[idx + missing[idx].deviceId * period_keys.length] = dbSum;
            }
        });
    }

    return summaries.filter(Boolean);
}

// Tổng hợp 1 Room
async function summarizeRoom({ room_id, device_ids, period_type, period_value, start, end }) {
    console.log(`[Room Summary] ▶️ Start summarizing room ${room_id} (${period_type} - ${period_value})`);

    let period_keys = [];

    if (period_type === "hourly") {
        period_keys.push(start.format("YYYY-MM-DD HH:00:00"));
    } else if (period_type === "daily") {
        for (let i = 0; i < 24; i++) {
            period_keys.push(start.clone().add(i, "hours").format("YYYY-MM-DD HH:00:00"));
        }
    } else if (period_type === "weekly") {
        for (let i = 0; i < 7; i++) {
            period_keys.push(start.clone().add(i, "days").format("YYYY-MM-DD"));
        }
    } else if (period_type === "monthly") {
        const daysInMonth = start.daysInMonth();
        for (let i = 0; i < daysInMonth; i++) {
            period_keys.push(start.clone().add(i, "days").format("YYYY-MM-DD"));
        }
    } else {
        console.warn(`[Room Summary] ⚠️ Unknown period_type: ${period_type}`);
        return;
    }

    const data = await getSummariesFromCacheOrDB(device_ids, period_type === "hourly" ? "hourly" : "daily", period_keys);

    if (data.length === 0) {
        console.warn(`[Room Summary] ⚠️ No device summaries found for room ${room_id}`);
        return;
    }

    const total_energy = data.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = data.length > 0 ? data.reduce((sum, r) => sum + (r.average_power || 0), 0) / data.length : 0;
    const peak_energy = data.length > 0 ? Math.max(...data.map(r => r.peak_energy || 0)) : 0;
    const downtime_minutes = data.reduce((sum, r) => sum + (r.downtime_minutes || 0), 0);

    const summaryData = { total_energy, average_power, peak_energy, downtime_minutes };

    try {
        await saveOrUpdateRoomSummary(room_id, period_type, period_value, summaryData);
        console.log(`[Room Summary] ✅ Successfully saved room ${room_id} (${period_type} - ${period_value})`);
    } catch (err) {
        console.error(`[Room Summary] ❌ Failed saving room ${room_id}`, err);
    }

    // Nếu muốn cache lại Redis thì mở comment dưới đây:
    // if (period_type === "hourly") {
    //     await setRoomHourlySummary(room_id, period_value, summaryData);
    // } else if (period_type === "daily") {
    //     await setRoomDailySummary(room_id, period_value, summaryData);
    // }
}

// Handler cho từng khung thời gian
async function handleHourlySummary(room_id, device_ids, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("hour");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("hour");
    await summarizeRoom({ room_id, device_ids, period_type: "hourly", period_value: start.format("YYYY-MM-DD HH:00:00"), start, end });
}

async function handleDailySummary(room_id, device_ids, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("day");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("day");
    await summarizeRoom({ room_id, device_ids, period_type: "daily", period_value: start.format("YYYY-MM-DD"), start, end });
}

async function handleWeeklySummary(room_id, device_ids, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("isoWeek");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("isoWeek");
    await summarizeRoom({ room_id, device_ids, period_type: "weekly", period_value: start.format("YYYY-[W]WW"), start, end });
}

async function handleMonthlySummary(room_id, device_ids, date) {
    const start = moment(date).tz("Asia/Ho_Chi_Minh").startOf("month");
    const end = moment(date).tz("Asia/Ho_Chi_Minh").endOf("month");
    await summarizeRoom({ room_id, device_ids, period_type: "monthly", period_value: start.format("YYYY-MM"), start, end });
}

// Realtime tổng hợp nhanh 1 giờ
async function handleRoomHourlyRealtime(room_id, hourKey) {
    let deviceIds = await redisClient.smembers(`room:${room_id}:devices`);
    if (!deviceIds || deviceIds.length === 0) {
        await buildRoomDevices(room_id);
        deviceIds = await redisClient.smembers(`room:${room_id}:devices`);
    }

    const summaries = await Promise.all(
        deviceIds.map(id => getSummaryFromRedis(`device:${id}:${hourKey}`))
    );
    const valid = summaries.filter(Boolean);

    if (valid.length === 0) return;

    const total_energy = valid.reduce((sum, r) => sum + r.total_energy, 0);
    const average_power = valid.reduce((sum, r) => sum + (r.average_power || 0), 0) / valid.length;
    const peak_energy = Math.max(...valid.map(r => r.peak_energy || 0));
    const downtime_minutes = valid.reduce((sum, r) => sum + (r.downtime_minutes || 0), 0);

    await setRoomHourlySummary(room_id, hourKey, { total_energy, average_power, peak_energy, downtime_minutes });

    console.log(`[Room] ✅ Cached room ${room_id} hourly summary ${hourKey}`);
}

module.exports = {
    handleHourlySummary,
    handleDailySummary,
    handleWeeklySummary,
    handleMonthlySummary,
    handleRoomHourlyRealtime
};
