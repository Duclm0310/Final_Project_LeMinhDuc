const roleService = require("../services/role.service");

class RoleController {
    constructor(roleService) {
        this.roleService = roleService;
    }

    async createRole(req, res) {
        try {
            const role = await roleService.createRole(req.body);
            res.status(201).json(role);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getRoleById(req, res) {
        try {
            const role = await roleService.getRoleById(req.params.id);
            if (role) {
                res.status(200).json(role);
            } else {
                res.status(404).json({ message: "Role not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAllRoles(req, res) {
        try {
            const roles = await roleService.getAllRoles({});
            res.status(200).json(roles);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async updateRole(req, res) {
        try {
            const role = await roleService.updateROle(req.params.id, req.body);
            if (role) {
                res.status(200).json(role);
            } else {
                res.status(404).json({ message: "Role not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteRole(req, res) {
        try {
            const role = await roleService.deleteRole(req.params.id);
            if (role) {
                res.status(200).json({ message: "Role deleted successfully" });
            } else {
                res.status(404).json({ message: "Role not found" });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async assignPermissionToRole(req, res, next) {
        try {
            const { role_id, permission_id } = req.params;

            const result = await roleService.assignPermissionToRole(
                role_id,
                permission_id
            );
            res.status(200).json(result);
        } catch (err) {
            console.error("Error assigning role");
            next(err);
        }
    }

    async assignPermissionsToRole(req, res, next) {
        try {
            const { role_id } = req.params;
            const permission_ids = req.body.permission_ids;

            const result = await roleService.assignPermissionsToRole(
                role_id,
                permission_ids
            );
            res.status(200).json(result);
        } catch (err) {
            console.error("Error assigning permissions to role");
            next(err);
        }
    }

    async removePermission(req, res, next) {
        try {
            const { role_name, permission_name } = req.params;

            const result = await roleService.removePermission(
                role_name,
                permission_name
            );
            res.status(200).json(result);
        } catch (err) {
            console.error("Error removing permission");
            next(err);
        }
    }

    async getRolesPermissions(req, res, next) {
        try {
            const rolePermissions = await roleService.getRolesPermissions(
                req.params.role_name
            );
            res.status(200).json(rolePermissions);
        } catch (err) {
            console.error("Error getting roles and permissions");
            next(err);
        }
    }
}

module.exports = new RoleController(roleService);
