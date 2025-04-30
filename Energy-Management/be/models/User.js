const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  //   user_id: { type: String, required: false, allowNull: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  phone: { type: String, allowNull: true, defaultValue: "" },
  password: {type: String, allowNull: false},
  address: { type: String, required: true, default: "" },
  is_verified: { type: Boolean, default: false },
});

const User = mongoose.model("User", userSchema);
module.exports = User;
