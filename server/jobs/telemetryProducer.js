const redisClient = require("../config/redisClient");
const {telemetryQueue} = require("../queue")

async function getLoggedInUserIds() {
    try {
        const userIds = await redisClient.smembers("logged_in_users:id");
        return userIds.length > 0 ? userIds : [];
    } catch (error) {
        return [];
    }
}


async function addTelemetryJobs() {
    const userIds = await getLoggedInUserIds();
    const batchSize = 5;

    for (let i = 0; i < userIds.length; i += batchSize) {
        const batch = userIds.slice(i, i + batchSize);
        await telemetryQueue.add("checkTelemetryBatch", { userIds: batch });
    }
}

setInterval(addTelemetryJobs, 15000);

module.exports = telemetryQueue;
