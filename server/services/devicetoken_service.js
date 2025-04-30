const {DeviceToken} = require('../models/index');
const { sequelize } = require("../config.js");
const {saveDeviceTokenToRedis} = require("../services/redis.service.js");


class DeviceTokenService {

    async saveDeviceToken(userId, token, deviceType) {
        try {

            const existingToken = await DeviceToken.findOne({ where: { device_token: token } });

            if (existingToken) {

                if (existingToken.user_id !== userId) {
                    await updateUserIdByToken(token, userId);
                    console.log('✅ Device token updated with new user_id.');
                }
                console.log('✅ Device token already exists, no need to save again.');
                return;
            }

            await DeviceToken.create({
                user_id: userId,
                device_token: token,
                device_type: deviceType
            });

            console.log('✅ New device token has been saved.');
        } catch (error) {
            console.error('❌ Error while saving device token:', error);
        }
    }

    async getAllTokensByUser(userId) {
        try {
            const tokens = await DeviceToken.findAll({
                where: { user_id: userId },
                attributes: ["device_token", "device_type"]
            });

            const tokenList = tokens.map(t => ({
                token: t.device_token,
                type: t.device_type
            }));

            console.log(`✅ Found ${tokens.length} token(s) for user ${userId}`);
            return tokenList;
        } catch (error) {
            console.error("❌ Error while fetching device tokens:", error);
            throw error;
        }
    }



    async removeDeviceToken(token) {
        try {
            const deleted = await DeviceToken.destroy({ where: { device_token: token } });

            if (deleted) {
                console.log(`✅ Token deleted: ${token}`);
            } else {
                console.log(`⚠️ Token not found: ${token}`);
            }
        } catch (error) {
            console.error("❌ Error while deleting device token:", error);
            throw error;
        }
    }

    async updateUserIdByToken(token, userId) {
        try {
            const tokenRecord = await DeviceToken.findOne({ where: { device_token: token } });

            if (!tokenRecord) {
                console.log(`⚠️ Token not found: ${token}`);
                return null;
            }
            await tokenRecord.update({ user_id: userId });
            console.log(`✅ Updated user_id ${userId} for token: ${token}`);
            return tokenRecord;
        } catch (error) {
            console.error("❌ Error while updating user_id for device token:", error);
            throw error;
        }
    }

    async saveOrUpdate ({ user_id, device_token, device_type }) {
        const existing = await DeviceToken.findOne({ where: { device_token } });
    
        if (existing) {
            if (existing.user_id !== user_id) {
                await existing.destroy();
            } else {
                // Cập nhật device_type nếu cần
                if (existing.device_type !== device_type) {
                    existing.device_type = device_type;
                    await existing.save();
                }
                return;
            }
        }

        // Thêm mới
        const newDevicetoken = await DeviceToken.create({ user_id, device_token, device_type });
        await saveDeviceTokenToRedis(user_id, device_token)
    };
    

}

module.exports = new DeviceTokenService();
