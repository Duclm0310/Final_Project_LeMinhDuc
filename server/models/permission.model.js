const { DataTypes, UUID } = require("sequelize");

module.exports = (sequelize, schema) => {
    const Permission = sequelize.define(
        "Permission",
        {
            permission_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            permission_name: {
                type: DataTypes.STRING,
                unique: true,
                allowNull: false,
            },
            permission_description: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            createdAt: {
                type: DataTypes.DATE,
                field: "created_at",
            },
            updatedAt: {
                type: DataTypes.DATE,
                field: "updated_at",
            },
        },
        {
            tableName: "permissions",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    Permission.associate = (models) => {
        // many-to-many relationship with Role
        Permission.belongsToMany(models.Role, {
            through: models.RolePermission,
            foreignKey: "permission_id",
            otherKey: "role_id",
            onDelete: "CASCADE",
        });
        // Explicit association with RolePermission
        Permission.hasMany(models.RolePermission, {
            foreignKey: "permission_id",
            onDelete: "CASCADE",
        });
    };
    return Permission;
};

/* 
List of pre-defined permissions:

create_house
read_house
update_house
delete_house

create_room
read_room
update_room
delete_room

create_device
read_device
update_device
delete_device

create_user
read_user
update_user
delete_user

create_role
read_role
update_role
delete_role
assign_role
unassign_role

create_permission
read_permission
update_permission
delete_permission
assign_permission_to_role
unassign_permission_from_role

create_notification
send_notification
read_notification

*/