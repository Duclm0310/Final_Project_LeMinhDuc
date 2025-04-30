const userController = require("./user.controller");
const roleController = require("./role.controller");
const permissionController = require("./permission.controller");
const rolePermissionController = require("./rolePermissionController");
const deviceController = require("./device.controller");
const roomController = require("./room.controller");
const deviceLogController = require("./device_log.controller");

module.exports = {
    userController,
    roleController,
    permissionController,
    rolePermissionController,
    deviceController,
    roomController,
    deviceLogController,
};
