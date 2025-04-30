const mongoose = require("mongoose");

const deviceSchema = new mongoose.Schema({
  deviceID: { type: String, required: true },
  energyUsed: { type: Number, required: true },
  recordDate: { type: Date, default: Date.now },
});

deviceSchema.methods.GetEnergyUsage = () => this.energyUsed;

const DeviceLog = mongoose.model("DeviceLog", deviceSchema);
module.exports = DeviceLog;
