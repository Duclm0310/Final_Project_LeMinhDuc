const { Queue } = require("bullmq");
const Redis = require("ioredis");

const connection = new Redis({
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
});

// Queue chung option chuẩn
function createQueue(queueName) {
    return new Queue(queueName, {
        connection,
        defaultJobOptions: {
            removeOnComplete: true,
            attempts: 3,
            backoff: { type: "exponential", delay: 5000 },
            removeOnFail: 10,
        },
    });
}

const deviceQueue = createQueue("deviceQueue");
const energySummaryQueue = createQueue("energy-summary");
const dailySummaryQueue = createQueue("daily-summary");
const telemetryQueue = createQueue("telemetryQueue");
const checkCostThresholdQueue = createQueue("checkCostThresholdQueue");
const notificationQueue = createQueue("notificationQueue"); 
const realtimeQueue = createQueue("realtimeQueue")

module.exports = {
    deviceQueue,
    energySummaryQueue,
    telemetryQueue,
    dailySummaryQueue,
    checkCostThresholdQueue,
    notificationQueue,
    realtimeQueue,
    connection,
};
