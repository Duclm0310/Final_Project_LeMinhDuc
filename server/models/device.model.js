const { DataTypes } = require("sequelize");
const { underscoredIf } = require("sequelize/lib/utils");

module.exports = (sequelize, schema) => {
    const Device = sequelize.define(
        "Device",
        {
            device_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            room_id: {
                type: DataTypes.UUID,
                allowNull: true,
            },
            device_name: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            device_type: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            device_description: {
                type: DataTypes.STRING,
                allowNull: true,
            },
            status: {
                type: DataTypes.STRING,
                allowNull: false,
                defaultValue: "OFF",
            },
            is_active: {
                type: DataTypes.BOOLEAN,
                allowNull: false,
                defaultValue: false,
            },
            user_id: {
                type: DataTypes.UUID,
                allowNull: true,
            }, //owner
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
            tableName: "devices",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );
    // Device.create({device_id:...})
    Device.associate = (models) => {
        Device.belongsTo(models.Room, {
            foreignKey: "room_id",
            onDelete: "CASCADE",
        });
        Device.belongsTo(models.User, {
            foreignKey: "user_id",
            onDelete: "SET NULL",
        });
    };

    return Device;
};
