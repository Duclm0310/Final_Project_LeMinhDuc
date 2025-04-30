const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const EnergySummary = sequelize.define(
        "EnergySummary",
        {
            summary_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            reference_id: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            summary_level: {
                type: DataTypes.ENUM("device", "room", "house"),
                allowNull: false,
            },
            period_type: {
                type: DataTypes.ENUM("hourly", "daily", "weekly", "monthly"),
                allowNull: false,
            },
            period_value: {
                type: DataTypes.STRING, // "2024-04-01" (ngày), "2024-W14" (tuần), "2024-04" (tháng)
                allowNull: false,
            },
            total_energy: {
                type: DataTypes.FLOAT,
                allowNull: false,
                defaultValue: 0,
            },
            average_power: {
                type: DataTypes.FLOAT,
                validate: {
                    min: 0, // Giới hạn giá trị dương
                },
            },
            peak_energy: {
                type: DataTypes.FLOAT,
                validate: {
                    min: 0,
                },
            },
            downtime_minutes: {
                type: DataTypes.INTEGER,
                allowNull: true,
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
            tableName: "energy_summary",
            timestamps: true,
            underscored: true,
            schema: schema,
            indexes: [
                {
                    fields: ["reference_id", "period_type", "period_value"],
                    unique: true,
                },
                { fields: ["period_value"] },
                { fields: ["summary_level"] }, // Nếu bạn thường xuyên query theo level
            ],
        }
    );

    return EnergySummary;
};
