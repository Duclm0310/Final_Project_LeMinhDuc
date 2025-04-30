const { Worker } = require("bullmq");
const { connection } = require("../queue");
const redisClient = require("../config/redisClient");
const warningService = require("../services/warning.service");
const{updateUserInfoInRedis, updateInvalidToken} = require("../services/redis.service");

const notificationWorker = new Worker(
  "notificationQueue",
  async (job) => {
    const { userId, deviceId, deviceName, telemetry, threshold, methods, title, message, houseId } = job.data;

    if (job.name === "check-cost-threshold") {
      // Xử lý thông báo cho chi phí vượt ngưỡng
      await handleCostThresholdNotification(userId, houseId, title, message, methods);
    } else if (job.name === "check-device-threshold") {
      // Xử lý thông báo cho thiết bị vượt ngưỡng
      await handleDeviceThresholdNotification(userId, deviceId, deviceName, telemetry, threshold, methods, title, message);
    } else {
      console.error("Unknown job name:", job.name);
    }
  },
  { connection, concurrency: 5 }
);

notificationWorker.on("completed", (job) => {
  console.log(`🎯 [NotificationWorker] Completed job for user: ${job.data.userId}`);
});

notificationWorker.on("failed", (job, err) => {
  console.error(`💥 [NotificationWorker] Job failed for user: ${job.data.userId}`, err);
});

// Xử lý thông báo khi chi phí vượt ngưỡng
async function handleCostThresholdNotification(userId, houseId, title, message, methods) {
  console.log(`[Cost Threshold] Sending notification to user ${userId} for house ${houseId}`);

  // Gửi thông báo qua PUSH và/hoặc EMAIL
  for (const method of methods) {
    if (method === "PUSH") {
      await sendPushNotification(userId, title, message);
    }
    if (method === "EMAIL") {
      await sendEmailNotification(userId, title, message);
    }
  }
}

// Xử lý thông báo khi thiết bị vượt ngưỡng
async function handleDeviceThresholdNotification(userId, deviceId, deviceName, telemetry, threshold, methods, title, message) {
  console.log(`[Device Threshold] Sending notification to user ${userId} for device ${deviceId}`);

  // Tạo tiêu đề và thông báo cho thiết bị
  const notificationTitle = title || `Alert: ${deviceName} exceeded threshold`;
  const notificationMessage = message || `Power: ${telemetry.power}W / Max ${threshold.max_power}W, Current: ${telemetry.current}A / Max ${threshold.max_current}A`;

  // Gửi thông báo qua PUSH và/hoặc EMAIL
  for (const method of methods) {
    if (method === "PUSH") {
      await sendPushNotification(userId, notificationTitle, notificationMessage);
    }
    if (method === "EMAIL") {
      await sendEmailNotification(userId, notificationTitle, notificationMessage);
    }
  }
}

// Gửi thông báo PUSH
async function sendPushNotification(userId, title, message) {
  let tokenJson = await redisClient.get(`device_tokens:${userId}`);
  let tokens = tokenJson ? JSON.parse(tokenJson) : [];
  if (tokens.length === 0) {
    console.warn(`⚠️ [PUSH] No device tokens found for user ${userId}, Update token...`);
    await updateInvalidToken(userId)
    tokenJson = await redisClient.get(`device_tokens:${userId}`);
    tokens = tokenJson ? JSON.parse(tokenJson) : [];
    if(tokens.length === 0) {
      console.warn(`⚠️ [PUSH] No device tokens found for user ${userId}`);
      return;
    }

  }

  for (const token of tokens) {
    if (token && token.token) {
      try {
        console.log(`➡️ [PUSH] Sending to token: ${token.token}`);
        await warningService.sendNotification(token.token, title, message);
        console.log(`✅ [PUSH] Successfully sent to token: ${token.token}`);
      } catch (error) {
        console.error(`❌ [PUSH] Failed to send to token: ${token.token}`, error);
      }
    }
  }
}

// Gửi thông báo EMAIL
async function sendEmailNotification(userId, title, message) {
  let userData = await redisClient.hgetall(`user:${userId}`);
  let email = userData?.email;
  if(!email){
    userData = await updateUserInfoInRedis(userId)
    email = userData?.email;
    if(!email){
      console.warn(`⚠️ [EMAIL] No Email found for user ${userId} `);
    }
  }



  if (email) {
    console.log(`➡️ [EMAIL] Sending to email: ${email}`);
    await warningService.sendEmailNotification(email, title, message);
    console.log(`[EMAIL] Successfully sent to email: ${email}`);
  } else {
    console.warn(`[EMAIL] No email found for user: ${userId}`);
  }
}

module.exports = notificationWorker;
