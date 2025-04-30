const moment = require("moment-timezone");
const { Op } = require("sequelize");
const { EnergySummary } = require("../models");
const { getSummaryFromRedis } = require("../services/redis.service");

async function saveOrUpdateSummary(device_id, level, type, periodValue, total_energy, average_power, peak_energy) {
    const [summary, created] = await EnergySummary.findOrCreate({
        where: {
            reference_id: device_id,
            summary_level: level,
            period_type: type,
            period_value: periodValue,
        },
        defaults: {
            total_energy,
            average_power,
            peak_energy,
        },
    });

    if (!created) {
        await summary.update({ total_energy, average_power, peak_energy });
    }
}

async function getSummariesFromCacheOrDB(device_id, level, type, keys) {
    const summaries = await Promise.all(
        keys.map(k => getSummaryFromRedis(`${level}:${device_id}:${k}`))
    );
    const missingKeys = keys.filter((_, idx) => !summaries[idx]);

    if (missingKeys.length > 0) {
        console.warn(`[Cache Miss] ${missingKeys.length} summaries for device ${device_id}`);
        const dbSummaries = await EnergySummary.findAll({
            where: {
                reference_id: device_id,
                summary_level: level,
                period_type: type,
                period_value: { [Op.in]: missingKeys },
            },
            raw: true,
        });
        dbSummaries.forEach(s => {
            const idx = keys.indexOf(s.period_value);
            if (idx !== -1) summaries[idx] = s;
        });
    }
    return summaries.filter(Boolean);
}

async function processDaily(device_id, date) {
    const start = moment.tz(date, "Asia/Ho_Chi_Minh").startOf("day");
    const keys = [];
    for (let i = 0; i < 24; i++) {
        keys.push(start.clone().add(i, 'hours').format("YYYY-MM-DD HH:00:00"));
    }

    const hourlySummaries = await getSummariesFromCacheOrDB(device_id, "device", "hourly", keys);

    if (hourlySummaries.length === 0) {
        await saveOrUpdateSummary(device_id, "device", "daily", start.format("YYYY-MM-DD"), null, null, null);
        return;
    }

    const total_energy = hourlySummaries.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = hourlySummaries.reduce((sum, r) => sum + (r.average_power || 0), 0) / hourlySummaries.length;
    const peak_energy = Math.max(...hourlySummaries.map(r => r.peak_energy || 0));

    await saveOrUpdateSummary(device_id, "device", "daily", start.format("YYYY-MM-DD"), total_energy, average_power, peak_energy);

    await setDeviceDailySummary(device_id, start.format("YYYY-MM-DD"), {
        total_energy,
        average_power,
        peak_energy
    });
}

async function processWeekly(device_id, date) {
    const start = moment.tz(date, "Asia/Ho_Chi_Minh").startOf('isoWeek');
    const keys = [];
    for (let i = 0; i < 7; i++) {
        keys.push(start.clone().add(i, 'days').format("YYYY-MM-DD"));
    }

    const dailySummaries = await getSummariesFromCacheOrDB(device_id, "device", "daily", keys);

    if (dailySummaries.length === 0) {
        await saveOrUpdateSummary(device_id, "device", "weekly", start.format("YYYY-[W]WW"), null, null, null);
        return;
    }

    const total_energy = dailySummaries.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = dailySummaries.reduce((sum, r) => sum + (r.average_power || 0), 0) / dailySummaries.length;
    const peak_energy = Math.max(...dailySummaries.map(r => r.peak_energy || 0));

    await saveOrUpdateSummary(device_id, "device", "weekly", start.format("YYYY-[W]WW"), total_energy, average_power, peak_energy);
}

async function processMonthly(device_id, date) {
    const start = moment.tz(date, "Asia/Ho_Chi_Minh").startOf('month');
    const daysInMonth = start.daysInMonth();
    const keys = [];
    for (let i = 0; i < daysInMonth; i++) {
        keys.push(start.clone().add(i, 'days').format("YYYY-MM-DD"));
    }

    const dailySummaries = await getSummariesFromCacheOrDB(device_id, "device", "daily", keys);

    if (dailySummaries.length === 0) {
        await saveOrUpdateSummary(device_id, "device", "monthly", start.format("YYYY-MM"), null, null, null);
        return;
    }

    const total_energy = dailySummaries.reduce((sum, r) => sum + (r.total_energy || 0), 0);
    const average_power = dailySummaries.reduce((sum, r) => sum + (r.average_power || 0), 0) / dailySummaries.length;
    const peak_energy = Math.max(...dailySummaries.map(r => r.peak_energy || 0));

    await saveOrUpdateSummary(device_id, "device", "monthly", start.format("YYYY-MM"), total_energy, average_power, peak_energy);
}

// Export
module.exports = {
    processDaily,
    processWeekly,
    processMonthly,
};
