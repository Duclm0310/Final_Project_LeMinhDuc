const { DataTypes, UUID } = require("sequelize");

module.exports = (sequelize, schema) => {
    const UserRole = sequelize.define(
        "UserRole",
        {
            user_id: {
                type: DataTypes.UUID,
                allowNull: false,
                primaryKey: true,
                field: "user_id",
            },
            role_id: {
                type: DataTypes.UUID,
                allowNull: false,
                primaryKey: true,
                field: "role_id",
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
            timestamps: true,
            underscored: true,
            tableName: "user_roles",
            schema: schema,
        }
    );

    UserRole.associate = (models) => {
        UserRole.belongsTo(models.User, {
            foreignKey: "user_id",
            as: "user",
        });
        UserRole.belongsTo(models.Role, {
            foreignKey: "role_id",
            as: "role",
        });
    };

    return UserRole;
};
