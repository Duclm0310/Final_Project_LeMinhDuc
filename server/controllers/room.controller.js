const roomService = require("../services/room.service");
const { addRoomToHouseInRedis,
    deleteRoomFromRedis,
    deleteHouseFromRedis, } = require("../services/redis.service");
    const { ResourceSharing, Room } = require("../models/index");

class RoomController {
    constructor(roomService) {
        this.roomService = roomService;

        this.createRoom = this.createRoom.bind(this);
        this.getRoomById = this.getRoomById.bind(this);
        this.getAllRooms = this.getAllRooms.bind(this);
        this.updateRoom = this.updateRoom.bind(this);
        this.deleteRoom = this.deleteRoom.bind(this);
        // this.deleteAllRooms = this.deleteAllRooms.bind(this);
    }

    async createRoom(req, res) {
        try {
            const room = await roomService.createRoom(req.body);
            addRoomToHouseInRedis(room.room_id, room.house_id);
            res.status(201).json(room);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getRoomById(req, res) {
        try {
            const room = await roomService.getRoomById(req.params.resource_id);
            if (room) {
                res.status(200).json(room);
            } else {
                res.status(404).json({ message: "Room not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAllRooms(req, res) {
        try {
            const rooms = await roomService.getAllRooms({});
            res.status(200).json(rooms);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async updateRoom(req, res) {
        try {
            const room = await roomService.updateRoom(req.params.resource_id, req.body);
            if (room) {
                res.status(200).json(room);
            } else {
                res.status(404).json({ message: "Room not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteRoom(req, res) {
        try {
            const room = await roomService.deleteRoom(req.params.resource_id);
            deleteRoomFromRedis(req.params.id);
            if (room) {
                res.status(200).json({ message: "Room deleted successfully" });
            } else {
                res.status(404).json({ message: "Room not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getRoomByhouseId(req, res) {
        try {
            const houseId = req.params.house_id;
            if (!houseId) {
                res.status(500).json({ message: "No house id" })
            }

            const rooms = await roomService.AllroomsByhouseId(houseId);
            res.status(200).json(rooms);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }


    async getAccessibleRoomsInHouse(req, res) {
        try {
            const userId = req.body.payload.user_id; 
            const houseId = req.params.house_id;
            const hasHouseLevelRole = await ResourceSharing.findOne({
                where: {
                    user_id: userId,
                    resource_type: 'HOUSE',
                    resource_id: houseId
                }
            });
    
            if (hasHouseLevelRole) {
                const allRooms = await Room.findAll({
                    where: { house_id: houseId }
                });
    
                return res.status(200).json({
                    success: true,
                    allRooms: true,
                    rooms: allRooms.map(r => ({
                        ...r.dataValues,
                        hasAccess: true
                    }))
                });
            }
    
            // 👤 Nếu chỉ là người dùng có quyền trên ROOM cụ thể
            const sharedRooms = await ResourceSharing.findAll({
                where: {
                    user_id: userId,
                    resource_type: 'ROOM'
                },
                attributes: ['resource_id'],
                raw: true
            });
    
            const roomIds = sharedRooms.map(r => r.resource_id);
    
            const rooms = await Room.findAll({
                where: {
                    house_id: houseId,
                    room_id: roomIds
                }
            });
    
            return res.status(200).json({
                success: true,
                allRooms: false,
                rooms: rooms.map(r => ({
                    ...r.dataValues,
                    hasAccess: true
                }))
            });
        } catch (error) {
            console.error("❌ Error in getAccessibleRoomsInHouse:", error);
            return res.status(500).json({
                success: false,
                message: "Server error while loading accessible rooms."
            });
        }
    }

}

module.exports = new RoomController(roomService);
