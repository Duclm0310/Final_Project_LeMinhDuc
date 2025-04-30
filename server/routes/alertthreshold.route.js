const express = require("express");
const router = express.Router();
const alertThresholdController = require("../controllers/alertthreshold.controller");
const authMiddleware = require("../middlewares/authMiddlewares");
const {checkPermission} = require("../middlewares/checkPermissionMiddleware");

// Middleware validate dữ liệu đầu vào
// const validateAlertThreshold = require("../middlewares/validateAlertThreshold");

// Routes
router.get("/", alertThresholdController.getAllAlertThresholds);



router.post("/device/:resource_id",
     authMiddleware("access"),
     (req, res, next) => {
          req.resourceType = "DEVICE";
          req.requiredPermission = "update_device";
          req.resource_id = req.body.device_id
          next();
      },
     checkPermission,
     alertThresholdController.createAlertThreshold);

router.put("/device/:resource_id",
     authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = "DEVICE";
        req.requiredPermission = "update_device";
        next();
    },
    checkPermission,
       alertThresholdController.updateAlertThreshold);

router.delete("/device/:resource_id",
     authMiddleware("access"),
     (req, res, next) => {
         req.resourceType = "DEVICE";
         req.requiredPermission = "delete_device";
         next();
     },
     checkPermission,
     alertThresholdController.deleteAlertThreshold);

router.get("/device/:resource_id",
     authMiddleware("access"),
     (req, res, next) => {
         req.resourceType = "DEVICE";
         req.requiredPermission = "read_device";
         next();
     },
     checkPermission,
     alertThresholdController.getThresholdByDeviceId);

module.exports = router;
