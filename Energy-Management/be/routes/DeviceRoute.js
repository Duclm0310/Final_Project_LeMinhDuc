const express = require("express");
const router = express.Router();
const deviceController = require("../controllers/DeviceController");

router.get("/", deviceController.getAllDevices);
router.get("/qr/:deviceId", deviceController.getDeviceQR);
router.get("/:id", deviceController.getDeviceById);
router.post("/", deviceController.createDevice);
router.put("/:id", deviceController.updateDevice);
router.delete("/:id", deviceController.deleteDevice);

module.exports = router;
