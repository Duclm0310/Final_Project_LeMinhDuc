const houseService = require("../services/house.service");
const roomSerice = require("../services/room.service");
const deviceService = require("../services/device.service")
const {Room, Device, ResourceSharing} = require("../models/index");
const{deleteHouseFromRedis} = require("../services/redis.service");

class HouseController {
    constructor(houseService) {
        this.houseService = houseService;
    }


    async createHouse(req, res, next) {
        try {
            console.log("creating house...");
            const userId = req.body.payload.user_id;
            const house = await houseService.createHouse(req.body, userId);
            res.status(201).json(house);
        } catch (error) {
            next(error);
        }
    }

    async getHouseById(req, res) {
        try {
            const house = await houseService.getHouseById(req.params.resource_id);
            if (house) {
                res.status(200).json(house);
            } else {
                res.status(404).json({ message: "House not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAllHouses(req, res) {
        try {
            const houses = await houseService.getAllHouses({});
            res.status(200).json(houses);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async updateHouse(req, res) {
        try {
            const house = await houseService.updateHouse(
                req.params.resource_id,
                req.body
            );
            if (house) {
                res.status(200).json(house);
            } else {
                res.status(404).json({ message: "House not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteHouse(req, res) {
        try {
            const house = await houseService.deleteHouse(req.params.resource_id);
            if (house) {
                await deleteHouseFromRedis(req.params.resource_id);
                res.status(200).json({ message: "House deleted successfully" });
            } else {
                res.status(404).json({ message: "House not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteAllHouses(req, res) {
        try {
            const result = await houseService.deleteAllHouses();
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getHouseByUserid(req, res){
        try {
            const userid = req.params.user_id;
            if(!userid){
                res.status(500).json({message: "No userid"})
            }
            const result = await houseService.getHouseByUserid(userid);
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAccessibleHouses(req, res) {
        const userId = req.body.payload.user_id;
        const houseIdsFromRoom = await roomSerice.getHouseidfromRoominResourceSharing(userId)
        const houseIdsFromDevice = await deviceService.getHouseidfromDeviceinResourceSharing(userId)
        const houseIdsFromHouse = await ResourceSharing.findAll({
            where: {
                user_id: userId,
                resource_type: 'HOUSE',
            },
            attributes: ['resource_id'],
            raw: true,
        });
    
        const allHouseIds = new Set([
            ...houseIdsFromRoom.map(r => r.house_id),
            ...houseIdsFromDevice.map(r => r.house_id),
            ...houseIdsFromHouse.map(r => r.resource_id),
        ]);
        const result = await houseService.getHouseByArrayHouseId(allHouseIds);
        res.status(200).json(result);
    }
    

}

module.exports = new HouseController(houseService);
