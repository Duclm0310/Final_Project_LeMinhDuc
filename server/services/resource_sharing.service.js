const { v4: uuidv4 } = require("uuid");
const QRCode = require("qrcode");
const redisClient = require("../config/redisClient");
const { Op } = require("sequelize");
const { ResourceSharing, Role ,User } = require("../models/index");


const TOKEN_EXPIRY_SECONDS = 600;

exports.generateShareToken = async ({ resource_id, resource_type, role_id, owner_id }) => {
    const token = uuidv4();
    const payload = { resource_id, resource_type, role_id, owner_id };

    await redisClient.set(`share_token:${token}`, JSON.stringify(payload), 'EX', 600);
    const qrData = JSON.stringify({ token });
    const qrCode = await QRCode.toDataURL(qrData);
    const qrImageBuffer = Buffer.from(qrCode.split(",")[1], "base64");
    return qrImageBuffer;
};

exports.consumeShareToken = async ({ token, user_id }) => {
    try {
        const redisKey = `share_token:${token}`;
        const data = await redisClient.get(redisKey);
        if (!data) {
            throw new Error("Token is invalid or expired");
        }
        const { resource_id, resource_type, role_id, owner_id } = JSON.parse(data);

        const managerRole = await Role.findOne({
            where: { role_name: "MANAGER" }
        });

        if (!managerRole) {
            throw new NotFoundError("Manager role not found");
        }

        const existingResourceSharing = await ResourceSharing.findOne({
            where: {
                user_id: user_id,
                resource_id: resource_id,
                resource_type: resource_type
            }
        });

        if (existingResourceSharing) {
            if (existingResourceSharing.role_id !== role_id) {
                existingResourceSharing.role_id = role_id;
                await existingResourceSharing.save();
                console.log(`Updated role for user ${user_id} in resource ${resource_id}`);
            }
            return {
                status: "Success",
                message: "Resource role updated successfully"
            };
        }
        if (String(role_id) === String(managerRole.id)) {
            await ResourceSharing.create({
                owner_id: owner_id,
                user_id: user_id,
                role_id: role_id,
                resource_id: resource_id,
                resource_type: "HOUSE",
            });
        } else {
            await ResourceSharing.create({
                owner_id: owner_id,
                user_id: user_id,
                role_id: role_id,
                resource_id: resource_id,
                resource_type: resource_type,
            });
        }
        await updateDeviceThresholds(user_id);
        await redisClient.del(redisKey);

        return {
            status: "Success",
            message: "Successfully shared resource and updated user role and thresholds",
        };
    } catch (err) {
        console.error("Error sharing resource:", err);
        throw err;
    }
};


exports.getSharingUsersOfHouse = async (houseId) => {
    let roomIds = await redisClient.smembers(`house:${houseId}:rooms`) || [];
    console.log('[INFO] roomIds:', roomIds);
    let deviceIds = [];
    for (const roomId of roomIds) {
      const devices = await redisClient.smembers(`room:${roomId}:devices`);
      if (devices) {
        deviceIds = deviceIds.concat(devices);
      }
    }

    const assetIds = [
      { type: 'HOUSE', ids: [houseId] },
      { type: 'ROOM', ids: roomIds },
      { type: 'DEVICE', ids: deviceIds },
    ];
  
    const resourceWhere = [];
    for (const asset of assetIds) {
      if (asset.ids.length > 0) {
        resourceWhere.push({
          resource_type: asset.type,
          resource_id: { [Op.in]: asset.ids }
        });
      }
    }

    const sharings = await ResourceSharing.findAll({
      where: {
        [Op.or]: resourceWhere
      },
      include: [
        {
          model: User,
          as: 'User',
          attributes: ['user_id', 'username', 'email'],
        },
        {
          model: Role,
          as: 'Role',
          attributes: ['role_name'],
        },
      ],
    });
    sharings.forEach((s, i) => {
      console.log(`[DEBUG] Sharing ${i}:`, {
        user_id: s.user_id,
        username: s.User?.username,
        email: s.User?.email,
        role_name: s.Role?.role_name,
        resource_type: s.resource_type,
        resource_id: s.resource_id,
      });
    });
  
    // 5. Map ra kết quả gọn gàng
    const results = sharings.map(s => ({
      user_id: s.user_id,
      username: s.User?.username || s.User?.email || 'Unknown',
      role_name: s.Role?.role_name || '',
      resource_type: s.resource_type,
      resource_id: s.resource_id,
    }));
    return results;
  };
  