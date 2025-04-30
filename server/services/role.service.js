const { Role, Permission, RolePermission } = require("../models/index");
const { BadRequestError, NotFoundError } = require("../utils/errors/index");

class roleIdervice {
    async createRole(roleData) {
        try {
            const { role_name, role_description } = roleData;

            const role = await Role.findOne({
                where: { role_name: role_name },
            });
            if (role) {
                throw new BadRequestError("Duplicate role name");
            }

            const newRole = await Role.create({
                role_name: role_name,
                role_description: role_description,
            });

            console.log("new role created: ", newRole.dataValues);
            return newRole;
        } catch (err) {
            console.error("Error creating role");
            throw err;
        }
    }

    async getRoleById(roleId) {
        try {
            const role = await Role.findByPk(roleId);
            if (!role) {
                throw new NotFoundError("No role found");
            }
            return await Role.findByPk(roleId);
        } catch (err) {
            console.error("Error getting role by id");
            throw err;
        }
    }

    async getAllRoles() {
        try {
            const allRoles = await Role.findAll();

            if (!allRoles) {
                throw new Error("There are no roles");
            }

            return allRoles;
        } catch (err) {
            console.error("Error getting all users");
            throw err;
        }
    }

    async updateRole(roleId, updateData) {
        try {
            const role = await Role.findByPk(roleId);
            if (!role) {
                throw new NotFoundError("Role not found");
            }

            return await role.update(updateData);
        } catch (err) {
            console.error("Error updating role");
            throw err;
        }
    }

    async deleteRole(role_id) {
        try {
            const role = await Role.findByPk(role_id);
            if (!role) {
                throw new Error("Role not found");
            }
            await role.destroy();
            return {
                status: "Success",
                message: "role deleted successfully",
            };
        } catch (err) { }
    }

    async assignPermissionToRole(role_id, permission_id) {
        try {
            if (!role_id || !permission_id) {
                throw new BadRequestError("role and permission are required");
            }

            const role = await Role.findByPk(role_id);
            if (!role) {
                throw new NotFoundError("role not found");
            }

            const permission = await Permission.findByPk(permission_id);
            if (!permission) {
                throw new NotFoundError(`Permission not found`);
            }

            await RolePermission.create({
                role_id: role.role_id,
                permission_id: permission.permission_id,
            });

            return {
                status: "Success",
                message: `successfully assign permission ${permission.permission_name} to role ${role.role_name}`,
            };
        } catch (err) {
            console.error("Error assigning permissions");
            throw err;
        }
    }

    async assignPermissionsToRole(role_id, permission_ids) {
        try {
            if (!role_id || !permission_ids || permission_ids.length === 0) {
                throw new BadRequestError("role and permission are required");
            }

            const role = await Role.findByPk(role_id);
            if (!role) {
                throw new NotFoundError("role not found");
            }

            let permissions;
            permission_ids.forEach(async (permission_id) => {
                const permission = await Permission.findByPk(permission_id);
                if (!permission) {
                    throw new NotFoundError(`Permission not found`);
                }
                await RolePermission.create({
                    role_id: role.role_id,
                    permission_id: permission.permission_id,
                });
            });

            return {
                status: "Success",
                message: `successfully assign permissions to role ${role.role_name}`,
            };
        } catch (err) {
            console.error("Error assigning permissions to role");
            throw err;
        }
    }

    async getRolesPermissions(roleName) {
        try {
            // joint table of 1 role & all its role_permissions & all permissions of those
            const role = await Role.findOne({
                where: { role_name: roleName },
                attributes: ["role_id", "role_name", "role_description"],
                include: [
                    {
                        model: RolePermission,
                        attributes: ["resources"],
                        include: [
                            {
                                model: Permission,
                                attributes: [
                                    "permission_id",
                                    "permission_name",
                                    "permission_description",
                                ],
                            },
                        ],
                    },
                ],
            });

            if (!role) {
                throw new NotFoundError("Role not found");
            }

            return role;
        } catch (err) {
            console.error("Error getting role permissions");
            throw err;
        }
    }

    async removePermission(roleName, permissionName) {
        try {
            const role = await Role.findOne({ where: { role_name: roleName } });
            if (!role) {
                throw new NotFoundError("role not found");
            }
            const permission = await Permission.findOne({
                where: { permission_name: permissionName },
            });
            if (!permission) {
                throw new NotFoundError("permission not found");
            }

            const rolePermission = await RolePermission.findOne({
                where: {
                    role_id: role.role_id,
                    permission_id: permission.permission_id,
                },
            });

            if (!rolePermission) {
                throw new NotFoundError(
                    `permission ${permissionName} not found for role ${roleName}`
                );
            }

            await rolePermission.destroy();

            return {
                status: "Success",
                message: `Permission removed from role ${role.role_name}`,
            };
        } catch (err) {
            console.error("Error removing permission");
            throw err;
        }
    }
}

module.exports = new roleIdervice();
