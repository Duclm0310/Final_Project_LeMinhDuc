const costthresholdService = require("../services/costthreshold.service");
const {updateThresholdCostInRedis} = require("../services/redis.service");

exports.setCostThreshold = async (req, res) => {
    const { houseId } = req.params;
    const { threshold_cost } = req.body;  
    try {
        const result = await costthresholdService.setCostThreshold(houseId, threshold_cost);
        await updateThresholdCostInRedis(houseId, threshold_cost);
        res.json({ success: true, result });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error" });
    }
};

exports.getCostThreshold = async (req, res) => {
    const { houseId } = req.params;
    try {
        const result = await costthresholdService.getCostThreshold(houseId);
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Server error" });
    }
};
