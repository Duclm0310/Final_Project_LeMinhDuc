const express = require("express");
const router = express.Router();
const userController = require("../controllers/UserController");

router.get("/", userController.getAllUser);
router.post("/signup", userController.signUp);
router.post("/signin", userController.signIn);
router.post("/phone", userController.signInWithPhoneNumber);

module.exports = router;
