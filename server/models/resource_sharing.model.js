const { DataTypes, UUID } = require("sequelize");

module.exports = (sequelize, schema) => {
    const ResourceSharing = sequelize.define(
        "ResourceSharing",
        {
            id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
            },
            owner_id: {
                type: DataTypes.UUID,
                allowNull: false,
                onDelete: "CASCADE",
            }, 
            user_id: {
                type: DataTypes.UUID,
                allowNull: false,
                onDelete: "CASCADE",
            },
            resource_type: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            resource_id: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            role_id: {
                type: DataTypes.UUID,
                allowNull: false,
            }
        },
        {
            tableName: "resource_sharing",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    ResourceSharing.associate = (models) => {
        ResourceSharing.belongsTo(models.User, {
            as: "Owner",
            foreignKey: "owner_id",
        });
        ResourceSharing.belongsTo(models.User, {
            as: "User",
            foreignKey: "user_id",
        });
        ResourceSharing.belongsTo(models.Role, {
            as: "Role",
            foreignKey: "role_id",
        });
        ResourceSharing.belongsTo(models.RolePermission, {
            foreignKey: 'role_id',
            as: 'RolePermissions',
        });
    };

    return ResourceSharing;
};
