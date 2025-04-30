const Device = require("../models/Device");
const DeviceLog = require("../models/DeviceLog");
const QRCode = require("qrcode");
require("dotenv").config();
// Generating QR Code!
const IP = process.env.IP;
const PORT = process.env.PORT || 5000;
exports.getDeviceQR = async (req, res) => {
  console.log("Generating QR code!");
  try {
    console.log("Received request for QR:", req.params);
    const { deviceId } = req.params;
    if (!deviceId) {
      return res.status(400).send("<h1>Missing deviceId</h1>");
    }
    const qrData = `http://${IP}:${PORT}/devices/${deviceId}`; // Hoặc chỉnh là trả về id cho đơn giản hơn :D
    const qrImageBase64 = await QRCode.toDataURL(qrData);
    const qrImageBuffer = Buffer.from(qrImageBase64.split(",")[1], "base64");
    res.setHeader("Content-Type", "image/png");
    res.send(qrImageBuffer);
  } catch (error) {
    console.error("Error generating QR:", error);
    res.status(500).send("<h1>Failed to generate QR</h1>");
  }
};

exports.getAllDevices = async (req, res) => {
  try {
    const devices = await Device.find();
    res.status(200).json({ message: "success", data: devices });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDeviceById = async (req, res) => {
  try {
    const device = await Device.findById(req.params.id);
    res.status(200).json({ message: "success", data: device });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createDevice = async (req, res) => {
  try {
    const {
      device_name,
      device_type,
      status,
      isActive,
      description,
      user_id,
      room_id,
      createdAt,
    } = req.body;
    const newDevice = new Device({
      device_name,
      device_type,
      status,
      isActive,
      description,
      user_id,
      room_id,
      createdAt,
    });
    await newDevice.save();
    const deviceLog = new DeviceLog({ deviceID: newDevice._id, energyUsed: 0 });
    await deviceLog.save();
    res.status(201).json({ message: "success" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Cập nhật thiết bị theo ID
exports.updateDevice = async (req, res) => {
  try {
    const { id } = req.params;
    const updatedDevice = await Device.findByIdAndUpdate(id, req.body, {
      new: true,
    });
    res.status(200).json({ message: "Update successful" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Xóa thiết bị theo ID
exports.deleteDevice = async (req, res) => {
  try {
    const { id } = req.params;
    await Device.findByIdAndDelete(id);
    res.json({ message: "Device deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
