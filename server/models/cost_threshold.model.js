const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const CostThreshold = sequelize.define(
        "CostThreshold",
        {
            cost_threshold_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            house_id: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            threshold_cost: {
                type: DataTypes.FLOAT,
                allowNull: false,
                defaultValue: 0,
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
            tableName: "cost_thresholds",
            timestamps: true,
            underscored: true,
            schema: schema,
        }
    );
    CostThreshold.associate = (models) => {
        CostThreshold.belongsTo(models.House, {
            foreignKey: "house_id",
            onDelete: "CASCADE",
            as: "house",
        });

    };
    
    return CostThreshold;
};
