const { Device, ResourceSharing,Room } = require("../models/index");
const { sequelize } = require("../models/index");
const{moveDeviceToAnotherRoom} = require("../services/redis.service");
// const { where } = require("../models/mongodb/blacklisttoken.model");

class DeviceService {
    async createDevice(deviceData) {
        return await Device.create(deviceData);
    }

    async getDeviceById(device_id) {
        return await Device.findByPk(device_id);
    }

    async getDeviceByName(deviceName) {
        return await Device.find({ where: { deviceName: deviceName } });
    }

    async getAllDevices() {
        try {
            const devices = await Device.findAll();
            return devices;
        } catch (error) {
            throw new Error(`Error fetching devices: ${error.message}`);
        }
    }

    async getDevicesByRoomId(roomId) {
        return await Device.findAll({ where: { roomId: roomId } });
    }

    async updateDevice(device_id, updateData) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        return await device.update(updateData);
    }

    async deleteDevice(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        await device.destroy();
        return true;
    }

    async deleteAllDevices() {
        return await Device.destroy({ where: {}, truncate: true });
    }


    // Check if device is active
    async checkDeviceActive(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        return device.isActive;
    }


    // Deactivate a device
    async deactivateDevice(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        device.update({ is_active: false });
        await device.save();
        return device;
    }

    // Activate a device
    async activateDevice(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        device.update({ is_active: true });
        await device.save();
        return device;
    }

    async turnOnDevice(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        device.update({ status: "ON" });
        await device.save();
        return device;
    }

    async turnOffDevice(device_id) {
        const device = await Device.findByPk(device_id);
        if (!device) {
            throw new Error("Device not found");
        }
        device.update({ status: "OFF" });
        await device.save();
        return device;
    }

      async getHouseidfromDeviceinResourceSharing(userId){
          const deviceIds = await ResourceSharing.findAll({
                     where: {
                         user_id: userId,
                         resource_type: 'DEVICE',
                     },
                     attributes: ['resource_id'],
                     raw: true,
                 });
                 
                 const deviceIdsOnly = deviceIds.map(r => r.resource_id);
                 
                 const houseIdsFromDevice = await Room.findAll({
                     include: {
                         model: Device,
                         where: {
                             device_id: deviceIdsOnly
                         },
                         attributes: [],
                         required: true,
                     },
                     attributes: ['house_id'],
                     group: ['house_id'],
                     raw: true,
                 });
                return houseIdsFromDevice;
       }



       async moveDeviceToRoom(deviceId, newRoomId) {
        const device = await Device.findByPk(deviceId);
        const newRoom = await Room.findByPk(newRoomId);
    
        if (!device || !newRoom) {
          throw new Error("Device or new room not found");
        }
    
        const oldRoomId = device.room_id;
        device.room_id = newRoomId;
        await device.save();
    
        await moveDeviceToAnotherRoom(deviceId, newRoomId);
    
        return {
          deviceId,
          oldRoomId,
          newRoomId,
        };
      }


}

module.exports = new DeviceService();
