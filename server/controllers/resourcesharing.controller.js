const resource_sharingService = require("../services/resource_sharing.service");

exports.createShareToken = async (req, res) => {
    try {
        const { resource_id, resource_type, role_id } = req.body;
        const ownerid  =  req.body.payload.user_id;

        const qrCode = await resource_sharingService.generateShareToken({ resource_id, resource_type, role_id, ownerid });
        res.json({ qrCode });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.handleScanShareToken = async (req, res) => {
    try {
        const { token } = req.body;
        const user_id = req.body.payload.user_id;

        const result = await resource_sharingService.consumeShareToken({ token, user_id });
        res.json(result);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

exports.getUsersOfHouse = async(req, res) => {
    const { houseId } = req.params;
  
    try {
      const users = await resource_sharingService.getSharingUsersOfHouse(houseId);
      res.json({ success: true, data: users });
    } catch (error) {
      console.error("[getUsersOfHouse]", error);
      res.status(500).json({ success: false, message: "Internal server error" });
    }
  };

  