const moment = require('moment-timezone');
const { Worker } = require("bullmq");
const { connection } = require("../queue.js"); // KHÔNG import dailySummaryQueue ở đây
const { handleHourlySummary, handleDailySummary, handleWeeklySummary, handleMonthlySummary } = require("../services/summaryenergyhouse.service.js");

const summaryWorker = new Worker(
    "daily-summary",
    async (job) => {
        if (job.name === "summary-house-job") {
            const { house_id, period, date } = job.data;
            console.log(`[Worker] Processing ${period} summary for house ${house_id} at ${date}`);

            try {
                switch (period) {
                    case "hourly":
                        await handleHourlySummary(house_id, date);
                        break;
                    case "daily":
                        await handleDailySummary(house_id, date);
                        break;
                    case "weekly":
                        await handleWeeklySummary(house_id, date);
                        break;
                    case "monthly":
                        await handleMonthlySummary(house_id, date);
                        break;
                    default:
                        console.warn(`[Worker] Unknown period: ${period}`);
                }
            } catch (err) {
                console.error(`[Worker] Error processing job: ${err.message}`);
            }
        }
    },
    { connection }
);

summaryWorker.on("failed", (job, err) => {
    console.error(`[Worker] Job ${job.id} failed with error: ${err.message}`);
});

module.exports = summaryWorker;