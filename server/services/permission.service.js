const { Permission } = require("../models/index");

class PermissionService {
    /**
     * Create a new permission.
     * @param {Object} permissionData - Permission data to create.
     * @returns {Promise<Permission>} - The created permission.
     */
    async createPermission(permissionData) {
        return await Permission.create(permissionData);
    }

    /**
     * Get a permission by its ID.
     * @param {string} permission_id - The ID of the permission.
     * @returns {Promise<Permission>} - The found permission.
     */
    async getPermissionById(permission_id) {
        return await Permission.findByPk(permission_id);
    }

    /**
     * Get all permissions.
     * @returns {Promise<Array<Permission>>} - A list of all permissions.
     */
    async getAllPermissions() {
        return await Permission.findAll();
    }

    /**
     * Update a permission by its ID.
     * @param {string} permission_id - The ID of the permission.
     * @param {Object} updateData - Data to update.
     * @returns {Promise<Permission>} - The updated permission.
     */
    async updatePermission(permission_id, updateData) {
        const permission = await Permission.findByPk(permission_id);
        if (!permission) {
            throw new Error("Permission not found");
        }
        return await permission.update(updateData);
    }

    /**
     * Delete a permission by its ID.
     * @param {string} permission_id - The ID of the permission.
     * @returns {Promise<boolean>} - True if the permission was deleted.
     */
    async deletePermission(permission_id) {
        const permission = await Permission.findByPk(permission_id);
        if (!permission) {
            throw new Error("Permission not found");
        }
        await permission.destroy();
        return true;
    }

    /**
     * Delete all permissions.
     * @returns {Promise<number>} - The number of deleted permissions.
     */
    async deleteAllPermissions() {
        const deletedCount = await Permission.destroy({
            where: {},
            truncate: true,
        });
        return deletedCount;
    }
}

module.exports = new PermissionService();
