const EnergyUsage = require("../models/mongodb/energy_usage.model");
const deviceService = require("./device.service");

class EnergyUsageService {
    async createUsage(data, energy_used, power) {
        try {
            const usage = new EnergyUsage({
                ...data,
                energy_used,
                power
            });
            await usage.save();
            return { status: 201, message: "Energy usage recorded successfully", data: usage };
        } catch (error) {
            return { status: 400, message: "Error recording energy usage", error: error.message };
        }
    }

    async getAllUsages() {
        try {
            const usages = await EnergyUsage.find().sort({ recorded_at: -1 });
            return { status: 200, message: "Energy usage records fetched", data: usages };
        } catch (error) {
            return { status: 500, message: "Error fetching records", error: error.message };
        }
    }

    async getUsageById(id) {
        try {
            const usage = await EnergyUsage.findById(id);
            if (!usage) {
                return { status: 404, message: "Energy usage record not found" };
            }
            return { status: 200, message: "Energy usage record found", data: usage };
        } catch (error) {
            return { status: 500, message: "Error fetching record", error: error.message };
        }
    }

    async deleteUsage(id) {
        try {
            const result = await EnergyUsage.findByIdAndDelete(id);
            if (!result) {
                return { status: 404, message: "Energy usage record not found" };
            }
            return { status: 200, message: "Energy usage record deleted successfully" };
        } catch (error) {
            return { status: 500, message: "Error deleting record", error: error.message };
        }
    }


    async getLastUsageByDevice(device_id) {
        try {
            return await EnergyUsage.findOne({ device_id })
                .sort({ recorded_at: -1 }) // Lấy bản ghi mới nhất
                .exec();
        } catch (error) {
            console.error("❌ Lỗi khi lấy bản ghi cuối:", error);
            return null;
        }
    }



    // Lấy dữ liệu telemetry của một thiết bị theo khoảng thời gian
    async getUsageByDeviceInTimeRange(deviceId, startDate, endDate) {
        try {
            const usages = await EnergyUsage.find({
                device_id: deviceId,
                recorded_at: { $gte: new Date(startDate), $lte: new Date(endDate) }
            }).sort({ recorded_at: -1 });

            return { status: 200, message: "Energy usage data fetched successfully", data: usages };
        } catch (error) {
            return { status: 500, message: "Error fetching telemetry data", error: error.message };
        }
    }


    async getDailyUsage(deviceId) {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(endDate.getDate() - 1); 
        return this.getUsageByDeviceInTimeRange(deviceId, startDate, endDate);
    }


    async getWeeklyUsage(deviceId) {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(endDate.getDate() - 7);
        return this.getUsageByDeviceInTimeRange(deviceId, startDate, endDate);
    }


    async getMonthlyUsage(deviceId) {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setMonth(endDate.getMonth() - 1);
        return this.getUsageByDeviceInTimeRange(deviceId, startDate, endDate);
    }

    
}

module.exports = new EnergyUsageService();
