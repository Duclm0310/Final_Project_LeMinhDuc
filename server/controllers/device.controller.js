const deviceService = require("../services/device.service");
const DeviceLogService = require("../services/devicelog.service");
const {
    updateDeviceCacheOnCreate,
    moveDeviceToAnotherRoom,
    deleteDeviceFromRedis,
} = require("../services/redis.service");

class DeviceController {
    constructor(deviceService) {
        this.deviceService = deviceService;
    }

    async createDevice(req, res) {
        try {
            const device = await deviceService.createDevice(req.body);
            await updateDeviceCacheOnCreate(device);
            res.status(201).json(device);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getDeviceById(req, res) {
        try {
            const device = await deviceService.getDeviceById(req.params.resource_id);
            if (device) {
                res.status(200).json(device);
            } else {
                res.status(404).json({ message: "Device not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAllDevices(req, res) {
        try {
            const devices = await deviceService.getAllDevices();
            res.status(200).json(devices);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getDevicesByRoomId(req, res) {
        try {
            const devices = await deviceService.getDevicesByRoomId({
                room: req.params.device_id,
            });
            res.status(200).json(devices);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async updateDevice(req, res) {
        try {
            const device = await deviceService.updateDevice(
                req.params.device_id,
                req.body
            );
            if (device) {
                res.status(200).json(device);
                await updateDeviceCacheOnCreate(device);
            } else {
                res.status(404).json({ message: "Device not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async turnDeviceOn(req, res) {
        try {
            const deviceId = req.params.device_id;
            const updatedDevice = await deviceService.turnOnDevice(deviceId);
            if(updatedDevice) await DeviceLogService.createDeviceLog(deviceId, "ON");
            res.status(200).json(updatedDevice);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async turnDeviceOff(req, res) {
        try {
            const deviceId = req.params.device_id;
            const updatedDevice = await deviceService.turnOffDevice(deviceId);
            if(updatedDevice) await DeviceLogService.createDeviceLog(deviceId, "OFF");
            res.status(200).json(updatedDevice);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteDevice(req, res) {
        try {
            const device = await deviceService.deleteDevice(req.params.device_id);
            if (device) {
                res.status(200).json({
                    message: "Device deleted successfully",
                });
                deleteDeviceFromRedis(req.params.device_id);
            } else {
                res.status(404).json({ message: "Device not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteAllDevices(req, res) {
        try {
            const result = await deviceService.deleteAllDevices();
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deactivateDevice(req, res) {
        try {
            const result = await deviceService.deactivateDevice(req.params.device_id);
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async activateDevice(req, res) {
        try {
            const result = await deviceService.activateDevice(req.params.device_id);
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async moveDevice(req, res) {
        const { device_id, new_room_id } = req.params;

        try {
            const result = await deviceService.moveDeviceToRoom(device_id, new_room_id);
            res.status(200).json({ message: "✅ Device moved successfully", result });
        } catch (error) {
            console.error("❌ Error moving device:", error);
            res.status(500).json({ error: error.message });
        }
    }



}
module.exports = new DeviceController(deviceService);
