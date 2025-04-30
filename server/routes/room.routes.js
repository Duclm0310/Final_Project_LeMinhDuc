const express = require("express");
const roomController = require("../controllers/room.controller");
const { validateRoom } = require("../middlewares/validation");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddlewares");
const {checkPermission} = require("../middlewares/checkPermissionMiddleware");

// GET
router.get("/", roomController.getAllRooms);

router.get("/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.requiredPermission = 'read_room';
        req.resourceType = 'ROOM';  
        next(); 
    },
    checkPermission,
    roomController.getRoomById);


    router.get("/houses/:house_id/accessible-rooms",
        authMiddleware("access"),
        roomController.getAccessibleRoomsInHouse);

    
router.get("/house/:house_id/rooms",
    roomController.getRoomByhouseId)

// POST
router.post("/",
    authMiddleware("access"),
    (req, res, next) => {
        req.requiredPermission = 'create_room';
        req.resourceType = 'ROOM';  
        next(); 
    },
    checkPermission,
    validateRoom,
    roomController.createRoom);

// UPDATE
router.put("/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.requiredPermission = 'update_room';
        req.resourceType = 'ROOM';  
        next(); 
    },
    checkPermission,
    validateRoom,
    roomController.updateRoom);

// DELETE
router.delete("/:resource_id",
    authMiddleware("access"),
    (req, res, next) => {
        req.requiredPermission = 'delete_room';
        req.resourceType = 'ROOM';  
        next(); 
    },
    checkPermission,
    roomController.deleteRoom);

module.exports = router;
