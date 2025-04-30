const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const RolePermission = sequelize.define(
        "RolePermission",
        {
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
            tableName: "role_permissions",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    RolePermission.associate = (models) => {
        // Many-to-Many relationship between Role and Permission
        RolePermission.belongsTo(models.Role, {
            foreignKey: "role_id",
            onDelete: "CASCADE",
        });

        RolePermission.belongsTo(models.Permission, {
            foreignKey: "permission_id",
            onDelete: "CASCADE",
        });
    };

    return RolePermission;
};
// role - permission
// [House, Room, Device, Account] - create