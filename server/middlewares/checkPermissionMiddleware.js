const {
    ResourceSharing,
    RolePermission,
    UserRole,
    Permission,
    Room,
    Device,
    House,
    Role,
    User,
} = require("../models/index");
const { Op, Sequelize } = require("sequelize");
const redisClient = require("../config/redisClient");
const {
    BadRequestError,
    NotFoundError,
    UnauthorizedError,
    ValidationError,
    ForbiddenError,
    ConflictError,
} = require("../utils/errors/index");
const { getUserPermissions } = require("../services/redis.service");
const { required } = require("joi");

async function checkPermission(req, res, next) {
    try {
        const userId = req.body.payload.user_id || req.body.user_id;
        const resourceId = req.params.resource_id;
        const resourceType = req.resourceType;
        const requiredPermission = req.requiredPermission;

        if (!resourceId) {
            if (!requiredPermission.includes("create")) {
                throw new BadRequestError("Missing resource ID");
            }
        }

        if (!resourceType) {
            throw new BadRequestError("Missing resource type");
        }

        if (isAdmin(userId)) {
            return next();
        }

        const cacheKey = `access:${userId}:${resourceType}:${resourceId}:${requiredPermission}`;
        const cachedPermission = await redisClient.get(cacheKey);
        if (cachedPermission) {
            console.log("✅ Permission from cache:", cacheKey);
            return next();
        }

        if (resourceType === "USER") {
            if (userId === resourceId) {
                await redisClient.set(cacheKey, true, "EX", 3600);
                return next();
            }
            const sharing = await ResourceSharing.findOne({
                where: {
                    user_id: userId,
                    resource_type: "USER",
                    resource_id: resourceId,
                },
            });
            if (sharing) {
                await redisClient.set(cacheKey, true, "EX", 3600);
                return next();
            }
            throw new ForbiddenError("You can't access another user's profile");
        }

        const isOwner = await ResourceSharing.findOne({
            where: {
                owner_id: userId,
                resource_type: resourceType,
                resource_id: resourceId,
            },
        });

        if (isOwner) {
            await redisClient.set(cacheKey, true, "EX", 3600);
            return next();
        }

        if (["ROOM", "DEVICE"].includes(resourceType)) {
            let houseId;
            if (resourceType === "ROOM") {
                const room = await Room.findByPk(resourceId);
                if (!room) throw new NotFoundError("Room not found");
                houseId = room.house_id;
            } else if (resourceType === "DEVICE") {
                const device = await Device.findByPk(resourceId);
                if (!device) throw new NotFoundError("Device not found");
                const room = await Room.findByPk(device.room_id);
                if (!room) throw new NotFoundError("Room not found");
                houseId = room.house_id;

                const hasViaParent = await hasPermissionViaParentAssets(userId, device.device_id, requiredPermission);
                if (hasViaParent) {
                    await redisClient.set(cacheKey, true, "EX", 3600);
                    return next();
                }
            }

            const hasHouseAccess = await ResourceSharing.findOne({
                where: {
                    owner_id: userId,
                    resource_type: "HOUSE",
                    resource_id: houseId,
                },
            });
            if (hasHouseAccess) {
                await redisClient.set(cacheKey, true, "EX", 3600);
                return next();
            }
        }

        if (resourceType === "HOUSE") {
            const hasViaChildren = await hasPermissionViaChildAssets(userId, resourceId, requiredPermission);
            if (hasViaChildren) {
                await redisClient.set(cacheKey, true, "EX", 3600);
                return next();
            }
        }

        const permissions = await getUserPermissions(userId, resourceType, resourceId);
        const safePermissions = Array.isArray(permissions) ? permissions : [];

        if (safePermissions.includes(requiredPermission)) {
            await redisClient.set(cacheKey, true, "EX", 3600);
            return next();
        }

        return res.status(403).json({
            success: false,
            message: "You do not have permission to perform this action.",
            missing_permission: requiredPermission,
        });

    } catch (err) {
        console.error("❌ checkPermission error:", err);
        next(err);
    }
}

async function hasPermissionViaChildAssets(userId, houseId, requiredPermission) {
    let roomIds = await redisClient.smembers(`house:${houseId}:rooms`);
    let deviceIds = await redisClient.smembers(`house:${houseId}:devices`);

    if (!roomIds.length || !deviceIds.length) {
        console.log("🔁 Redis cache thiếu, fallback DB và rebuild...");

        const rooms = await Room.findAll({ where: { house_id: houseId } });
        roomIds = rooms.map(r => r.room_id);

        const devices = await Device.findAll({
            where: {
                room_id: roomIds.length ? roomIds : undefined,
            },
        });
        deviceIds = devices.map(d => d.device_id);

        await rebuildHouseCache(houseId);
        for (const room of rooms) {
            await buildRoomDevices(room.room_id);
        }
    }
    const resources = [
        ...roomIds.map(id => ({ type: "ROOM", id })),
        ...deviceIds.map(id => ({ type: "DEVICE", id })),
    ];

    for (const roomId of roomIds) {
        const roomPermissions = await getUserPermissions(userId, "ROOM", roomId);
        if (Array.isArray(roomPermissions) && roomPermissions.includes(requiredPermission)) {
            return true; // ✅ Có quyền ở ROOM
        }
    }
    
    for (const deviceId of deviceIds) {
        const devicePermissions = await getUserPermissions(userId, "DEVICE", deviceId);
        if (Array.isArray(devicePermissions) && devicePermissions.includes(requiredPermission)) {
            return true; // ✅ Có quyền ở DEVICE
        }
    }
    return false; 
}


async function hasPermissionViaParentAssets(userId, deviceId, requiredPermission) {
    const device = await Device.findByPk(deviceId);
    if (!device) return false;

    const room = await Room.findByPk(device.room_id);
    if (!room) return false;

    const roomId = room.room_id;
    const houseId = room.house_id;

    const resourcePairs = [
        { type: "ROOM", id: roomId },
        { type: "HOUSE", id: houseId },
    ];

    for (const { type, id } of resourcePairs) {
        const perms = await getUserPermissions(userId, type, id);
        if (Array.isArray(perms) && perms.includes(requiredPermission)) {
            return true;
        }
    }

    return false;
}

function withPermission(resourceType, permission) {
    return (req, res, next) => {
        req.resourceType = resourceType;
        req.requiredPermission = permission;
        next();
    }
}

async function isAdmin(userId) {
    const userRole = await UserRole.findOne({
        where: {
            user_id: userId,
            role_id: "6384685f-faec-46b4-b78a-b40d101e45bc"
        }
    });

    if (userRole !== null) {
        console.log("USER IS ADMIN", userRole);
        return true;
    }
    return false;
}

module.exports = { checkPermission, withPermission };