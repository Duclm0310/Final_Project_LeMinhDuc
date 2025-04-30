const House = require("../models/House");
const User = require("../models/User");
const jwt = require("jsonwebtoken");

exports.createHouse = async (req, res) => {
  try {
    const { house_name, house_address, owner_id } = req.body;

    const newHouse = new House({
      house_name,
      house_address,
      owner: owner_id,
    });

    await newHouse.save();

    res.status(201).json({ message: "House created successfully", house: newHouse });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

exports.getAllHouses = async (req, res) => {
  try {
    const houses = await House.find().populate("owner");
    res.status(200).json(houses);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

exports.getHouseById = async (req, res) => {
  try {
    const house = await House.findById(req.params.id).populate("owner");
    if (!house) return res.status(404).json({ message: "House not found" });
    res.status(200).json(house);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};