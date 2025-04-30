const { Room, ResourceSharing } = require("../models/index");

class RoomService {
    async createRoom(roomData) {
        return await Room.create(roomData);
    }

    async getRoomById(roomId) {
        return await Room.findByPk(roomId);
    }

    async getAllRooms() {
        return await Room.findAll();
    }

    async updateRoom(roomId, updateData) {
        const room = await Room.findByPk(roomId);
        if (!room) {
            throw new Error("Room not found");
        }
        return await room.update(updateData);
    }

    async deleteRoom(roomId) {
        const room = await Room.findByPk(roomId);
        if (!room) {
            throw new Error("Room not found");
        }
        await room.destroy();
        return true;
    }

   async AllroomsByhouseId(houseId){
    return await Room.findAll({
        where: {
            house_id : houseId
        }
    })
   }


   async getHouseidfromRoominResourceSharing(userId){
     const roomIds = await ResourceSharing.findAll({
                where: {
                    user_id: userId,
                    resource_type: 'ROOM',
                },
                attributes: ['resource_id'],
                raw: true,
            });
            
            const roomIdsOnly = roomIds.map(r => r.resource_id);
            
            const houseIdsFromRoom = await Room.findAll({
                where: {
                    room_id: roomIdsOnly,
                },
                attributes: ['house_id'],
                group: ['house_id'],
                raw: true,
            });
            return houseIdsFromRoom;
   }
}

module.exports = new RoomService();
