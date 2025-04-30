const { Worker } = require("bullmq");
const { connection } = require("../queue"); 
const { checkTelemetryForAlerts, checkTelemetryBatchForAlerts } = require("../services/alert.service");

const telemetryWorker = new Worker(
    "telemetryQueue",
    async (job) => {
        const { userIds } = job.data;
        await checkTelemetryBatchForAlerts(userIds);
    },
    { connection, concurrency: 10 }
);


telemetryWorker.on("completed", (job) => {
    console.log(`✅ Completed telemetry check for users:`, job.data.userIds);
});

telemetryWorker.on("failed", (job, err) => {
    console.error(`❌ Telemetry job failed:`, err);
});

module.exports = telemetryWorker;
