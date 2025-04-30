const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddlewares");
const {checkPermission} = require("../middlewares/checkPermissionMiddleware");
const resource_sharingController = require("../controllers/resourcesharing.controller");


router.post("/generate-share-token",
     authMiddleware("access"),
     (req, res, next) => {
        req.resourceType = 'HOUSE';
        req.requiredPermission = 'assign_role';
        req.params.resource_id = req.body.resource_id;
        next();
    },
    checkPermission,
    resource_sharingController.createShareToken);

 router.post("/consume-share-token",
    authMiddleware("access"),
//     (req, res, next) => {
//        req.resourceType = 'HOUSE';
//        req.requiredPermission = 'assign_role';
//        next();
//    },
//    checkPermission,
resource_sharingController.handleScanShareToken);



router.get("/houses/:houseId/sharing-users",
   authMiddleware("access"),
   resource_sharingController.getUsersOfHouse );


module.exports = router;