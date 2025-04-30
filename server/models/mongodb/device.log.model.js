const mongoose = require("mongoose");
const { type } = require("os");

const deviceLogSchema = new mongoose.Schema({
    device_id: {
        type: String, // UUID của thiết bị
        required: true,
        index: true,
    },
    status: {
        type: String, // "ON", "OFF", "ERROR", etc.
        required: true,
    },
    message: {
        type: String, 
        required: false,
    },
    recorded_at: {
        type: Date,
        default: Date.now,
        index: true, // Giúp truy vấn nhanh theo thời gian
    },
    resolved_at: {
        type : Date,
        required: false,
    }
}, { timestamps: true });

module.exports = mongoose.model("DeviceLog", deviceLogSchema);
