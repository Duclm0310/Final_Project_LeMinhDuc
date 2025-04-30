const mongoose = require("mongoose");

const deviceSchema = new mongoose.Schema({
  // device_id: { type: String, required: false, allowNull: true },
  device_name: { type: String, required: true },
  device_type: { type: String, required: true },
  status: { type: String, allowNull: false, defaultValue: "off" },
  isActive: { type: Boolean, required: true, default: false },
  description: { type: String, default: "Smart Device" },
  user_id: { type: String, allowNull: true },
  room_id: { type: String, required: false, allowNull: true },
  createdAt: { type: Date, default: Date.now },
});

deviceSchema.methods.ActiveDevice = async () => {
  this.isActive = true;
  return await this.save();
};

deviceSchema.methods.DeactiveDevice = async () => {
  this.isActive = false;
  return await this.save();
};
deviceSchema.statics.getActiveDevices = () => {
  return this.find({ status: true });
};

const Device = mongoose.model("Device", deviceSchema);
module.exports = Device;
