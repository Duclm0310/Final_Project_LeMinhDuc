const { EnergySummary } = require("../models");
const moment = require("moment-timezone");
const { getSummaryFromRedis, setHouseHourlySummary, setHouseDailySummary, rebuildHouseCache } = require("./redis.service");
const { publishEvent } = require('../sockets/redisPubSub');
const redisClient = require("../config/redisClient");

// Save vào DB + Redis sau khi tổng hợp
async function saveOrUpdateHouseSummary(house_id, period_type, period_value, data) {
    try {
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
            console.log(`[House Summary] 🔄 Updated ${period_type} summary for house ${house_id}`);
        } else {
            console.log(`[House Summary] 🆕 Created ${period_type} summary for house ${house_id}`);
        }
    } catch (err) {
        console.error(`[House Summary] ❌ Failed to save summary for house ${house_id}`, err);
        throw err;
    }
}

async function summarizeHouse({ house_id, period_type, period_value, start, end }) {
    let roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    
    if (!roomIds || roomIds.length === 0) {
        console.warn(`[Cache] No rooms for house ${house_id}, rebuilding...`);
        await rebuildHouseCache(house_id);
        roomIds = await redisClient.smembers(`house:${house_id}:rooms`);
    }

    if (!roomIds || roomIds.length === 0) {
        console.error(`[House Summary] No rooms found for house ${house_id}`);
        return null;
    }

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
        console.warn(`[House Summary] Unknown period_type: ${period_type}`);
        return null;
    }

    let summaries = [];

    for (const roomId of roomIds) {
        for (const periodKey of period_keys) {
            const redisKey = `room:${roomId}:${periodKey}`;
            let summary = await getSummaryFromRedis(redisKey);

            if (!summary) {
                console.warn(`[Redis Miss] Fallback DB query room ${roomId} - ${periodKey}`);
                const dbSummary = await EnergySummary.findOne({
                    where: {
                        reference_id: roomId,
                        summary_level: "room",
                        period_type: period_type === "hourly" ? "hourly" : "daily",
                        period_value: periodKey,
                    },
                    raw: true,
                });

                if (dbSummary) {
                    summary = {
                        total_energy: dbSummary.total_energy || 0,
                        average_power: dbSummary.average_power || 0,
                        peak_energy: dbSummary.peak_energy || 0,
                        downtime_minutes: dbSummary.downtime_minutes || 0,
                    };
                }
            }

            if (summary) {
                summaries.push(summary);
            }
        }
    }

    if (summaries.length === 0) {
        console.warn(`[House Summary] No data available to summarize for house ${house_id}`);
        return null;
    }

    // Aggregate
    const total_energy = summaries.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = summaries.reduce((sum, r) => sum + (r.average_power || 0), 0) / summaries.length;
    const peak_energy = Math.max(...summaries.map(r => r.peak_energy || 0));
    const downtime_minutes = summaries.reduce((sum, r) => sum + (r.downtime_minutes || 0), 0);

    const summaryData = {
        total_energy,
        average_power,
        peak_energy,
        downtime_minutes,
    };

    console.log(`[House Summary] ✅ Calculated summary for house ${house_id} ${period_type} - ${period_value}:`, summaryData);

    // Save vào DB
    await saveOrUpdateHouseSummary(house_id, period_type, period_value, summaryData);

    // Save lại Redis nếu cần
    if (period_type === "hourly") {
        await setHouseHourlySummary(house_id, period_value, summaryData);
    } else if (period_type === "daily") {
        await setHouseDailySummary(house_id, period_value, summaryData);
    }

    return summaryData;
}

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


    const now = moment().tz("Asia/Ho_Chi_Minh");
    const startOfMonth = now.clone().startOf('month');
    const today = now.clone();

    const days = [];
    for (let d = startOfMonth.clone(); d.isSameOrBefore(today, 'day'); d.add(1, 'day')) {
        days.push(d.format('YYYY-MM-DD'));
    }

    let totalEnergy = 0;

    // Cộng các daily từ đầu tháng đến hôm qua
    const dailySummaries = await Promise.all(
        days.slice(0, -1).map(async (date) => {
            let redisData = await getSummaryFromRedis(`house:${house_id}:${date}`);
            if (redisData) {
                return redisData;
            } else {
                const dbData = await EnergySummary.findOne({
                    where: {
                        reference_id: house_id,
                        summary_level: "house",
                        period_type: "daily",
                        period_value: date,
                    },
                    raw: true,
                });
                return dbData ? {
                    total_energy: dbData.total_energy || 0,
                    average_power: dbData.average_power || 0,
                    peak_energy: dbData.peak_energy || 0,
                } : null;
            }
        })
    );

    totalEnergy += dailySummaries.filter(Boolean).reduce((sum, r) => sum + (r.total_energy || 0), 0);

    // Cộng các hourly của hôm nay
    for (let hour = 0; hour <= now.hour(); hour++) {
        const hourKey = `${now.format("YYYY-MM-DD")} ${String(hour).padStart(2, '0')}:00:00`;
        const redisHour = await getSummaryFromRedis(`house:${house_id}:${hourKey}`);
        if (redisHour) {
            totalEnergy += redisHour.total_energy;
        }
    }

    publishEvent(`house:${house_id}:hourly_updated`, {
        house_id,
        total_energy: totalEnergy,
        current_time: now.format(),
    });

    console.log(`[PubSub] ✅ Published updated monthly total for house ${house_id}: ${totalEnergy} kWh`);
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
