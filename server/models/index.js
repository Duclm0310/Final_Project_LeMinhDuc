require("dotenv").config();
const { sequelize } = require("../config");

const models = {};

models.User = require("./user.model")(sequelize, process.env.DB_SCHEMA);
models.Device = require("./device.model")(sequelize, process.env.DB_SCHEMA);
models.House = require("./house.model")(sequelize, process.env.DB_SCHEMA);
models.Permission = require("./permission.model")(sequelize, process.env.DB_SCHEMA);
models.Role = require("./role.model")(sequelize, process.env.DB_SCHEMA);
models.Room = require("./room.model")(sequelize, process.env.DB_SCHEMA);
models.OtpUser = require("./otpusers.model")(sequelize, process.env.DB_SCHEMA);
models.AlertThreshold = require("./alert_threshold.model")(sequelize, process.env.DB_SCHEMA);
models.DeviceToken = require("./device_token.model")(sequelize, process.env.DB_SCHEMA);
models.EnergySummary = require("./energy_summary.model")(sequelize, process.env.DB_SCHEMA);
models.ResourceSharing = require("./resource_sharing.model")(sequelize, process.env.DB_SCHEMA);
models.CostThreshold = require("./cost_threshold.model")(sequelize, process.env.DB_SCHEMA);


// junction tables
// models.HouseResident = require("./house_resident.model")(sequelize, process.env.DB_SCHEMA);
models.UserRole = require("./user_role.model")(sequelize, process.env.DB_SCHEMA);
models.RolePermission = require("./role_permission.model")(sequelize, process.env.DB_SCHEMA);

function createAssociations(model) {
    if (model.associate) {
        model.associate(models);
    }
}

Object.values(models).forEach((model) => {
    createAssociations(model);
});

module.exports = { ...models };
