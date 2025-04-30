const cron = require("node-cron");
const { dailySummaryQueue, energySummaryQueue, realtimeQueue } = require("../queue");
const { Device } = require("../models/index");
const moment = require('moment-timezone');

const {getCachedActiveDevices} = require("../services/redis.service");

async function addSummaryJobs(period) {
    const devices = await getCachedActiveDevices();
    const date = moment().tz("Asia/Ho_Chi_Minh").format("YYYY-MM-DD");

    for (const device of devices) {
        console.log(`[Cron] Add ${period} summary for ${device.device_id}`);
        await dailySummaryQueue.add("summary-job", {
            device_id: device.device_id,
            period,
            date,
        });
    }
}

async function addHourlySummaryJobs() {
    const devices = await getCachedActiveDevices();
    for (const device of devices) {
        await energySummaryQueue.add("hourly-summary", {
            period: "hourly",
            device_id: device.device_id,
        });
    }
}

async function addRealtimeSummaryJobs() {
    const devices = await getCachedActiveDevices();
    for (const device of devices) {
        await realtimeQueue.add("realtime-summary", {
            device_id: device.device_id,
        });
    }
}

// CRON

// cron.schedule("* * * * *", async () => {
//     console.log("🔁 Realtime summary run");
//     await addRealtimeSummaryJobs();
// });

// cron.schedule("5 * * * *", async () => {
cron.schedule("* * * * *", async () => {    
    console.log("⏳ Hourly summary run");
    await addHourlySummaryJobs();
});

cron.schedule("10 0 * * *", () => {
    addSummaryJobs("daily");
});

cron.schedule("15 0 * * 1", () => {
    addSummaryJobs("weekly");
});

cron.schedule("25 1 1 * *", () => {
    addSummaryJobs("monthly");
});
