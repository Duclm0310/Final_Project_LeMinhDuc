const express = require("express");
const router = express.Router();
const costthresholdController = require("../controllers/costthreshold.controller");
const authMiddleware = require("../middlewares/authMiddlewares");
const { checkPermission } = require("../middlewares/checkPermissionMiddleware");


router.post("/set-threshold/house/:houseId",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = "HOUSE";
        req.requiredPermission = "update_house";
        req.params.resource_id = req.params.houseId;
        next();
    },
    checkPermission,
    costthresholdController.setCostThreshold);

router.get("/threshold/house/:houseId",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = "HOUSE";
        req.requiredPermission = "read_house";
        req.params.resource_id = req.params.houseId;
        next();
    },
    checkPermission,
    costthresholdController.getCostThreshold);

module.exports = router;
