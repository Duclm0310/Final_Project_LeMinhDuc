const mongoose = require("mongoose");

const roomSchema = new mongoose.Schema({
  //   user_id: { type: String, required: false, allowNull: true },
  room_name: { type: String, required: true },
  room_description: { type: String, required: true },
  house_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "House",
    required: true,
  },
  room_residents: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: false,
  },
});

const Room = mongoose.model("Room", roomSchema);
module.exports = Room;
