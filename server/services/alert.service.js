const redisClient = require("../config/redisClient");
const { notificationQueue } = require("../queue");
const { Op } = require("sequelize");
const warningService = require("./warning.service");
const notificationService = require("../services/notification.service");
const { CostThreshold, House,  User, EnergySummary } = require("../models/index");
const { getElectricityCost } = require("./summary.service");
const moment = require("moment-timezone");
const { updateDeviceThresholds, updateThresholdCostInRedis, getThresholdCostFromRedis, getSummaryFromRedis, getUsersWithNotificationPermission } = require("../services/redis.service");


async function checkTelemetryBatchForAlerts(userIds) {
    try {

        for (const userId of userIds) {
            let thresholdsData = await redisClient.get(`user:${userId}:thresholds`);

            if (!thresholdsData) {
                await updateDeviceThresholds(userId);
                thresholdsData = await redisClient.get(`user:${userId}:thresholds`);
                if (!thresholdsData) {
                    // console.error(`❌ [User ${userId}] Cập nhật cache thất bại, bỏ qua user này.`);
                    continue;
                }
            }

            const thresholds = JSON.parse(thresholdsData);
            const deviceIds = Object.keys(thresholds);

            if (deviceIds.length === 0) {
                continue;
            }

            const telemetryKeys = deviceIds.map(id => `telemetry:${id}`);
            const telemetryDataList = await redisClient.mget(telemetryKeys);

            const deviceNamesJson = await redisClient.get(`user:${userId}:device_names`);
            const deviceNames = deviceNamesJson ? JSON.parse(deviceNamesJson) : {};

            for (let i = 0; i < deviceIds.length; i++) {
                const deviceId = deviceIds[i];
                const telemetryData = telemetryDataList[i];
                if (!telemetryData) {
                    console.warn(`⚠️ [Device ${deviceId}] have'n any telemetry.`);
                    continue;
                }

                const telemetry = JSON.parse(telemetryData);
                const threshold = thresholds[deviceId];

                if (!threshold) {
                    console.warn(`⚠️ [Device ${deviceId}] have'n any threshold.`);
                    continue;
                }

                const powerExceeded = telemetry.power > threshold.max_power;
                const currentExceeded = telemetry.current > threshold.max_current;

                if (powerExceeded || currentExceeded) {

                    const deviceNamesData = await redisClient.get(`user:${userId}:device_names`);
                    const deviceNames = deviceNamesData ? JSON.parse(deviceNamesData) : {};
                    const deviceName = deviceNames[deviceId] || "Unknown Device";

                    const title = `Alert: Device ${deviceName} exceeded the threshold`;
                    const message = `Device ${deviceName} exceeded the threshold:
                    Power: ${telemetry.power}W (max: ${threshold.max_power}W),
                    Current: ${telemetry.current}A (max: ${threshold.max_current}A)`;
                    console.log("Alert:", message);

                    await notificationService.createNotification({
                        user_id: userId,
                        device_id: deviceId,
                        type: "ALERT",
                        title: title,
                        message: message
                    });

                    // console.log(`🚨 [Alert] [User ${userId}] [Device ${deviceId} - ${deviceName}] Vượt ngưỡng: ${powerExceeded ? `Power ${telemetry.power}W` : ''} ${currentExceeded ? `Current ${telemetry.current}A` : ''}`);

                    await notificationQueue.add("check-device-threshold", {
                        userId,
                        deviceId,
                        deviceName,
                        telemetry,
                        threshold,
                        methods: threshold.notify_via,
                        title: `Alert: ${deviceName} exceeded threshold`,
                        message: `Power: ${telemetryData.power}W / Max ${threshold.max_power}W, Current: ${telemetryData.current}A / Max ${threshold.max_current}A`
                    });
                }
            }
        }
    } catch (error) {
        console.error(" [Telemetry Check] :", error);
    }
}


async function calculateTotalEnergy(houseId, now) {
    let totalEnergy = 0;

    const redisKey = `house:${houseId}:${now.format("YYYY-MM")}`;
    const redisData = await getSummaryFromRedis(redisKey);

    // --------------------- 1. Lấy dữ liệu daily từ đầu tháng đến hôm qua ---------------------
    const startOfMonth = now.clone().startOf('month').format("YYYY-MM-DD");
    const dailyCacheKey = `house:${houseId}:daily:${startOfMonth}-${now.clone().subtract(1, 'day').format("YYYY-MM-DD")}`;
    const dailyCache = await redisClient.get(dailyCacheKey);

    if (dailyCache) {
        totalEnergy = parseFloat(dailyCache);  // Dữ liệu daily đã có trong cache
    } else {
        // Nếu không có cache, lấy từ DB và cập nhật Redis
        const dailyResults = await EnergySummary.findAll({
            where: {
                reference_id: houseId,
                summary_level: "house",
                period_type: "daily",
                period_value: {
                    [Op.between]: [startOfMonth, now.clone().subtract(1, 'day').format("YYYY-MM-DD")]
                }
            },
            raw: true
        });
        totalEnergy = dailyResults.reduce((sum, row) => sum + (row.total_energy || 0), 0);
        await redisClient.set(dailyCacheKey, totalEnergy, 'EX', 24 * 60 * 60);  // Cache dữ liệu daily 8 ngày
    }

    // --------------------- 2. Lấy dữ liệu hourly từ đầu ngày đến giờ hiện tại ---------------------
    const startOfDay = now.clone().startOf("day").format("YYYY-MM-DD HH:00:00");
    const hourlyCacheKey = `house:${houseId}:hourly:${startOfDay}-${now.format("YYYY-MM-DD HH:00:00")}`;
    const hourlyCache = await redisClient.get(hourlyCacheKey);

    if (hourlyCache) {
        totalEnergy += parseFloat(hourlyCache);  // Dữ liệu hourly đã có trong cache
    } else {
        // Nếu không có cache, lấy từ DB và cập nhật Redis
        const hourlyResults = await EnergySummary.findAll({
            where: {
                reference_id: houseId,
                summary_level: "house",
                period_type: "hourly",
                period_value: {
                    [Op.between]: [startOfDay, now.format("YYYY-MM-DD HH:00:00")]
                }
            },
            raw: true
        });
        totalEnergy += hourlyResults.reduce((sum, row) => sum + (row.total_energy || 0), 0);
        await redisClient.set(hourlyCacheKey, totalEnergy, 'EX', 3600);  // Cache dữ liệu hourly 1 giờ
    }

    return totalEnergy;
}

async function checkCostThreshold(houseId) {
    const threshold_cost = await getThresholdCostFromRedis(houseId);
    if (!threshold_cost) {
        console.log(`No threshold found in Redis for house: ${houseId}`);
        const threshold = await CostThreshold.findOne({ where: { house_id: houseId } });
        if (!threshold) {
            console.log("Threshold not set for this house.");
            return;
        }
        await updateThresholdCostInRedis(houseId);
    }

    let totalEnergy = 0;
    const now = moment().tz("Asia/Ho_Chi_Minh");

    totalEnergy = await calculateTotalEnergy(houseId, now);

    const totalEnergyAndCost = await getElectricityCost("house", houseId, "monthly", now.clone().startOf('month').format("YYYY-MM-DD"), now.format("YYYY-MM-DD"));
    if (totalEnergyAndCost) {
        totalEnergy = totalEnergyAndCost.totalEnergy;
        cost = totalEnergyAndCost.cost;
    }

    // Check if alert has already been sent
    const houseAlertSentKey = `house:${houseId}:alert_sent`;
    const alertSent = await redisClient.get(houseAlertSentKey);
    if (alertSent) {
        console.log(`⚠️ Already sent alert for house ${houseId}, skipping.`);
        return;
    }


    const users = await getUsersWithNotificationPermission(houseId);
    //Phase 
    for (const userId of users) {
        console.log("userId" + userId);
        const user = await User.findByPk(userId);
        const alertsEnabled = user.alert_notifications_enabled;
        if (alertsEnabled === "false") {
            console.log(`⚠️ User ${userId} has disabled alerts.`);
            continue;
        }
        let title = "";
        let message = "";
        const house = House.findByPk(houseId);
        const houseName = house.house_name;
        if (cost >= threshold_cost * 0.8 && cost < threshold_cost) {
            title = `Warning: Electricity cost is nearing the threshold for ${houseName}`;
            message = `Current cost: ${cost}`;
            console.log(`⚠️ ${title}`);
        } else if (cost >= threshold_cost) {
            title = `Alert: Electricity cost has exceeded the threshold for ${houseName}`;
            message = `Current cost: ${cost}`;
            console.log(`❌ ${title}`);
        }

        if (title && message) {
            await redisClient.set(houseAlertSentKey, "true", "EX", 86400);

            await notificationService.createNotification({
                user_id: userId,
                type: "ALERT",
                title: title,
                message: message
            });

            await notificationQueue.add("check-cost-threshold", {
                userId,
                houseId,
                title,
                message,
                methods: ["PUSH"],
            });
        }
    }
    await redisClient.set(houseAlertSentKey, "true", "EX", 86400);
}

module.exports = { checkTelemetryBatchForAlerts, checkCostThreshold };
