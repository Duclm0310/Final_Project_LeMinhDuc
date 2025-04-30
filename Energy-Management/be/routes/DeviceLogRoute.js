const express = require("express");
const router = express.Router();
const deviceLogController = require("../controllers/DeviceLogController");

router.get("/", deviceLogController.getAllDeviceLogs);
// router.get("/:id", deviceLogController.getDeviceById);
router.post("/", deviceLogController.createDeviceLog);
router.put("/:id", deviceLogController.updateDeviceLog);
router.delete("/:id", deviceLogController.deleteDeviceLog);

module.exports = router;
