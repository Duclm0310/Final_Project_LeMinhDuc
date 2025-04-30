const BlacklistToken = require("../models/mongodb/blacklisttoken.model");

class TokenService {
    static async addToBlacklist(token) {
        try {
            await BlacklistToken.create({ token });
            return { success: true };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    static async isTokenBlacklisted(token) {
        const tokenExists = await BlacklistToken.findOne({ token });
        return !!tokenExists;
    }
}

module.exports = TokenService;
