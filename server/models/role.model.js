const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const Role = sequelize.define(
        "Role",
        {
            role_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            role_name: {
                type: DataTypes.STRING,
                unique: true,
                allowNull: false,
            },
            role_description: {
                type: DataTypes.STRING,
                allowNull: true,
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
            tableName: "roles",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    Role.associate = (models) => {
        // many-to-many relationship with Permission
        Role.belongsToMany(models.Permission, {
            through: models.RolePermission,
            foreignKey: "role_id",
            otherKey: "permission_id",
            onDelete: "CASCADE",
        });
        // Explicit association with RolePermission
        Role.hasMany(models.RolePermission, {
            foreignKey: "role_id",
            onDelete: "CASCADE",
        });
        // many-to-many relationship with User
        Role.belongsToMany(models.User, {
            through: "user_roles",
            foreignKey: "role_id",
            otherKey: "user_id",
            onDelete: "CASCADE",
        });
    };

    return Role;
};

/* 
1 số role fix cứng:
- homeowner: cho tất cả quyền trong nhà
- admin: cho tất cả quyền trong hệ thống
- guest: cho permission read
- resident: cho permission đọc trong nhà
- manager: cho quyền quản lý thiết bị trong nhà

*/
