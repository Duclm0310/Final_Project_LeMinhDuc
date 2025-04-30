const express = require("express");
const router = express.Router();
const houseController = require("../controllers/HouseController");

router.post("/", houseController.createHouse);
router.get("/", houseController.getAllHouses);
router.get("/:id", houseController.getHouseById);

module.exports = router;