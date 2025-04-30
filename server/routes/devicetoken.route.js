const express = require("express");
const router = express.Router();
const deviceTokenController = require("../controllers/deviceToken.controller");
const authMiddleware = require("../middlewares/authMiddlewares");


router.post("/", authMiddleware("access"), deviceTokenController.saveOrUpdate);

module.exports = router;