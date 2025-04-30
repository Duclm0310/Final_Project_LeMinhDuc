const { User, Device, Role, Permission, ResourceSharing } = require("../models/index");
const bcrypt = require("bcrypt");
const { generalAccessToken, generalRefreshToken } = require("./jwt.service");
const otpService = require("./otp.service");
const { isEmail } = require("validator");
const { updateDeviceThresholds, saveUserInfoToRedis, saveDeviceTokenToRedis } = require("./redis.service");
const DeviceTokenService = require("./devicetoken_service");
const roleService = require("./role.service.js");
const redisClient = require("../config/redisClient");

const {
    BadRequestError,
    NotFoundError,
    ValidationError,
    ForbiddenError,
    UnauthorizedError,
    ConflictError,
} = require("../utils/errors/index.js");

class UserService {
    async createUser(userData) {
        const { name, username, email, password, address, phone } = userData;
        try {
            const checkEmail = await User.findOne({
                where: { email: email },
            });

            if (checkEmail !== null) {
                throw new ConflictError("This email address is already in use");
            }

            const checkUsername = await User.findOne({
                where: { username: username },
            });

            if (checkUsername !== null) {
                throw new ConflictError("This username is already in use");
            }

            const passwordhash = bcrypt.hashSync(password, 10);

            const newUser = await User.create({
                name: name,
                username: username,
                email: email,
                password: passwordhash,
                address: address,
                phone: phone,
            });

            await otpService.sendOtp(email);

            console.log("new user created: " + newUser.dataValues);

            return newUser;
        } catch (err) {
            console.error("Error creating user");
            throw err;
        }
    }

    async signinUser(email, password) {
        try {
            if (!email || !password) {
                throw new BadRequestError("All input fields are required");
            }
    
            if (!isEmail(email)) {
                throw new BadRequestError("Invalid email format");
            } 
            const redisUserKey = await redisClient.keys(`user:*`);
            let userDataFromCache = null;
            const allKeys = await redisClient.keys("user:*");
            const userKeys = allKeys.filter(key => /^user:[^:]+$/.test(key));
    
            for (const key of userKeys) {
                const cachedEmail = await redisClient.hget(key, "email");
                if (cachedEmail === email) {
                    userDataFromCache = await redisClient.hgetall(key);
                    break;
                }
            }
            let user;
            if (userDataFromCache) {
                user = {
                    user_id: userDataFromCache.id,
                    email: userDataFromCache.email,
                    password: userDataFromCache.password,
                    name: userDataFromCache.name,
                    is_verified: userDataFromCache.is_verified === "true"
                };
            } else {
                user = await User.findOne({ where: { email } });
    
                if (!user) {
                    throw new UnauthorizedError("Incorrect email or password");
                }
                // Lưu vào Redis sau khi lấy DB
                await saveUserInfoToRedis(user.user_id, user.email, {
                    name: user.name,
                    password: user.password,
                    is_verified: user.is_verified
                });
            }
    
            const comparePassword = bcrypt.compareSync(password, user.password);
    
            if (!comparePassword) {
                throw new UnauthorizedError("Incorrect email or password");
            }
    
            if (!user.is_verified) {
                throw new ForbiddenError("Please verify your email first");
            }
    
            const accesstoken = await generalAccessToken({ user_id: user.user_id });
            const refreshtoken = await generalRefreshToken({ user_id: user.user_id });
    
            const device_tokens = await DeviceTokenService.getAllTokensByUser(user.user_id);
    
            await Promise.all([
                updateDeviceThresholds(user.user_id),
                saveDeviceTokenToRedis(user.user_id, device_tokens),
            ]);
    
            return {
                status: "Success",
                message: "Login successful",
                accesstoken,
                refreshtoken,
                name: user.name,
            };
        } catch (err) {
            console.error("❌ Error signing in:", err);
            throw err;
        }
    }

    async getUserById(userId) {
        try {
            const user = await User.findByPk(userId);

            if (!user) {
                throw new NotFoundError("No user found");
            }

            return {
                status: "Success",
                message: `User found with id: ${userId}`,
                user: user,
            };
        } catch (err) {
            console.error(`Error fetching user by user id ${userId}`);
            throw err;
        }
    }

    async getUserByEmailAndPassword(email, password) {
        try {
            const user = await User.findOne({
                where: {
                    email: email,
                    password: password,
                },
            });

            if (!user) {
                throw new UnauthorizedError("Invalid email or password");
            }

            console.log("User found:", user);

            return user;
        } catch (err) {
            console.error("Error finding user by email + password");
            throw new err();
        }
    }

    async getAllUsers() {
        try {
            const allUsers = await User.findAll();

            if (!allUsers) {
                throw new NotFoundError("There are no users");
            }

            return allUsers;
        } catch (err) {
            console.error("Error getting all users");
            throw err;
        }
    }

    async getUsers(criteria = {}) {
        try {
            const { sortBy, sortOrder, role, permission } = criteria;

            if (sortBy && !["name", "createdAt"].includes(sortBy)) {
                throw new BadRequestError(
                    (details = `Invalid sort field: '${sortBy}'. Must be 'name' or 'createdAt'.`)
                );
            }

            const queryOptions = {
                include: [], // joining associated tables
                order: [], // asc/desc
                where: {}, // filtering
            };

            // sorting
            if (sortBy && sortOrder) {
                queryOptions.order.push([sortBy, sortOrder.toUpperCase()]);
            }

            // filtering by role
            if (role) {
                queryOptions.include.push({
                    model: Role,
                    where: { role_name: role },
                    through: { attributes: [] },
                });
            }

            if (permission) {
                queryOptions.include.push({
                    model: Role,
                    include: [
                        {
                            model: Permission,
                            where: { permission_name: permission },
                            through: { attributes: [] }, // exclude joint table's columns
                        },
                    ],
                    through: { attributes: [] }, // exclude joint table's columns
                });
            }

            const users = await User.findAll(queryOptions);
            return users;
        } catch (err) {
            throw new Error(err);
        }
    }

    async updateUser(userId, updateData) {
        try {
            const checkUser = await User.findByPk(userId);
            if (!checkUser) {
                throw new Error("There was no user with that id");
            }

            if (updateData.password) {
                const salt = await bcrypt.genSalt(10);
                updateData.password = await bcrypt.hash(
                    updateData.password,
                    salt
                );
            }

            updateData.updated_at = new Date();

            console.log("updated data: " + updateData);

            const updatedUser = await User.update(updateData, {
                where: { user_id: userId },
            });

            await saveUserInfoToRedis(updatedUser.user_id, updatedUser.email, {
                name: updatedUser.name,
                password: updatedUser.password,
                is_verified: updatedUser.is_verified
            });

            return {
                status: "Success",
                message: "User updated successfully",
                data: updatedUser,
            };
        } catch (err) {
            console.error("Error updating user");
            throw err;
        }
    }

    async deleteUser(userId) {
        try {
            const checkUser = await User.findByPk(userId);
            if (!checkUser) {
                throw new Error("There was no user with that id");
            }
            await User.destroy(id);

            return {
                status: "Success",
                message: "User deleted successfully",
            };
        } catch (err) {
            console.error("Error deleting user");
            throw err;
        }
    }

    async getUserRolesAndPermissions(userId) {
        try {
            const user = await User.findByPk(userId, {
                include: [
                    {
                        model: Role,
                        through: { attributes: [] },
                        // attributes: [
                        //     "role_id",
                        //     "role_name",
                        //     "role_description",
                        // ],
                    },
                ],
            });

            if (!user) {
                throw new NotFoundError("User not found");
            }

            return user;
        } catch (err) {
            console.error("Error getting user's roles");
            throw err;
        }
    }

    async resetPassword(email, newPassword) {
        try {
            if (!email || !newPassword) {
                throw new BadRequestError(
                    "Email and new password are required"
                );
            }

            const user = await User.findOne({ where: { email: email } });
            if (!user) {
                throw new NotFoundError("User not found");
            }

            if (bcrypt.compareSync(newPassword, user.password)) {
                throw new BadRequestError(
                    "New password cannot be the same as the old password"
                );
            }

            const hashedNewPassword = await bcrypt.hash(newPassword, 10);

            user.password = hashedNewPassword;
            await user.save();

            return {
                status: "Success",
                message: "Password reset successfully",
            };
        } catch (err) {
            console.error("Error resetting password");
            throw err;
        }
    }

    async assignDevice(userId, deviceId) {
        try {
            if (!userId || !deviceId) {
                throw new BadRequestError("User ID and device id are required");
            }

            const device = await Device.findByPk(deviceId);

            if (!device) {
                throw new NotFoundError("Device not found");
            }

            device.user_id = userId;
            await device.save();

            console.log(`new user: ${device.user_id}`);

            return {
                status: "Success",
                message: "successfully assigned device to user " + userId,
            };
        } catch (err) {
            console.error("Error assigning device");
            throw err;
        }
    }

    async unassignDevice(deviceId) {
        try {
            if (!deviceId) {
                throw new Error("device id is required");
            }

            const device = await Device.findByPk(deviceId);

            if (!device) {
                throw new Error("device not found");
            }

            console.log(`before unassign: ${device}`);

            device.user_id = null;
            await device.save();

            console.log(`after unassign: ${device}`);
            return {
                status: "Success",
                message: "successfully unassigned device",
            };
        } catch (err) {
            console.error(`error unassigning device: ${err}`);
            throw err;
        }
    }

    async assignRole(userId, roleId) {
        try {
            if (!userId || !roleId) {
                throw new BadRequestError("user ID and role id are required");
            }

            const user = await User.findByPk(userId);
            if (!user) {
                throw new NotFoundError("user not found");
            }
            const role = await Role.findByPk(roleId);
            if (!role) {
                throw new NotFoundError("role not found");
            }

            await user.addRole(role, {
                through: {
                    user_id: userId,
                    role_id: roleId,
                },
            });

            return {
                status: "Success",
                message:
                    `successfully assign role ${role.role_name}to user ` +
                    user.username,
            };
        } catch (err) {
            console.error("Error assigning role");
            throw err;
        }
    }

    async unassignRole(userId, roleId) {
        try {
            if (!userId || !roleId) {
                throw new BadRequestError("user ID and role id are required");
            }
            const user = await User.findByPk(userId);
            if (!user) {
                throw new NotFoundError("user not found");
            }
            const role = await Role.findByPk(roleId);
            if (!role) {
                throw new NotFoundError("role not found");
            }

            await user.removeRole(role);

            console.log(`role ${roleId} unassigned from user ${userId}`);
            return {
                status: "Success",
                message: "successfully unassigned role from user " + userId,
            };
        } catch (err) {
            console.error("Error unassigning role");
            throw err;
        }
    }

    async getMyDevices(userId) {
        try {
            if (!userId) {
                throw new BadRequestError("User ID is required");
            }
            const devices = await Device.findAll({
                where: { user_id: userId },
            });
            return devices;
        } catch (err) {
            console.error("Error getting user devices");
            throw err;
        }
    }

    async addResident(parentUserId, childUserId) {
        try {
            const parentUser = User.findByPk(parentUserId);
            if (!parentUser) {
                throw new NotFoundError("parent user not found");
            }
            const childUser = User.findByPk(childUserId);
            if (!childUser) {
                throw new NotFoundError("child user not found");
            }

            const parentUserRole = roleService.getRolesPermissions(
                parentUser.role
            );
        } catch (err) {
            console.err("Error adding resident to user");
            throw err;
        }
    }

    async shareResource(ownerId, userId, roleId, resourceId, resourceType) {
        try {
            if (!ownerId || !userId || !roleId || !resourceId || !resourceType) {
                throw new BadRequestError("user ID, resource ID and resource type are required");
            }
    
            const user = await User.findByPk(userId);
            if (!user) {
                throw new NotFoundError("User not found");
            }
            const managerRole = await Role.findOne({
                where: { role_name: "MANAGER" }
            });
    
            if (!managerRole) {
                throw new NotFoundError("Manager role not found");
            }
            const existingResourceSharing = await ResourceSharing.findOne({
                where: {
                    owner_id: ownerId,
                    user_id: userId,
                    resource_id: resourceId,
                    resource_type: resourceType
                }
            });
            if (existingResourceSharing) {
                if (existingResourceSharing.role_id !== roleId) {
                    existingResourceSharing.role_id = roleId;
                    await existingResourceSharing.save();
                    console.log(`Updated role for user ${userId} in resource ${resourceId}`);
                }
                return {
                    status: "Success",
                    message: "Resource role updated successfully"
                };
            }
            if (roleId === managerRole.role_id) {
                await ResourceSharing.create({
                    owner_id: ownerId,
                    user_id: userId,
                    role_id: roleId,
                    resource_id: resourceId,
                    resource_type: "HOUSE",
                });
            } else {
                await ResourceSharing.create({
                    owner_id: ownerId,
                    user_id: userId,
                    role_id: roleId,
                    resource_id: resourceId,
                    resource_type: resourceType,
                });
            }
            await updateDeviceThresholds(userId);
    
            return {
                status: "Success",
                message: "Successfully shared resource and updated user role and thresholds",
            };
        } catch (err) {
            console.error("Error sharing resource:", err);
            throw err;
        }
    }
    
    
}

module.exports = new UserService();
