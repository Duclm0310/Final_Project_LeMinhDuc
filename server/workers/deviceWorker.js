const { Worker } = require("bullmq");
const { connection } = require("../queue");

const EnergyUsage = require("../models/mongodb/energy_usage.model");
const DeviceLog = require("../models/mongodb/device.log.model");
const DeviceLogService = require("../services/devicelog.service");

const deviceCheckWorker = new Worker(
    "deviceQueue",
    async (job) => {
        try {
            const { deviceId, fifteenMinutesAgo } = job.data;

            const latestTelemetry = await EnergyUsage.findOne(
                {
                    device_id: deviceId,
                    recorded_at: { $gte: fifteenMinutesAgo },
                },
                {},
                { sort: { recorded_at: -1 } }
            );

            if (!latestTelemetry) {
                console.log(`❗ Không có dữ liệu telemetry mới cho thiết bị ${deviceId}`);

                const lastLog = await DeviceLogService.getLastDeviceLogbyDeviceid(deviceId);

                if (!lastLog) {
                    console.log(`📥 Chưa có log nào, tạo log lỗi mới cho thiết bị ${deviceId}`);
                    await DeviceLog.create({
                        device_id: deviceId,
                        status: "error",
                        message: "Không có telemetry trong 15 phút qua",
                        recorded_at: new Date(),
                        resolved_at: new Date(),
                    });
                } else if (lastLog.status === "error") {
                    console.log(`⚠️ Đã có log lỗi gần đây, không tạo thêm.`);
                } else {
                    console.log(`🔁 Tạo log lỗi mới vì trạng thái log cũ không phải "error"`);
                    await DeviceLog.create({
                        device_id: deviceId,
                        status: "error",
                        message: "Không có telemetry trong 15 phút qua",
                        recorded_at: new Date(),
                        resolved_at: new Date(),
                    });
                }
            }
        } catch (error) {
            console.error(`🚨 Lỗi khi kiểm tra telemetry cho thiết bị ${job.data.deviceId}:`, error);
        }
    },
    { connection }
);

// Tùy chọn: bật listener cho debug nếu muốn
// deviceCheckWorker.on("completed", (job) => {
//     console.log(`✅ Job hoàn thành cho user ${job.data.userId}`);
// });

// deviceCheckWorker.on("failed", (job, err) => {
//     console.error(`❌ Job thất bại cho user ${job.data.userId}:`, err);
// });

console.log("🚀 Worker kiểm tra trạng thái thiết bị đang chạy...");

module.exports = deviceCheckWorker;
