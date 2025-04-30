const express = require("express");
const router = express.Router();
const deviceController = require("../controllers/device.controller");
const authMiddleware = require("../middlewares/authMiddlewares");
const { validateDevice } = require("../middlewares/validation");
const roleBasedAccessControl = require("../middlewares/rbacMiddlewares");
const { checkPermission } = require("../middlewares/checkPermissionMiddleware");

router.get(
    "/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = "DEVICE";
        req.requiredPermission = "read_device";
        next();
    },
    checkPermission,
    deviceController.getDeviceById
);

router.get("/", deviceController.getAllDevices);

router.post(
    "/create&active",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = "DEVICE";
        req.requiredPermission = "create_device";
        next();
    },
    checkPermission,
    deviceController.createDevice
);

router.post(
    "/",
    authMiddleware("access"), // Ensure this is called correctly
    (req, res, next) => {
        req.resourceType = "DEVICE";
        req.requiredPermission = "create_device";
        next();
    },
    checkPermission,
    deviceController.createDevice
);

// Turn device ON
router.put(
    "/status/on/:resource_id",
    authMiddleware("access"), // Ensure this is called correctly
    (req, res, next) => {
        req.resourceType = "DEVICE";
        req.requiredPermission = "read_device";
        next();
    },
    checkPermission,
    deviceController.turnDeviceOn
);

// Turn device OFF
router.put(
    "/status/off/:device_id",
    authMiddleware("access"), // Ensure this is called correctly
    deviceController.turnDeviceOff
);

// deactivateDevice
router.put(
    "/deactivate/:device_id",
    authMiddleware("access"), // Ensure this is called correctly
    deviceController.deactivateDevice
);

// activateDevice
router.put(
    "/activate/:device_id",
    authMiddleware("access"), // Ensure this is called correctly
    deviceController.activateDevice
);

// Update a device
router.put(
    "/:device_id",
    authMiddleware("access"), // Ensure this is called correctly
    deviceController.updateDevice
);

// Delete a device (protected route)
router.delete(
    "/:device_id",
    authMiddleware("access"), // Ensure this is called correctly
    deviceController.deleteDevice
);

router.put(
    "/move/:device_id/:new_room_id",
    authMiddleware("access"),
    (req, res, next) => {
      req.resourceType = "DEVICE";
      req.requiredPermission = "update_device";
      next();
    },
    checkPermission,
    deviceController.moveDevice
  );

  

module.exports = router;
