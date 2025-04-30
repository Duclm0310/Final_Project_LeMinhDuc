const mongoose = require("mongoose");

const houseSchema = new mongoose.Schema({
  //   user_id: { type: String, required: false, allowNull: true },
  house_name: { type: String, required: true },
  house_address: { type: String, required: true },
  owner_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: false,
    allowNull: true,
    defaultValue: "",
  },
});

const House = mongoose.model("House", houseSchema);
module.exports = House;
