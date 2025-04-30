const userService = require("../services/user.service");
const { provideToken } = require("../services/jwt.service");
const { OtpUser, User } = require("../models/index");
const { isEmail } = require("validator");
const otpService = require("../services/otp.service");
const TokenService = require("../services/blacklisttoken.service");
const jwtService = require("../services/jwt.service");
const {
    BadRequestError,
    NotFoundError,
    UnauthorizedError,
    ValidationError,
    ForbiddenError,
    ConflictError,
} = require("../utils/errors");

class UserController {
    constructor(userService) {
        this.userService = userService;

        this.createUser = this.createUser.bind(this);
        this.getUserById = this.getUserById.bind(this);
        this.getAllUsers = this.getAllUsers.bind(this);
        this.updateUser = this.updateUser.bind(this);
        this.deleteUser = this.deleteUser.bind(this);
    }

    async createUser(req, res, next) {
        try {
            const { name, username, email, password, address, phone } =
                req.body;

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                return res.status(400).json({ message: "Invalid email format." });
            }

            // Validate password strength
            const passwordRegex = /^(?=.*\d).{8,}$/;
            if (!passwordRegex.test(password)) {
                return res.status(400).json({ 
                    message: "Password must be at least 8 characters long and contain at least one number." 
                });
            }

            const newUser = await userService.createUser({
                name,
                username,
                email,
                password,
                address,
                phone,
            });
            return res.status(200).json({
                message: "User created. Please verify your email with OTP.",
            });
        } catch (err) {
            console.error("Error creating user");
            next(err);
        }
    }

    async signinUser(req, res, next) {
        try {
            const { email, password } = req.body;

            const result = await userService.signinUser(email, password);

            const { refreshtoken, ...userData } = result;

            res.cookie("refreshtoken", refreshtoken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === "production",
            });

            return res.status(200).json(userData);
        } catch (err) {
            console.error("Error signing in");
            next(err);
        }
    }

    async getUserById(req, res, next) {
        try {
            const userId = req.params.user_id;
            if (!userId) {
                return res.status(400).json({
                    message: "this Id is required",
                });
            }
            const response = await userService.getUserById(userId);
            return res.status(200).json(response);
        } catch (err) {
            console.error("Error getting user by ID");
            next(err);
        }
    }

    async getAllUsers(req, res, next) {
        try {
            const response = await userService.getAllUsers();
            return res.status(200).json(response);
        } catch (err) {
            next(err);
        }
    }

    async getUsers(req, res, next) {
        try {
            const sortBy = req.query.sortBy;
            const sortOrder = req.query.sortOrder;
            const role = req.query.role;
            const permission = req.query.permission;

            if (sortOrder && sortOrder != "asc" && sortOrder != "desc") {
                throw new BadRequestError(
                    `Invalid sort order: '${sortOrder}'. Must be 'asc' or 'desc'.`
                );
            }

            const users = await userService.getUsers({
                sortBy,
                sortOrder,
                role,
                permission,
            });
            res.status(200).json({
                "Successfully got sorted + filtered list of users: ": users,
            });
        } catch (err) {
            console.error("Error getting users");
            next(err);
        }
    }

    async updateUser(req, res, next) {
        try {
            const userId = req.params.user_id;
            const datauser = req.body;

            if (!userId) {
                return res.status(400).json({ message: "this Id is required" });
            }

            const response = await userService.updateUser(userId, datauser);
            return res.status(200).json(response);
        } catch (err) {
            console.error("Error updating user");
            next(err);
        }
    }

    async deleteUser(req, res, next) {
        try {
            const userId = req.params.user_id;
            console.log(userId);

            if (!userId) {
                return res.status(400).json({ message: "this Id is required" });
            }

            const response = await userService.deleteUser(userId);
            return res.status(200).json(response);
        } catch (err) {
            console.error("Error deleting user");
            next(err);
        }
    }

    async reprovideToken(req, res, next) {
        try {
            const token = req.cookies.refreshtoken;

            if (!token) {
                return res.status(401).send("Refresh Token is required");
            }

            // Kiểm tra xem refresh token có bị blacklist không
            const isBlacklisted = await TokenService.isTokenBlacklisted(
                token
            );
            if (isBlacklisted) {
                return res.status(403).send("Refresh Token is blacklisted");
            }

            const response = await provideToken(token);
            if (response.status === "ERROR") {
                return res.status(403).send(response.message);
            }

            return res.status(200).json({
                message: "Refresh token is valid",
                accessToken: response.accessToken,
            });
        } catch (err) {
            console.error("Error re-providing token");
            next(err);
        }
    }

    async logoutUser(req, res, next) {
        try {
            const refreshToken = req.cookies.refreshtoken;

            if (!refreshToken) {
                return res
                    .status(400)
                    .json({ message: "No refresh token provided" });
            }
            await TokenService.addToBlacklist(refreshToken);

            res.clearCookie("refreshtoken", {
                httpOnly: true,
                secure: process.env.NODE_ENV === "production",
            });

            return res.status(200).json({ message: "Logged out successfully" });
        } catch (err) {
            console.error("Error logging out user");
            next(err);
        }
    }

    async verifyOtp(req, res, next) {
        try {
            const { email, otp } = req.body;

            console.log("Received OTP:", otp);

            const otpRecord = await OtpUser.findOne({
                where: { email: email },
            });
            if (!otpRecord) {
                return res
                    .status(400)
                    .json({ message: "OTP record not found" });
            }

            console.log("Stored OTP:", otpRecord.otp);

            if (otpRecord.otp !== otp) {
                return res.status(400).json({ message: "Invalid OTP" });
            }

            if (otpRecord.expiresAt < new Date()) {
                return res.status(400).json({ message: "OTP has expired" });
            }

            const userId = otpRecord.user_id;
            await userService.updateUser(userId, { is_verified: true });

            await OtpUser.destroy({ where: { email: email } });

            return res
                .status(200)
                .json({ message: "Email verified successfully" });
        } catch (err) {
            console.error("Error verifying OTP");
            next(err);
        }
    }

    async requestPasswordReset(req, res, next) {
        try {
            const { email } = req.body;
            const isHaveEmail = User.findOne({ where: { email: email } })
            if (!isHaveEmail) {
                res.status(200).json({
                    status: "Success",
                    message:
                        "This email does not exist in the system, please try again!",
                });
            }

            await otpService.sendOtp(email);

            res.status(200).json({
                status: "Success",
                message:
                    "OTP sent to your email. Please verify to reset your password.",
            });
        } catch (err) {
            console.error("Error requesting password reset");
            next(err);
        }
    }

    async verifyPasswordResetOtp(req, res, next) {
        try {
            const { email, otp } = req.body;

            console.log("Received OTP:", otp);

            const otpRecord = await OtpUser.findOne({
                where: { email: email },
            });
            if (!otpRecord) {
                return res
                    .status(400)
                    .json({ message: "OTP record not found" });
            }

            console.log("Stored OTP:", otpRecord.otp);

            if (otpRecord.otp !== otp) {
                return res.status(400).json({ message: "Invalid OTP" });
            }

            if (otpRecord.expiresAt < new Date()) {
                return res.status(400).json({ message: "OTP has expired" });
            }

            await OtpUser.destroy({ where: { email: email } });

            const resettoken = await jwtService.getResetPasswordToken({
                email: email,
            });
            console.log("Reset token: ", resettoken);

            return res.status(200).json({
                message: "Email verified successfully",
                resettoken: resettoken,
            });
        } catch (err) {
            console.error("Error verifying password reset OTP");
            next(err);
        }
    }

    async resetPassword(req, res, next) {
        try {
            const { newPassword, payload } = req.body;

            if (!newPassword) {
                throw new BadRequestError("New password is required");
            }
            if (!payload) {
                throw new UnauthorizedError("Invalid token");
            } else {
                console.log("new Password: ", newPassword);
            }

            const result = await userService.resetPassword(
                payload.email,
                newPassword
            );

            res.status(200).json({
                status: "Success",
                message: result.message,
            });
        } catch (err) {
            console.error("Error verifying OTP and resetting password");
            next(err);
        }
    }

    async getUserRolesAndPermissions(req, res, next) {
        try {
            const user = await userService.getUserRolesAndPermissions(req.params.user_id);
            return res.status(200).json({
                status: "Success",
                message: `successfully fetched user ${user.username}'s roles`,
                user: user,
            });
        } catch (err) {
            next(err);
        }
    }

    async assignDevice(req, res, next) {
        try {
            await userService.assignDevice(
                req.params.user_id,
                req.params.device_id
            );
            return res.status(200).json({
                message: `Successfully assigned device ${req.params.device_id} to user ${req.params.user_id}`,
            });
        } catch (err) {
            console.error(err);
            next(err);
        }
    }

    async unassignDevice(req, res, next) {
        try {
            userService.unassignDevice(req.params.device_id);
            return res.status(200).json({
                message: `Successfully unassigned device ${req.params.device_id}`,
            });
        } catch (err) {
            console.error(err);
            next(err);
        }
    }

    async assignRole(req, res, next) {
        try {
            const { user_id, role_id } = req.body;
            await userService.assignRole(user_id, role_id);
            return res.status(200).json({
                message: `Successfully assigned role ${user_id} to user ${role_id}`,
            });
        } catch (err) {
            console.error(err);
            next(err);
        }
    }

    async unassignRole(req, res, next) {
        try {
            const { user_id, role_id } = req.body;
            await userService.unassignRole(user_id, role_id);
            return res.status(200).json({
                message: `Successfully unassigned role ${user_id} from user ${role_id}`,
            });
        } catch (err) {
            console.error(err);
            next(err);
        }
    }

    async getMyDevices(req, res, next) {
        try {
            console.log(JSON.stringify(req.body));
            const userId = req.body.payload.user_id;
            const devices = await userService.getMyDevices(userId);
            res.status(200).json(devices);
        } catch (err) {
            console.error(err);
            next(err);
        }
    }

    async shareResource(req, res, next) {
        try {
            const owner_id = req.body.payload.user_id;
            const { user_id, resource_id, resource_type, role_id } = req.body;
            await userService.shareResource(
                owner_id,
                user_id,
                role_id,
                resource_id,
                resource_type
            );
            return res.status(200).json({
                message: `Successfully shared resource ${resource_id} of type ${resource_type} with user ${user_id}`,
            });
        } catch (err) {
            console.error(err);
            next(err);
        }
    }
}

module.exports = new UserController(userService);
