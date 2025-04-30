// routes/summary.routes.js
const express = require("express");
const router = express.Router();
const summaryController = require("../controllers/summary.controller");

// Device (GET /summary/device/:deviceId?period=hourly&limit=24)
router.get("/device/:deviceId", summaryController.getDeviceSummary);

// Room (GET /summary/room/:roomId?period=daily&limit=7)
router.get("/room/:roomId", summaryController.getRoomSummary);

// House (GET /summary/house/:houseId?period=monthly&limit=6)
router.get("/house/:houseId", summaryController.getHouseSummary);

// GET electricity cost (GET /summary/electricity-cost/:level/:id?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD)
router.get("/electricity-cost/:level/:id", summaryController.getElectricityCost);

// GET /summary/energy-consumption/house/:houseId
router.get("/energy-consumption/house/:houseId", summaryController.getHouseEnergyConsumption);

router.get("/energy-consumption/room/:roomId", summaryController.getRoomEnergyConsumption);





module.exports = router;
