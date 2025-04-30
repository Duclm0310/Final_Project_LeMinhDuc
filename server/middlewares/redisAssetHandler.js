const redisService = require("../services/redis.service"); 

module.exports = {
    updateThresholdsMiddleware: async (req, res, next) => {
        const userId = req.user?.id;
        if (userId) await redisService.updateDeviceThresholds(userId);
        next();
    },

    storeTelemetryMiddleware: async (req, res, next) => {
        const { deviceId, data } = req.body;
        if (deviceId && data) {
            await redisService.storeTelemetry(deviceId, data);
        }
        next();
    },

    syncDeviceOnCreate: async (req, res, next) => {
        const device = req.body;
        await redisService.updateDeviceCacheOnCreate(device);
        next();
    },

    syncDeviceOnUpdateRoom: async (req, res, next) => {
        const { id } = req.params;
        const { newRoomId } = req.body;
        await redisService.moveDeviceToAnotherRoom(id, newRoomId);
        next();
    },

    syncDeviceOnDelete: async (req, res, next) => {
        const { id } = req.params;
        await redisService.deleteDeviceFromRedis(id);
        next();
    },

    syncRoomOnCreate: async (req, res, next) => {
        const { room_id, house_id } = req.body;
        await redisService.addRoomToHouseInRedis(room_id, house_id);
        next();
    },

    syncRoomOnDelete: async (req, res, next) => {
        const { id } = req.params;
        await redisService.deleteRoomFromRedis(id);
        next();
    },

    syncHouseOnDelete: async (req, res, next) => {
        const { id } = req.params;
        await redisService.deleteHouseFromRedis(id);
        next();
    }
};
