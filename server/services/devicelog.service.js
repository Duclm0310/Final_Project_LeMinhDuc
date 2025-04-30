const DeviceLog = require("../models/mongodb/device.log.model");

class DeviceLogService{

    async getLastDeviceLogbyDeviceid(deviceId){
        try {
            const log = await DeviceLog.findOne({ device_id: deviceId }) 
                .sort({ recorded_at: -1 }) 
                .exec();
    
            if (!log) {
                return null;
            }
            return log;
        } catch (error) {
            return null;
        }
    }

    async createDeviceLog(deviceId, status) {
        try {
            if (status === "ON") {
                const lastLog = await DeviceLog.findOne({
                    device_id: deviceId,
                    $or: [
                        { status: "ERROR" },
                        { status: "OFF" }
                    ]
                }).sort({ recorded_at: -1 });
    
                if (lastLog) {
                    if (lastLog.status === "ERROR") {
                        // console.log(`✅ Tìm thấy log lỗi trước đó cho thiết bị ${deviceId}, cập nhật resolve_at...`);
                        lastLog.resolved_at = new Date();
                        await lastLog.save()
                        .then(() => console.log(`✅ resolve_at updated for the error log of device ${deviceId}`))
                        .catch(err => console.error(`❌ Error while updating resolve_at:`, err));
                }
    
                    // console.log(`✅ Creating new log for device ${deviceId} with status "ON"`);
                } else {

                }
            }
            const newDeviceLog = new DeviceLog({
                device_id: deviceId,
                status: status,
                recorded_at: new Date(),
                resolved_at: null
            });
    
            await newDeviceLog.save()
            .then(() => console.log(`✅ New log created for device ${deviceId} with status ${status}`))
            .catch(err => console.error(`❌ Error while creating new log:`, err));
            return newDeviceLog;
        } catch (error) {
            console.error("❌ Error while creating DeviceLog:", error);
            return null;
        }
    }
    
    

}

module.exports = new DeviceLogService();
