const { CostThreshold } = require("../models/index");

exports.setCostThreshold = async (houseId, threshold_cost) => {
    if (isNaN(threshold_cost) || threshold_cost <= 0) {
        throw new Error("Invalid threshold cost value.");
    }

    const [threshold, created] = await CostThreshold.findOrCreate({
        where: { house_id: houseId },
        defaults: { threshold_cost },
    });

    if (!created) {
        await threshold.update({ threshold_cost });
    }

    return threshold;
};

exports.getCostThreshold = async (houseId) => {
    const threshold = await CostThreshold.findOne({ where: { house_id: houseId } });
    if (!threshold) {
        throw new Error("No threshold set for this house.");
    }
    return threshold;
};
