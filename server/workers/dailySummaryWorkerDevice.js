// daily-summary.worker.js
const { Worker } = require("bullmq");
const { connection } = require("../queue.js");

const { processDaily, processWeekly, processMonthly } = require("../services/summaryenergydevice.service.js");

const summaryWorker = new Worker(
    "daily-summary",
    async (job) => {
        if (job.name === "summary-job") {
            const { period, device_id, date } = job.data;
            switch (period) {
                case "daily":
                    return await processDaily(device_id, date);
                case "weekly":
                    return await processWeekly(device_id, date);
                case "monthly":
                    return await processMonthly(device_id, date);
                default:
                    throw new Error("Unknown period type");
            }
        }
    },
    { connection, concurrency: 3 }
);


console.log("[Daily Summary Worker] is running...");
module.exports = summaryWorker;
