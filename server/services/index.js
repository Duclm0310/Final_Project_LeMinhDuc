const User = require("./User");
const House = require("./House");
const Room = require("./Room");
const Device = require("./Device");
const Notification = require("./Notification");
const Role = require("./Role");
const Permission = require("./Permission");
const RolePermission = require("./RolePermission");

const models = {
    User,
    House,
    Room,
    Device,
    Notification,
    Role,
    Permission,
    RolePermission,
};

// call associate function for each model
Object.values(models).forEach((model) => {
    if (model.associate) {
        model.associate(models);
    }
});

module.exports = { ...models };
