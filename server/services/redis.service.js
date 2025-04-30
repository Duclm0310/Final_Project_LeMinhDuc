const redisClient = require("../config/redisClient");
const { Room, AlertThreshold, Device, RolePermission, Permission, ResourceSharing, CostThreshold, House, User  } = require("../models/index");
const { Op, Sequelize } = require("sequelize");
const devicetoken_service = require("../services/devicetoken_service");

const TTL = {
    ROOM_DEVICES: 3600,
    HOUSE_DEVICES: 3600,
    HOUSE_ROOMS: 7200,
    USER_THRESHOLD: 1800,
    DEVICE_NAME: 1800,
    DEVICE_TOKEN: 3600,
    USER_INFO: 3600,
    HOURLY_SUMMARY: 45000,
    TELEMETRY: 15,
    PERMISSION: 3600
};

async function updateDeviceThresholds(userId) {
    try {
        const devicePermissions = await ResourceSharing.findAll({
            where: {
                user_id: userId,
                resource_type: { [Op.in]: ["DEVICE", "ROOM", "HOUSE"] },
            },
        });

        const deviceIds = new Set();

        for (const sharing of devicePermissions) {
            if (sharing.resource_type === "DEVICE") {
                deviceIds.add(sharing.resource_id);
            } else if (sharing.resource_type === "ROOM") {
                const roomDevices = await redisClient.smembers(`room:${sharing.resource_id}:devices`);
                if (roomDevices && roomDevices.length > 0) {
                    roomDevices.forEach(deviceId => deviceIds.add(deviceId));
                } else {
                    const devices = await Device.findAll({ where: { room_id: sharing.resource_id } });
                    devices.forEach(d => deviceIds.add(d.device_id));
                }
            } else if (sharing.resource_type === "HOUSE") {
                const housedevices = await redisClient.smembers(`house:${sharing.resource_id}:devices`);
                if (housedevices && housedevices.length > 0) {
                    housedevices.forEach(d => deviceIds.add(d.device))
                } else {

                    const houseRooms = await redisClient.smembers(`house:${sharing.resource_id}:rooms`);
                    if (houseRooms && houseRooms.length > 0) {
                        for (const roomId of houseRooms) {
                            const roomDevices = await redisClient.smembers(`room:${roomId}:devices`);
                            if (roomDevices && roomDevices.length > 0) {
                                roomDevices.forEach(deviceId => deviceIds.add(deviceId));
                            } else {
                                const devices = await Device.findAll({ where: { room_id: roomId } });
                                devices.forEach(d => deviceIds.add(d.device_id));
                            }
                        }
                    } else {
                        const rooms = await Room.findAll({ where: { house_id: sharing.resource_id } });
                        for (const room of rooms) {
                            const devices = await Device.findAll({ where: { room_id: room.room_id } });
                            devices.forEach(d => deviceIds.add(d.device_id));
                        }
                    }
                }
            }
        }

        const uniqueDeviceIds = Array.from(deviceIds);
        if (uniqueDeviceIds.length === 0) return;

        const devices = await Device.findAll({
            where: { device_id: { [Op.in]: uniqueDeviceIds } },
        });
        const thresholds = await AlertThreshold.findAll({
            where: { device_id: { [Op.in]: uniqueDeviceIds } }
        });
        const deviceThresholds = {};
        const deviceNames = {};

        devices.forEach(d => {
            deviceNames[d.device_id] = d.device_name;
        });

        thresholds.forEach(th => {
            deviceThresholds[th.device_id] = {
                max_power: th.max_power,
                max_current: th.max_current,
                notify_via: th.notify_via
            };
        });
        await redisClient.set(`user:${userId}:thresholds`, JSON.stringify(deviceThresholds), 'EX', TTL.USER_THRESHOLD);
        await redisClient.set(`user:${userId}:device_names`, JSON.stringify(deviceNames), 'EX', TTL.DEVICE_NAME);

        console.log(`✅ Device thresholds updated in Redis for user ${userId}`);
        const usersWithAccess = await ResourceSharing.findAll({
            where: {
                resource_id: { [Op.in]: uniqueDeviceIds },
                resource_type: "DEVICE",
            },
        });
        const userIds = usersWithAccess.map(sharing => sharing.user_id);
        for (const managerId of userIds) {
            if (managerId !== userId) {
                await redisClient.set(`user:${managerId}:thresholds`, JSON.stringify(deviceThresholds), 'EX', TTL.USER_THRESHOLD);
                await redisClient.set(`user:${managerId}:device_names`, JSON.stringify(deviceNames), 'EX', TTL.DEVICE_NAME);
                console.log(`✅ Device thresholds updated in Redis for manager ${managerId}`);
            }
        }
    } catch (error) {
        console.error("❌ Error updating device thresholds in Redis:", error);
    }
}


// Lưu trữ ngưỡng chi phí cho một house
async function updateThresholdCostInRedis(houseId, thresholdCost) {
    try {
        const redisKey = `house:${houseId}:threshold_cost`;
        await redisClient.set(redisKey, thresholdCost, 'EX', 86400); // Đặt thời gian hết hạn là 1 ngày
        console.log(`✅ Updated threshold cost for house ${houseId} in Redis`);
    } catch (error) {
        console.error(`❌ Error updating threshold cost for house ${houseId}:`, error);
    }
}

async function getThresholdCostFromRedis(houseId) {
    try {
        const redisKey = `house:${houseId}:threshold_cost`;
        let thresholdCost = await redisClient.get(redisKey);

        if (thresholdCost) {
            console.log(`✅ Found threshold cost in Redis for house: ${houseId}`);
            return parseFloat(thresholdCost);
        }

        console.warn(`⚠️ No threshold cost found in Redis for house: ${houseId}. Fallback to Database...`);

        const thresholdRecord = await CostThreshold.findOne({ where: { house_id: houseId } });

        if (!thresholdRecord) {
            console.error(`❌ No threshold cost found in DB for house: ${houseId}`);
            return null;
        }

        thresholdCost = thresholdRecord.threshold_cost;

        await redisClient.set(redisKey, thresholdCost.toString(), "EX", 86400); // Cache 1 ngày
        return thresholdCost;
    } catch (error) {
        console.error(`❌ Error retrieving threshold cost for house ${houseId}:`, error);
        return null;
    }
}



async function getUsersWithNotificationPermission(houseId) {
    const permissionUsersKey = `house:${houseId}:notify_users`;
    let usersToNotify = await redisClient.get(permissionUsersKey);
    if (!usersToNotify) {
        const shares = await ResourceSharing.findAll({
            where: {
                resource_id: houseId,
                resource_type: "HOUSE"
            },
            include: [{
                model: RolePermission,
                as: 'RolePermissions',
                include: [{
                    model: Permission,
                    where: { permission_name: "receive_notification_house" },
                    attributes: []
                }],
                attributes: []
            }],
            raw: true
        });
        usersToNotify = [...new Set(shares.map(s => s.user_id))];
        await redisClient.set(permissionUsersKey, JSON.stringify(usersToNotify), 'EX', 1800); // Cache trong 30 phút
    } else {
        usersToNotify = JSON.parse(usersToNotify);
    }
    return usersToNotify;
}



async function saveUserInfoToRedis(userId, email, extra = {}) {
    try {
        await redisClient.sadd("logged_in_users:id", userId);
        await redisClient.hset(`user:${userId}`, {
            id: userId,
            email: email,
            loggedInAt: Date.now(),
            ...extra,
        });
        await redisClient.expire(`user:${userId}`, TTL.USER_INFO);
        console.log(`✅ User ${userId} info saved to Redis`);
    } catch (error) {
        console.error("❌ Error saving user data to Redis:", error);
    }
}


async function updateUserInfoInRedis(userId) {
    try {
        const userCacheKey = `user:${userId}`;
        let userData = await redisClient.hgetall(userCacheKey);

        if (userData && Object.keys(userData).length > 0) {
            console.log(`✅ User ${userId} info fetched from Redis`);
            return userData;
        }

        const user = await User.findByPk(userId);
        if (!user) {
            console.error(`❌ User with ID ${userId} not found in DB.`);
            return null;
        }

        await saveUserInfoToRedis(user.user_id, user.email, {
            name: user.name,
            password: user.password,
            is_verified: user.is_verified
        });

        userData = {
            id: user.id,
            email: user.email,
            name: user.name,
            password: user.password,
            is_verified: user.is_verified
        };
        await redisClient.hset(userCacheKey, userData);
        await redisClient.expire(userCacheKey, TTL.USER_INFO);

        console.log(`✅ User ${userId} info updated in Redis`);
        
        return userData;

    } catch (error) {
        console.error("❌ Error updating user data in Redis:", error);
        return null;
    }
}



async function saveTelemetryToRedis(deviceId, data) {
    try {
        const jsonData = JSON.stringify(data);
        await redisClient.setex(`telemetry:${deviceId}`, TTL.TELEMETRY, jsonData);
        console.log(`✅ Telemetry saved in Redis: telemetry:${deviceId}`);
    } catch (error) {
        console.error("❌ Error saving telemetry to Redis:", error);
    }
}



async function saveDeviceTokenToRedis(userId, tokenList) {
    try {
        if (Array.isArray(tokenList) && tokenList.length > 0) {
            await redisClient.set(`device_tokens:${userId}`, JSON.stringify(tokenList), 'EX', TTL.DEVICE_TOKEN);
        } else {
            console.warn(`⚠️ No device tokens to save for user ${userId}`);
        }
    } catch (error) {
        console.error("❌ Error saving device tokens to Redis:", error);
    }
}

async function updateInvalidToken(userId) {
    try {
        const tokenList = await devicetoken_service.getAllTokensByUser(userId);
        console.log("userid " + userId +  " tokenList" + tokenList);
        await saveDeviceTokenToRedis(userId, tokenList);
    } catch (error) {
        console.error("❌ Error updating invalid token:", error);
    }
}



//////

async function storeTelemetry(device_id, data) {
    try {
        const jsonData = JSON.stringify(data);
        await redisClient.set(`telemetry:${device_id}`, jsonData, 'EX', TTL.TELEMETRY);
        console.log(`✅ Đã lưu telemetry vào Redis: telemetry:${device_id}`);
    } catch (error) {
        console.error("❌ Lỗi khi lưu telemetry vào Redis:", error);
    }
}


//// update device,room,house cache 

async function buildRoomDevices(roomId) {
    try {
        const room = await Room.findByPk(roomId, {
            include: [{ association: "Devices" }]
        });
        if (!room) throw new Error("Room not found");

        const deviceIds = room.Devices.map(d => d.device_id);

        if (deviceIds.length > 0) {
            await redisClient.del(`room:${roomId}:devices`);
            await redisClient.sadd(`room:${roomId}:devices`, ...deviceIds);
            await redisClient.expire(`room:${roomId}:devices`, TTL.ROOM_DEVICES);
            console.log(`✅ Rebuilt room:${roomId}:devices`);
        }
    } catch (error) {
        console.error(`❌ Error building room:${roomId}:devices`, error);
    }
}

async function buildHouseDevices(houseId) {
    try {
        const rooms = await Room.findAll({ where: { house_id: houseId }, include: ["Devices"] });

        const deviceIds = rooms.flatMap(room => room.Devices.map(d => d.device_id));

        if (deviceIds.length > 0) {
            await redisClient.del(`house:${houseId}:devices`);
            await redisClient.sadd(`house:${houseId}:devices`, ...deviceIds);
            await redisClient.expire(`house:${houseId}:devices`, TTL.HOUSE_DEVICES);
            console.log(`✅ Rebuilt house:${houseId}:devices`);
        }
    } catch (error) {
        console.error(`❌ Error building house:${houseId}:devices`, error);
    }
}

async function buildHouseRooms(houseId) {
    try {
        const rooms = await Room.findAll({ where: { house_id: houseId }, attributes: ["room_id"] });
        const roomIds = rooms.map(r => r.room_id);

        if (roomIds.length > 0) {
            await redisClient.del(`house:${houseId}:rooms`);
            await redisClient.sadd(`house:${houseId}:rooms`, ...roomIds);
            await redisClient.expire(`house:${houseId}:rooms`, TTL.HOUSE_ROOMS);
            console.log(`✅ Rebuilt house:${houseId}:rooms`);
        }
    } catch (error) {
        console.error(`❌ Error building house:${houseId}:rooms`, error);
    }
}

async function rebuildHouseCache(houseId) {
    await buildHouseRooms(houseId);
    await buildHouseDevices(houseId);
}


async function updateDeviceCacheOnCreate(device) {
    try {
        const { room_id, device_id } = device;
        const room = await Room.findByPk(room_id);
        if (!room) throw new Error("Room not found");

        const house_id = room.house_id;

        await redisClient.sadd(`room:${room_id}:devices`, device_id);
        await redisClient.expire(`room:${room_id}:devices`, TTL.ROOM_DEVICES);

        await redisClient.sadd(`house:${house_id}:devices`, device_id);
        await redisClient.expire(`house:${house_id}:devices`, TTL.HOUSE_DEVICES);

        await redisClient.sadd(`house:${house_id}:rooms`, room_id);
        await redisClient.expire(`house:${house_id}:rooms`, TTL.HOUSE_ROOMS);

        console.log(`✅ Redis cache updated for device ${device_id}`);
    } catch (error) {
        console.error("Redis update failed:", error);
    }
}

async function moveDeviceToAnotherRoom(deviceId, newRoomId) {
    const device = await Device.findByPk(deviceId);
    if (!device) throw new Error("Device not found");

    const oldRoom = await Room.findByPk(device.room_id);
    const newRoom = await Room.findByPk(newRoomId);
    if (!oldRoom || !newRoom) throw new Error("Invalid rooms");

    const oldHouseId = oldRoom.house_id;
    const newHouseId = newRoom.house_id;

    device.room_id = newRoomId;
    await device.save();

    await redisClient.srem(`room:${oldRoom.room_id}:devices`, deviceId);
    await redisClient.sadd(`room:${newRoom.room_id}:devices`, deviceId);
    await redisClient.expire(`room:${newRoom.room_id}:devices`, TTL.ROOM_DEVICES);

    if (oldHouseId !== newHouseId) {
        await redisClient.srem(`house:${oldHouseId}:devices`, deviceId);
        await redisClient.sadd(`house:${newHouseId}:devices`, deviceId);
        await redisClient.expire(`house:${newHouseId}:devices`, TTL.HOUSE_DEVICES);
    }

    await redisClient.sadd(`house:${newHouseId}:rooms`, newRoom.room_id);
    await redisClient.expire(`house:${newHouseId}:rooms`, TTL.HOUSE_ROOMS);
}

async function deleteDeviceFromRedis(deviceId) {
    try {
        const device = await Device.findByPk(deviceId);
        if (!device) throw new Error("Device not found");

        const room = await Room.findByPk(device.room_id);
        if (!room) throw new Error("Room not found");

        const houseId = room.house_id;

        await redisClient.srem(`room:${room.room_id}:devices`, deviceId);
        await redisClient.srem(`house:${houseId}:devices`, deviceId);

        console.log(`✅ Removed device ${deviceId} from Redis`);
    } catch (error) {
        console.error("❌ Error deleting device from Redis:", error);
    }
}

async function addRoomToHouseInRedis(roomId, houseId) {
    try {
        await redisClient.sadd(`house:${houseId}:rooms`, roomId);
        await redisClient.expire(`house:${houseId}:rooms`, TTL.HOUSE_ROOMS);
        console.log(`✅ Room ${roomId} added to house ${houseId} in Redis`);
    } catch (error) {
        console.error("❌ Error adding room to Redis:", error);
    }
}


async function deleteRoomFromRedis(roomId) {
    try {
        const room = await Room.findByPk(roomId, { include: ["Devices"] });
        if (!room) throw new Error("Room not found");

        const houseId = room.house_id;

        const deviceIds = room.Devices.map(d => d.device_id);
        for (const deviceId of deviceIds) {
            await redisClient.srem(`room:${roomId}:devices`, deviceId);
            await redisClient.srem(`house:${houseId}:devices`, deviceId);
        }

        await redisClient.srem(`house:${houseId}:rooms`, roomId);

        console.log(`✅ Room ${roomId} and its devices removed from Redis`);
    } catch (error) {
        console.error("❌ Error deleting room from Redis:", error);
    }
}


async function deleteHouseFromRedis(houseId) {
    try {
        const keys = await redisClient.keys(`house:${houseId}:*`);
        if (keys.length > 0) {
            await redisClient.del(...keys);
            console.log(`✅ Deleted all Redis keys for house ${houseId}`);
        } else {
            console.log(`⚠️ No Redis keys found for house ${houseId}`);
        }
    } catch (error) {
        console.error("❌ Error deleting house from Redis:", error);
    }
}

////////////////////

async function setDeviceHourlySummary(deviceId, hourKey, data) {
    const key = `device:${deviceId}:${hourKey}`;
    await redisClient.set(key, JSON.stringify(data), 'EX', TTL.HOURLY_SUMMARY);
    console.log(`[Redis] ✅ Cached device hourly summary: ${key}`);
}

async function setRoomHourlySummary(roomId, hourKey, data) {
    const key = `room:${roomId}:${hourKey}`;
    await redisClient.set(key, JSON.stringify(data), 'EX', TTL.HOURLY_SUMMARY);
    console.log(`[Redis] ✅ Cached room hourly summary: ${key}`);
}

async function setHouseHourlySummary(houseId, hourKey, data) {
    const key = `house:${houseId}:${hourKey}`;
    await redisClient.set(key, JSON.stringify(data), 'EX', TTL.HOURLY_SUMMARY);
    console.log(`[Redis] ✅ Cached house hourly summary: ${key}`);
}

async function setDeviceDailySummary(deviceId, dateKey, data) {
    const redisKey = `device:${deviceId}:daily:${dateKey}`;
    await redisClient.set(redisKey, JSON.stringify(data), 'EX', 8 * 24 * 60 * 60); // 8 ngày
}

async function setRoomDailySummary(roomId, dateKey, data) {
    const redisKey = `room:${roomId}:daily:${dateKey}`;
    await redisClient.set(redisKey, JSON.stringify(data), 'EX', 8 * 24 * 60 * 60);
}

async function setHouseDailySummary(houseId, dateKey, data) {
    const redisKey = `house:${houseId}:daily:${dateKey}`;
    await redisClient.set(redisKey, JSON.stringify(data), 'EX', 8 * 24 * 60 * 60);
}


async function getSummaryFromRedis(key) {
    const result = await redisClient.get(key);
    return result ? JSON.parse(result) : null;
}


// permissions <-> user <-> resource
// Cache permission và role_id cho user với resource cụ thể
async function cacheUserPermissions(userId, resourceType, resourceId) {
    const sharing = await ResourceSharing.findOne({
        where: {
            user_id: userId,
            resource_type: resourceType,
            resource_id: resourceId,
        },
    });


    if (!sharing) return null;

    const roleId = sharing.role_id;

    const permissions = await RolePermission.findAll({
        where: { role_id: roleId },
        include: [{ model: Permission, attributes: ["permission_name"] }],
    });

    const permNames = permissions.map(p => p.Permission.permission_name);

    const permKey = `perm:${userId}:${resourceType}:${resourceId}`;
    const roleKey = `roles:${userId}:${resourceType}:${resourceId}`;

    await redisClient.set(permKey, JSON.stringify(permNames), "EX", TTL.PERMISSION);
    await redisClient.set(roleKey, roleId, "EX", TTL.PERMISSION);

    return permNames;
}

// Lấy permission từ Redis (nếu không có thì tự động cache lại)
async function getUserPermissions(userId, resourceType, resourceId) {
    const permKey = `perm:${userId}:${resourceType}:${resourceId}`;
    let permissionList = await redisClient.get(permKey);

    if (!permissionList) {
        permissionList = await cacheUserPermissions(userId, resourceType, resourceId);
        return permissionList;
    }

    return JSON.parse(permissionList);
}

// Xoá cache nếu cần
async function clearPermissionCache(userId, resourceType, resourceId) {
    await redisClient.del(`perm:${userId}:${resourceType}:${resourceId}`);
    await redisClient.del(`roles:${userId}:${resourceType}:${resourceId}`);
}


//////////////

const ACTIVE_DEVICES_CACHE_KEY = "device:active_devices";
const ACTIVE_DEVICES_CACHE_TTL = 300;
const ACTIVE_ROOMS_CACHE_KEY = "room:active_rooms";
const ACTIVE_HOUSES_CACHE_KEY = "house:active_houses";



async function updateActiveDevicesCache() {
    try {
        const devices = await Device.findAll({
            attributes: [[Sequelize.fn("DISTINCT", Sequelize.col("device_id")), "device_id"]],
            where: {
                status: "ON",
                is_active: true,
            },
            raw: true,
        });

        await redisClient.set(
            ACTIVE_DEVICES_CACHE_KEY,
            JSON.stringify(devices),
            "EX",
            ACTIVE_DEVICES_CACHE_TTL
        );
        console.log("[Cache] Đã cập nhật cache Active Devices");
        return devices;
    } catch (err) {
        console.error("[Cache] Lỗi khi cập nhật cache Active Devices:", err);
        throw err;
    }
}

/**
 * Lấy danh sách thiết bị active từ cache, nếu không có thì fallback DB và update cache
 */
async function getCachedActiveDevices() {
    try {
        const cached = await redisClient.get(ACTIVE_DEVICES_CACHE_KEY);

        if (cached) {
            console.log("[Cache] Get Active Devices List from Redis");
            return JSON.parse(cached);
        }

        console.log("[Cache] No cache, query from DB and update cache");
        const devices = await updateActiveDevicesCache();
        return devices;

    } catch (err) {
        console.error("[Cache]Redis error, fallback DB:", err);

        const devices = await await Device.findAll({
            attributes: [[Sequelize.fn("DISTINCT", Sequelize.col("device_id")), "device_id"]],
            where: {
                status: "ON",
                is_active: true,
            },
            raw: true,
        });
        return devices;
    }
}



async function getOrUpdateActiveRooms() {
    try {
        const cached = await redisClient.get(ACTIVE_ROOMS_CACHE_KEY);
        if (cached) {
            console.log("[Cache] Get Active Rooms List from Redis");
            return JSON.parse(cached);
        }

        console.log("[Cache] No cache, query from DB and update cache");
        const rooms = await Room.findAll({
            include: [
                {
                    model: Device,
                    where: {
                        status: "ON",
                        is_active: true,
                    },
                    attributes: ["device_id"],
                    required: true,
                },
            ],
        });

        await redisClient.set(
            ACTIVE_ROOMS_CACHE_KEY,
            JSON.stringify(rooms),
            'EX',
            ACTIVE_DEVICES_CACHE_TTL
        );

        return rooms;
    } catch (err) {
        const rooms = await Room.findAll({
            include: [
                {
                    model: Device,
                    where: {
                        status: "ON",
                        is_active: true,
                    },
                    attributes: ["device_id"],
                    required: true,
                },
            ],
        });
        return rooms;
    }
}

/**
 * Lấy danh sách House có thiết bị active trong phòng, cache Redis
 */
async function getOrUpdateActiveHouses() {
    try {
        const cached = await redisClient.get(ACTIVE_HOUSES_CACHE_KEY);
        if (cached) {
            console.log("[Cache]  Get Active Houses List from Redis");
            return JSON.parse(cached);
        }

        console.log("[Cache] No cache, query from DB and update cache");
        const houses = await House.findAll({
            include: [
                {
                    model: Room,
                    required: true,
                    include: [
                        {
                            model: Device,
                            where: {
                                status: "ON",
                                is_active: true,
                            },
                            attributes: ["device_id"],
                            required: true,
                        },
                    ],
                },
            ],
        });

        await redisClient.set(
            ACTIVE_HOUSES_CACHE_KEY,
            JSON.stringify(houses),
            "EX",
            ACTIVE_DEVICES_CACHE_TTL
        );

        console.log(`[Cache] cache ${houses.length} Active Houses`);
        return houses;
    } catch (err) {
        console.error("[Cache] Error Active Houses:", err);

        // Fallback lấy từ DB nếu Redis lỗi
        const houses = await House.findAll({
            include: [
                {
                    model: Room,
                    required: true,
                    include: [
                        {
                            model: Device,
                            where: {
                                status: "ON",
                                is_active: true,
                            },
                            attributes: ["device_id"],
                            required: true,
                        },
                    ],
                },
            ],
        });

        console.log(`[Cache] Fallback lấy ${houses.length} Active Houses từ DB`);
        return houses;
    }
}





module.exports = {
    updateDeviceThresholds,
    saveTelemetryToRedis,

    //
    saveUserInfoToRedis,
    updateUserInfoInRedis,
    saveDeviceTokenToRedis,
    updateInvalidToken,

    //
    storeTelemetry,
    updateThresholdCostInRedis,
    getThresholdCostFromRedis,
    getUsersWithNotificationPermission,

    //
    buildRoomDevices,
    rebuildHouseCache,
    //
    updateDeviceCacheOnCreate,
    moveDeviceToAnotherRoom,
    deleteDeviceFromRedis,
    addRoomToHouseInRedis,
    deleteRoomFromRedis,
    deleteHouseFromRedis,
    //
    setDeviceHourlySummary,
    setRoomHourlySummary,
    setHouseHourlySummary,
    setDeviceDailySummary,
    setRoomDailySummary,
    setHouseDailySummary,
    getSummaryFromRedis,
    //
    cacheUserPermissions,
    getUserPermissions,
    clearPermissionCache,
    //
    updateActiveDevicesCache,
    getCachedActiveDevices,
    getOrUpdateActiveRooms,
    getOrUpdateActiveHouses
};
