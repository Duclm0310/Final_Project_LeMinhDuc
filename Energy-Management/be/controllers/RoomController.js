const Room = require("../models/Room");
const House = require("../models/House");
const User = require("../models/User");

exports.createRoom = async (req, res) => {
  try {
    const { room_name, room_description, house_id, resident_id } = req.body;

    const newRoom = new Room({
      room_name,
      room_description,
      house: house_id,
      resident: resident_id,
    });

    await newRoom.save();

    res.status(201).json({ message: "Room created successfully", room: newRoom });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

exports.getAllRooms = async (req, res) => {
  try {
    const rooms = await Room.find().populate("house").populate("resident");
    res.status(200).json(rooms);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

exports.getRoomById = async (req, res) => {
  try {
    const room = await Room.findById(req.params.id).populate("house").populate("resident");
    if (!room) return res.status(404).json({ message: "Room not found" });
    res.status(200).json(room);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};
