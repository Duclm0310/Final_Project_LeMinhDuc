const {
    NotFoundError,
    BadRequestError,
    ForbiddenError,
} = require("../utils/errors/index");

const {
    User,
    Role,
    Permission,
    RolePermission,
    House,
    Device,
    Room,
    HouseResident,
} = require("../models/index");

const roleBasedAccessControl = (requiredPermissions, requiredResource) => {
    return async (req, res, next) => {
        console.log(
            "------------------------------------------RBAC_MIDDLEWARE-------------------------------"
        );
        try {
            // get user ID from jwt
            const userId = req.body.payload.user_id;
            if (!userId) throw new UnauthorizedError("Authentication required");

            // get user and their roles & permissions + owned/currently living in houses
            const user = await User.findByPk(userId, {
                include: [
                    {
                        model: Role,
                        include: [
                            {
                                model: RolePermission,
                                include: [Permission],
                                attributes: ["resources"], // Include resources from join table
                            },
                        ],
                    },
                    {
                        // owned houses
                        model: House,
                        as: "OwnedHouses",
                    },
                    {
                        // houses where user is resident
                        model: House,
                        as: "ResidentHouses",
                    },
                ],
            });
            if (!user) throw new NotFoundError("User not found");

            console.log("THIS USER'S ROLES: ", user.Roles);

            // extract all permissions from all of this user's roles
            const isSysadmin = user.Roles.some(
                (role) => role.role_name === "SYSADMIN"
            );
            const effectivePermissions = new Map();

            // creates permission keys in format: "PERMISSION_TYPE:RESOURCE" => store in map
            user.Roles.forEach((role) => {
                role.RolePermissions.forEach((rp) => {
                    rp.resources.forEach((resource) => {
                        const key = `${rp.Permission.permission_name}:${resource}`;
                        effectivePermissions.set(key, true);
                    });
                });
            });

            console.log("EFFECTIVE PERMISSIONS: ", effectivePermissions);

            // check if permissions extracted above fit the required permissions
            // by creating required permission keys and check if they are in the map
            const missingPermissions = requiredPermissions.filter(
                (requiredPermission) => {
                    const permissionKey = `${requiredPermission}:${requiredResource}`;
                    return (
                        !effectivePermissions.has(permissionKey) &&
                        !effectivePermissions.has(`ALL:${requiredResource}`) &&
                        !isSysadmin
                    );
                }
            );

            if (missingPermissions.length > 0) {
                // prettier-ignore
                throw new ForbiddenError(
                    `Missing permissions: ${missingPermissions.join(", ")} for ${requiredResource}`
                );
            }

            // skip checks if sysadmin
            if (isSysadmin) return next();

            // check if user owns/can access the resources
            const resourceId = req.params.id || req.body.id; // Adjust based on your routes
            if (!resourceId) throw new BadRequestError("Resource ID required");

            switch (requiredResource.toLowerCase()) {
                case "house":
                    await validateHouseAccess(user, resourceId);
                    break;
                case "device":
                    await validateDeviceAccess(user, resourceId);
                    break;
                default:
                    throw new ForbiddenError(
                        `Unsupported resource type: ${requiredResource}`
                    );
            }

            next();
        } catch (err) {
            console.error("RBAC Error");
            next(err);
        }
    };
};

async function validateHouseAccess(user, houseId) {
    const isOwner = user.OwnedHouses.some(
        (house) => house.house_id === houseId
    );
    const isResident = user.ResidentHouses.some(
        (house) => house.house_id === houseId
    );

    if (!isOwner && !isResident) {
        throw new ForbiddenError("Access denied to this house");
    }
}

async function validateDeviceAccess(user, deviceId) {
    const device = await Device.findByPk(deviceId, {
        include: [
            {
                model: House,
                include: [
                    {
                        model: User,
                        as: "Residents",
                        through: HouseResident,
                    },
                ],
            },
        ],
    });

    if (!device) throw new NotFoundError("Device not found");

    const validUsers = [
        device.House.owner_id,
        ...device.House.Residents.map((u) => u.user_id),
    ];

    if (!validUsers.includes(user.user_id)) {
        throw new ForbiddenError("Access denied to this device");
    }
}

module.exports = roleBasedAccessControl;
