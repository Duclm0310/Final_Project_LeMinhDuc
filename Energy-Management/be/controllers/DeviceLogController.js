const DeviceLog = require("../models/DeviceLog");

// Lấy danh sách tất cả thiết bị
exports.getAllDeviceLogs = async (req, res) => {
  try {
    const logs = await DeviceLog.find();
    res.status(200).json({ message: "success", data: logs });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Thêm thiết bị mới
exports.createDeviceLog = async (req, res) => {
  try {
    const { deviceID, energyUsed, recordDate } = req.body;
    const newLog = new DeviceLog({ deviceID, energyUsed, recordDate });
    await newLog.save();
    res.status(201).json({ message: "success", data: newLog });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Cập nhật thiết bị theo ID
exports.updateDeviceLog = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedDevice = await Device.findByIdAndUpdate(id, req.body, {
      new: true,
    });
    res.json({ message: "update successful" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Xóa thiết bị theo ID
exports.deleteDeviceLog = async (req, res) => {
  try {
    const { id } = req.params;
    await Device.findByIdAndDelete(id);
    res.json({ message: "Device deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
