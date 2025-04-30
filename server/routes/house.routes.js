const express = require("express");
const router = express.Router();
const houseController = require("../controllers/house.controller");
const authMiddleware = require("../middlewares/authMiddlewares");
const { validateHouse } = require("../middlewares/validation");
const { checkPermission } = require("../middlewares/checkPermissionMiddleware");

router.get("/", authMiddleware, houseController.getAllHouses);

router.get("/accessible-houses",
    authMiddleware("access"),
    houseController.getAccessibleHouses
);


router.get(
    "/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = 'HOUSE';
        req.requiredPermission = 'read_house';
        next();
    },
    checkPermission,
    houseController.getHouseById
);

router.get("/user/:user_id",
    authMiddleware("access"),
    houseController.getHouseByUserid
)

// Create a new house (protected route)
router.post("/", authMiddleware("access"), houseController.createHouse);


router.put("/:resource_id",
     authMiddleware("access"),
     (req, res, next) => {
        req.resourceType = 'HOUSE';
        req.requiredPermission = 'update_house';
        next();
    },
    checkPermission,
      houseController.updateHouse);


router.delete(
    "/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.resourceType = 'HOUSE';
        req.requiredPermission = 'delete_house';
        next();
    },
    checkPermission,
    houseController.deleteHouse
);




module.exports = router;
