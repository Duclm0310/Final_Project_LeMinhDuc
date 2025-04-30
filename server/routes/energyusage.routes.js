const express = require("express");
const router = express.Router();
const energyUsageController = require("../controllers/energyusage.controller");

router.post("/", energyUsageController.create);
router.get("/", energyUsageController.getAll);
router.get("/:id", energyUsageController.getById);
router.delete("/:id", energyUsageController.delete);


router.get("/device/:device_id/range", energyUsageController.getByDeviceAndTime);

router.get("/device/:device_id/daily", energyUsageController.getDaily);

router.get("/device/:device_id/weekly", energyUsageController.getWeekly);

router.get("/device/:device_id/monthly", energyUsageController.getMonthly);

module.exports = router;
