const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const House = sequelize.define(
        "House",
        {
            house_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            house_name: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            district: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            house_address: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            owner_id: {
                type: DataTypes.UUID,
                allowNull: true,
            },
        },
        {
            tableName: "houses",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );

    House.associate = (models) => {
        // one-to-many relationship with Room
        House.hasMany(models.Room, {
            foreignKey: "house_id",
            onDelete: "CASCADE",
        });
        // one-to-many relationship with User
        House.belongsTo(models.User, {
            foreignKey: "owner_id",
            onDelete: "CASCADE",
        });

        // many-to-many relationship with User
        House.belongsToMany(models.User, {
            through: "house_residents",
            as: "Residents",
            foreignKey: "house_id",
            otherKey: "user_id",
            onDelete: "CASCADE",
        });
    };

    return House;
};
