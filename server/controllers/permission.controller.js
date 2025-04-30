const permissionService = require('../services/permission.service');

class PermissionController {
    constructor(permissionService) {
        this.permissionService = permissionService;

        this.createPermission = this.createPermission.bind(this);
        this.getPermissionById = this.getPermissionById.bind(this);
        this.getAllPermissions = this.getAllPermissions.bind(this);
        this.updatePermission = this.updatePermission.bind(this);
        this.deletePermission = this.deletePermission.bind(this);
        this.deleteAllPermissions = this.deleteAllPermissions.bind(this);
    }

    async createPermission(req, res) {
        try {
            const permission = await permissionService.createPermission(req.body);
            res.status(201).json(permission);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getPermissionById(req, res) {
        try {
            const permission = await permissionService.getPermissionById(req.params.id);
            if (permission) {
                res.status(200).json(permission);
            } else {
                res.status(404).json({ message: 'Permission not found' });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async getAllPermissions(req, res) {
        try {
            const permissions = await permissionService.getAllPermissions({});
            res.status(200).json(permissions);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async updatePermission(req, res) {
        try {
            const permission = await permissionService.updatePermission(req.params.id, req.body)
            if (permission) {
                res.status(200).json(permission);
            } else {
                res.status(404).json({ message: 'Permission not found' });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deletePermission(req, res) {
        try {
            const permission = await permissionService.deletePermission(req.params.id);
            if (permission) {
                res.status(200).json({ message: 'Permission deleted successfully' });
            } else {
                res.status(404).json({ message: 'Permission not found' });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    async deleteAllPermissions(req, res) {
        try {
            const permissions = await permissionService.deleteAllPermissions({});
            if (permissions) {
                res.status(200).json({ message: 'Permissions deleted successfully' });
            } else {
                res.status(404).json({ message: 'Permissions not found' });
            }
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
}

module.exports = new PermissionController(permissionService);