const { House, ResourceSharing, Role } = require("../models/index");
const { Op } = require("sequelize");
const { 
    BadRequestError, 
    NotFoundError, 
    ConflictError,
    ValidationError
} = require("../utils/errors/index");

class HouseService {

    async createHouse(houseData, userId) {
        try {
            if (!houseData.house_name || !houseData.house_address) {
                throw new ValidationError("House name and address are required.");
            }

            const newHouse = await House.create({
                ...houseData,
                owner_id: userId,
            });
            const houseOwnerRole = await Role.findOne({
                where: { role_name: "HOMEOWNER" },
            });
            if (!houseOwnerRole) {
                throw new NotFoundError("Role 'HOMEOWNER' không tồn tại trong hệ thống.");
            }
            const newResourceSharing = await ResourceSharing.create({
                owner_id: userId,
                user_id: userId,
                resource_type: "HOUSE",
                resource_id: newHouse.house_id,
                role_id: houseOwnerRole.id,
            });

            console.log("New Resource Sharing:", newResourceSharing);
            return newHouse;

        } catch (err) {
            console.error("Error creating house:", err.message);
            throw err;
        }
    }


    async getHouseById(houseId) {
        try {
            const house = await House.findByPk(houseId);
            if (!house) {
                throw new NotFoundError("House not found");
            }
            return house;
        } catch (error) {
            console.error("Error getting house by ID: " + error.message);
            throw error;
        }
    }

    async getAllHouses() {
        try {
            return await House.findAll();
        } catch (error) {
            console.error("Error getting all houses: " + error.message);
            throw error;
        }
    }

    async updateHouse(house_id, updateData) {
        try {
            const house = await House.findByPk(house_id);
            if (!house) {
                throw new NotFoundError("House not found");
            }
            return await house.update(updateData);
        } catch (error) {
            console.error("Error updating house: " + error.message);
            if (error instanceof NotFoundError) {
                throw error;
            }
            throw new BadRequestError("Failed to update house: " + error.message);
        }
    }

    async deleteHouse(house_id) {
        try {
            const house = await House.findByPk(house_id);
            if (!house) {
                throw new NotFoundError("House not found");
            }
            await house.destroy();
            return true;
        } catch (error) {
            console.error("Error deleting house: " + error.message);
            if (error instanceof NotFoundError) {
                throw error;
            }
            throw new BadRequestError("Failed to delete house: " + error.message);
        }
    }

    async getHouseByUserid(user_id) {
        try {
            const houses = await House.findAll({
                where: {
                    owner_id: user_id,
                },
            });
            return houses;
        } catch (error) {
            console.error("Error getting houses by user ID: " + error.message);
            throw new BadRequestError("Failed to get houses for user: " + error.message);
        }
    }

    async getHouseByArrayHouseId(HouseIds) {
        try {
            if (!HouseIds || HouseIds.length === 0) {
                throw new ValidationError("House IDs array is required and cannot be empty");
            }
            const houses = await House.findAll({
                where: { house_id: Array.from(HouseIds) },
            });
            return houses;
        } catch (error) {
            console.error("Error getting houses by array of IDs: " + error.message);
            if (error instanceof ValidationError) {
                throw error;
            }
            throw new BadRequestError("Failed to get houses by IDs: " + error.message);
        }
    }

    async getHousesByDistrict(district) {
        try {
            if (!district) {
                throw new ValidationError("District parameter is required");
            }
            return await House.findAll({
                where: {
                    house_address: {
                        [Op.like]: `%${district}%`,
                    },
                },
            });
        } catch (error) {
            console.error("Error fetching houses by district: " + error.message);
            if (error instanceof ValidationError) {
                throw error;
            }
            throw new BadRequestError("Failed to get houses by district: " + error.message);
        }
    }
}

module.exports = new HouseService();
