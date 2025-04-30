const User = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

//TODO: add login with phone number and handle logic for create account with phone number!
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.address,
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

encryptPassword = async (password) => {
  const saltRounds = 10;
  const hashedPassword = await bcrypt.hash(password, saltRounds);
  return hashedPassword;
};

verifyPassword = async (inputPassword, storedHashedPassword) => {
  if (!inputPassword || !storedHashedPassword) {
    console.log("Invalid password input or stored password missing!");
    return false;
  }
  return await bcrypt.compare(inputPassword, storedHashedPassword);
};

exports.signUp = async (req, res) => {
  try {
    const { name, email, password, phone, address, is_verified } = req.body;
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists!" });
    }

    const encryptPass = await encryptPassword(password);
    const newUser = new User({
      name,
      email,
      phone,
      password: encryptPass,
      address,
      is_verified,
    });
    await newUser.save();
    const token = generateToken(newUser);
    res.status(200).json({ message: "success", token: token });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

exports.signInWithPhoneNumber = async (req, res) => {
  try {
    const { phone } = req.body;
    const foundUser = await User.findOne({ phone });
    if (!foundUser) return res.status(401).json({ message: "user not found!" });
    const token = generateToken(foundUser);
    res.status(200).json({ message: "verified", token: token });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

exports.signIn = async (req, res) => {
  try {
    const { email, password } = req.body;
    const foundUser = await User.findOne({ email });
    // console.log(`Found user: ${foundUser.email}`);
    if (!email || !password)
      return res.status(400).json({ message: "Missing email or password!" });

    if (!foundUser) return res.status(401).json({ message: "user not found!" });
    const isCorrectData = await verifyPassword(password, foundUser.password);
    //console.log(`Password verify status: ${isCorrectData}`);

    if (!isCorrectData)
      return res.status(401).json({ message: "incorrect password!" });
    const token = generateToken(foundUser);
    res.status(200).json({ message: "verified!", token: token });
  } catch (e) {
    res.status(400).json({ message: e.message });
  }
};

exports.getAllUser = async (req, res) => {
  try {
    const users = await User.find();
    res.status(200).json({ message: "success", data: users });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};
