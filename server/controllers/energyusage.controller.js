const energyUsageService = require("../services/energyusage.service");
const deviceService = require("../services/device.service");
const { storeTelemetry } = require("../services/redis.service");
const { now } = require("mongoose");
const DeviceLogService = require("../services/devicelog.service")


class EnergyUsageController {
    async create(req, res) {
        try {
            const { device_id, voltage, current } = req.body;

            const device = await deviceService.getDeviceById(device_id);
            if (!device || !device.status || !device.is_active) {
                console.warn(`❌ Thiết bị ${device_id} không hợp lệ hoặc không hoạt động.`);
                return res.status(400).json({ status: 400, message: "Thiết bị không hợp lệ hoặc không hoạt động." });
            }

            let power = voltage * current;

            const timeDiffMinutes = 5;
            const energy_used = (power * timeDiffMinutes) / (60 * 1000);

            // let energy_used = 0;
            // const lastRecord = await energyUsageService.getLastUsageByDevice(device_id);
            // // console.log("lastRecord:", JSON.stringify(lastRecord, null, 2));
            // if (lastRecord) {
            //     const lastRecordedTime = new Date(lastRecord.recorded_at);
            //     const now = new Date();
            //     const timeDiffMinutes = (now - lastRecordedTime) / (1000 * 60); // ms -> phút

            //     if (!isNaN(timeDiffMinutes) && timeDiffMinutes > 0) {
            //         energy_used = (power * timeDiffMinutes) / (60 * 1000);
            //     } else {
            //         console.warn(`⚠️ timeDiffMinutes không hợp lệ: ${timeDiffMinutes}, đặt về 0.`);
            //         energy_used = 0;
            //     }
            // } 1 4 1

            const result = await energyUsageService.createUsage(req.body, energy_used, power);

            await Promise.all([
                DeviceLogService.createDeviceLog(device_id, "ON"),
                storeTelemetry(device_id, { power, current })
            ]);

            return res.status(result.status).json(result);
        } catch (error) {
            console.error("❌ Lỗi trong create:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getAll(req, res) {
        try {
            const result = await energyUsageService.getAllUsages();
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getAll:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getById(req, res) {
        try {
            const result = await energyUsageService.getUsageById(req.params.id);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getById:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async delete(req, res) {
        try {
            const result = await energyUsageService.deleteUsage(req.params.id);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in delete:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getByDeviceAndTime(req, res) {
        try {
            const { device_id } = req.params;
            const { start, end } = req.query;

            if (!start || !end) {
                return res.status(400).json({ status: 400, message: "Start and end dates are required" });
            }

            const result = await energyUsageService.getUsageByDeviceInTimeRange(device_id, start, end);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getByDeviceAndTime:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getDaily(req, res) {
        try {
            const { device_id } = req.params;
            const result = await energyUsageService.getDailyUsage(device_id);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getDaily:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getWeekly(req, res) {
        try {
            const { device_id } = req.params;
            const result = await energyUsageService.getWeeklyUsage(device_id);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getWeekly:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }

    async getMonthly(req, res) {
        try {
            const { device_id } = req.params;
            const result = await energyUsageService.getMonthlyUsage(device_id);
            return res.status(result.status).json(result);
        } catch (error) {
            console.error("Error in getMonthly:", error);
            return res.status(500).json({ status: 500, message: "Internal Server Error" });
        }
    }
}

module.exports = new EnergyUsageController();
