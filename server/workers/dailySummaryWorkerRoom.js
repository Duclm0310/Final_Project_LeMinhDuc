const moment = require('moment-timezone');
const { Worker } = require("bullmq");
const { connection } = require("../queue.js"); // KHÔNG import dailySummaryQueue ở đây
const {
    handleHourlySummary,
    handleDailySummary,
    handleWeeklySummary,
    handleMonthlySummary,
} = require("../services/summaryenergyroom.service.js");

const summaryWorker = new Worker(
    "daily-summary", 
    async (job) => {
        if (job.name === "summary-room-job") {

            const { room_id, device_ids, period, date } = job.data;
    
            switch (period) {
                case "hourly":
                    console.log(`[Queue] Processing hourly summary for room ${room_id}`);
                    handleHourlySummary(room_id, device_ids, date);
                    break;
                case "daily":
                    console.log(`[Queue] Processing daily summary for room ${room_id}`);
                    handleDailySummary(room_id, device_ids, date);
                    break;
                case "weekly":
                    console.log(`[Queue] Processing weekly summary for room ${room_id}`);
                    handleWeeklySummary(room_id, device_ids, date);
                    break;
                case "monthly":
                    console.log(`[Queue] Processing monthly summary for room ${room_id}`);
                    handleMonthlySummary(room_id, device_ids, date);
                    break;
                default:
                    console.warn(`[Queue] Unknown period: ${period}`);
            }
        }
    },
    {
        connection,
    }
);

// Bắt lỗi nếu worker gặp lỗi
summaryWorker.on("failed", (job, err) => {
    console.error(`[Worker] Job ${job.id} failed with error: ${err.message}`);
});

module.exports = summaryWorker;