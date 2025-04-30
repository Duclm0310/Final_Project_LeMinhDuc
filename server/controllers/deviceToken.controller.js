const deviceTokenService = require("../services/devicetoken_service");

const saveOrUpdate = async (req, res) => {
    try {
        const userId = req.body.payload.user_id; 
        const { device_token, device_type } = req.body;

        if (!device_token || !device_type) {
            return res.status(400).json({ message: "Missing device_token or device_type" });
        }

        await deviceTokenService.saveOrUpdate({ user_id: userId, device_token, device_type });

        return res.status(200).json({ message: "Device token saved or updated successfully" });
    } catch (err) {
        console.error("Error saving device token:", err);
        return res.status(500).json({ message: "Internal server error" });
    }
};

module.exports = {
    saveOrUpdate,
};
