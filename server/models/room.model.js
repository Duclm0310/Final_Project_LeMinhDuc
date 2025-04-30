const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const Room = sequelize.define(
        "Room",
        {
            room_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            room_name: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            room_description: {
                type: DataTypes.STRING,
                allowNull: true,
            },
            room_residents: {
                type: DataTypes.ARRAY(DataTypes.UUID),
                allowNull: true,
            },
            house_id: {
                type: DataTypes.UUID,
                allowNull: false,
            },
        },

        {
            tableName: "rooms",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    Room.associate = (models) => {
        Room.belongsTo(models.House, {
            foreignKey: "house_id",
            onDelete: "CASCADE",
        });
        Room.hasMany(models.Device, {
            foreignKey: "room_id",
            onDelete: "CASCADE",
        });
    };

    return Room;
};
