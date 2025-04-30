const { AlertThreshold } = require("../models/index");

exports.getAllAlertThresholds = async () => {
    return await AlertThreshold.findAll();
};

exports.createAlertThreshold = async (data) => {
    return await AlertThreshold.create(data);
};

exports.updateAlertThreshold = async (id, data) => {
    const threshold = await AlertThreshold.findOne({ where: { device_id: deviceId } });
    if (!threshold) return null;

    await threshold.update(data);
    return threshold;
};

exports.deleteAlertThreshold = async (id) => {
    const threshold = await AlertThreshold.findOne({ where: { device_id: deviceId } });
    if (!threshold) return null;

    await threshold.destroy();
    return true;
};

exports.getThresholdByDeviceId = async (deviceId) => {
    return await AlertThreshold.findOne({ where: { device_id: deviceId } });
};
