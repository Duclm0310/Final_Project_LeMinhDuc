const Joi = require("joi");
const ValidationError = require("../utils/errors/ValidationError");

// User Schema
const userSchema = Joi.object({
    name: Joi.string().min(3).max(100).required(),
    username: Joi.string().min(3).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    phone: Joi.string().min(8).max(15).required(),
    address: Joi.string().min(5).max(200).required(),
});

// House Schema
const houseSchema = Joi.object({
    house_name: Joi.string().min(3).max(100).required(),
    house_address: Joi.string().min(5).max(200).required(),
    owner_id: Joi.string().optional(),
});

// Device Schema
const deviceSchema = Joi.object({
    device_id: Joi.string().uuid().optional(),
    room_id: Joi.string().uuid().allow(null).optional(),
    device_name: Joi.string().min(3).max(100).required(),
    device_type: Joi.string().min(3).max(50).required(),
    device_description: Joi.string().max(200).allow(null).optional(),
    status: Joi.string().valid("ON", "OFF", "INACTIVE").required(),
    is_active: Joi.boolean().required(),
    user_id: Joi.string().uuid().allow(null).optional(),
});

// Room Schema
const roomSchema = Joi.object({
    room_id: Joi.string().uuid().optional(),
    room_name: Joi.string().min(3).max(100).required(),
    room_description: Joi.string().max(200).allow(null).optional(),
    room_residents: Joi.array()
        .items(Joi.string().uuid())
        .allow(null)
        .optional(),
    house_id: Joi.string().uuid().required(),
});

// Role Schema
const roleSchema = Joi.object({
    role_id: Joi.string().uuid().optional(),
    role_name: Joi.string().min(3).max(50).required(),
    role_description: Joi.string().min(5).max(200).optional(),
});

// Permission Schema
const permissionSchema = Joi.object({
    permission_id: Joi.string().uuid().optional(),
    permission_name: Joi.string().min(3).max(50).required(),
    permission_description: Joi.string().min(5).max(200).required(),
});

// Device Log Schema
const deviceLogSchema = Joi.object({
    deviceId: Joi.string().required(),
    status: Joi.string().required(),
    timestamp: Joi.date().required(),
});

// Notification Schema
const notificationSchema = Joi.object({
    title: Joi.string().min(3).max(100).required(),
    message: Joi.string().min(5).max(500).required(),
    user_id: Joi.string().required(),
    // timestamp: Joi.date().required(),
});

// // Validation Middleware for User
// function validateUser(req, res, next) {
//     const { error } = userSchema.validate(req.body);
//     if (error) {
//         const myError = new ValidationError(error.details[0].message);
//         throw myError;
//     }
//     next();
// }

// // Validation Middleware for House
// function validateHouse(req, res, next) {
//     const { error } = houseSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// // Validation Middleware for Device
// function validateDevice(req, res, next) {
//     const { error } = deviceSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// // Validation Middleware for Room
// function validateRoom(req, res, next) {
//     const { error } = roomSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// // Validation Middleware for Role
// function validateRole(req, res, next) {
//     const { error } = roleSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// // Validation Middleware for Permission
// function validatePermission(req, res, next) {
//     const { error } = permissionSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// // Validation Middleware for Device Log
// function validateDeviceLog(req, res, next) {
//     const { error } = deviceLogSchema.validate(req.body);
//     if (error) {
//         return next(new ValidationError(error.details[0].message));
//     }
//     next();
// }

// Validation Middleware
function validate(schema) {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);

        if (error) {
            // Send a 400 Bad Request response with the validation error message
            return res.status(400).json({
                status: "Error",
                message: `${error.details[0].message}`,
                details: error.details[0].message,
            });
        }

        // If validation passes, proceed to the next middleware or route handler
        next();
    };
}

module.exports = {
    validateUser: validate(userSchema),
    validateRole: validate(roleSchema),
    validatePermission: validate(permissionSchema),
    validateHouse: validate(houseSchema),
    validateDevice: validate(deviceSchema),
    validateRoom: validate(roomSchema),
    validateDeviceLog: validate(deviceLogSchema),
    validateNotification: validate(notificationSchema),
};
