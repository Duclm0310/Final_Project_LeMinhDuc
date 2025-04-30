const alertThresholdService = require("../services/alertthreshold.service");
const {updateDeviceThresholds} = require("../services/redis.service");

exports.getAllAlertThresholds = async (req, res) => {
    try {
        const alertThresholds = await alertThresholdService.getAllAlertThresholds();
        res.status(200).json({ success: true, data: alertThresholds });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.createAlertThreshold = async (req, res) => {
    try {
        const deviceId = req.params.resource_id;
        const existing = await alertThresholdService.getThresholdByDeviceId(deviceId);
        if (existing) {
            return res.status(400).json({ success: false, message: "Threshold for this device already exists" });
        }

        const newThreshold = await alertThresholdService.createAlertThreshold({
            ...req.body,
            device_id: deviceId,
            user_id: req.body.payload.user_id,
        });

        await updateDeviceThresholds(req.body.payload.user_id)

        res.status(201).json({ success: true, data: newThreshold });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

exports.updateAlertThreshold = async (req, res) => {
    try {
        const deviceId = req.params.device_id;
        const updated = await alertThresholdService.updateAlertThreshold(deviceId, req.body);
        if (!updated) {
            return res.status(404).json({ success: false, message: "Threshold not found" });
        }
        await updateDeviceThresholds(req.body.payload.user_id)
        res.status(200).json({ success: true, data: updated });
    } catch (error) {
        res.status(400).json({ success: false, message: error.message });
    }
};

exports.deleteAlertThreshold = async (req, res) => {
    try {
        const deviceId = req.params.resource_id;
        const deleted = await alertThresholdService.deleteAlertThreshold(deviceId);
        if (!deleted) {
            return res.status(404).json({ success: false, message: "Threshold not found" });
        }
        await updateDeviceThresholds(req.body.payload.user_id)
        res.status(200).json({ success: true, message: "Deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getThresholdByDeviceId = async (req, res) => {
    try {
        const threshold = await alertThresholdService.getThresholdByDeviceId(req.params.resource_id);
        if (!threshold) {
            return res.status(404).json({ success: false, message: "Threshold for this device not found" });
        }
        res.status(200).json({ success: true, data: threshold });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};