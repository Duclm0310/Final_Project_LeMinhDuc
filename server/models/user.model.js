const { DataTypes, UUID } = require("sequelize");

module.exports = (sequelize, schema) => {
    const User = sequelize.define(
        "User",
        {
            user_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            name: {
                type: DataTypes.STRING,
                allowNull: false,
                unique: false,
            },
            username: {
                type: DataTypes.STRING,
                allowNull: false,
                unique: true,
            },
            password: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            email: {
                type: DataTypes.STRING,
                allowNull: false,
                unique: true,
                validate: {
                    isEmail: true,
                },
            },
            phone: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            address: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            is_verified: {
                type: DataTypes.BOOLEAN,
                allowNull: false,
                defaultValue: false,
            },
            parent_user_id: {
                type: DataTypes.UUID,
                allowNull: true,
                references: {
                    model: "users",
                    key: "user_id",
                },
            },
            createdAt: {
                type: DataTypes.DATE,
                allowNull: false,
                defaultValue: DataTypes.NOW,
            },
            updatedAt: {
                type: DataTypes.DATE,
                allowNull: true,
                defaultValue: DataTypes.NOW,
            },
            deletedAt: {
                type: DataTypes.DATE,
                allowNull: true,
            },
            alert_notifications_enabled: {
                type: DataTypes.BOOLEAN,
                defaultValue: true,
            },
        },
        {
            tableName: "users",
            timestamps: true,
            underscored: true,
            paranoid: true,
            schema: schema,
        }
    );

    // Define associations
    User.associate = (models) => {
        // one-to-many relationship with House
        User.hasMany(models.House, {
            foreignKey: "owner_id",
            as: "OwnedHouses",
            onDelete: "CASCADE",
        });
        User.hasMany(models.Device, {
            foreignKey: "user_id",
            onDelete: "CASCADE",
        });
        // many-to-many relationship with Role
        User.belongsToMany(models.Role, {
            through: "user_roles",
            foreignKey: "user_id",
            otherKey: "role_id",
            onDelete: "CASCADE",
        });
        // many-to-many relationship with House
        User.belongsToMany(models.House, {
            through: "house_residents",
            foreignKey: "user_id",
            otherKey: "house_id",
            as: "ResidentHouses",
            onDelete: "CASCADE",
        });
        // one-to-many relationship with a super user
        User.belongsTo(User, {
            as: "Homeowner",
            foreignKey: "parent_user_id",
            allowNull: true, // A homeowner will have a null parent_user_id
        });
        // many-to-one relationship with a child user/tenant
        User.hasMany(User, {
            as: "Tenants",
            foreignKey: "parent_user_id",
        });
    };

    return User;
};
