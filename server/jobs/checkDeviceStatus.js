const { Sequelize } = require("sequelize");
const { Device } = require("../models/index");
const cron = require("node-cron");
const { deviceQueue, connection } = require("../queue");

async function addTelemetryJobs() {
    const fifteenMinutesAgo = new Date(Date.now() - 15 * 60 * 1000);
    const devices = await Device.findAll({
        attributes: [[Sequelize.fn("DISTINCT", Sequelize.col("device_id")), "device_id"]],
        where: {
            status: "ON",
            is_active: true
        },
        raw: true
    });

    console.log("Devices to process:", devices.length);

    for (const device of devices) {
        const deviceId = device.device_id;
        const existingJobs = await deviceQueue.getJobs(["delayed", "waiting"]);
    
        if (!existingJobs.some(job => job.data.deviceId === deviceId)) {
            await deviceQueue.add("checkTelemetry", { deviceId, fifteenMinutesAgo }, { removeOnComplete: true });
            console.log(`🕒 Đã thêm job kiểm tra telemetry cho thiết bị ${deviceId}`);
        }
    }
}


cron.schedule('* * * * *', () => {
    console.log("🔄 Checking and adding telemetry jobs...");
    addTelemetryJobs();
});
