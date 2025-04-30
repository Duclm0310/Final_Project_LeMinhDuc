const cron = require("node-cron");
const { energySummaryQueue } = require("../queue");

cron.schedule("* * * * *", async () => {
    console.log("📌 Chạy báo cáo ngày...");
    await energySummaryQueue.add("daily-summary", { period: "day" });
});

console.log("✅ Scheduler is running...");



module.exports = energySummaryQueue;
