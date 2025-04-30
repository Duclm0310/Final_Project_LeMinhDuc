const { DataTypes } = require("sequelize");

module.exports = (sequelize, schema) => {
    const AlertThreshold = sequelize.define(
        "AlertThreshold",
        {
            alert_threshold_id: {
                type: DataTypes.UUID,
                defaultValue: DataTypes.UUIDV4,
                primaryKey: true,
                allowNull: false,
            },
            user_id: {
                type: DataTypes.UUID,
                allowNull: true,
                references: {
                    model: {
                        schema,
                        tableName: "users",
                    },
                    key: "user_id",
                },
                onDelete: "CASCADE",
            },
            device_id: {
                type: DataTypes.UUID, // Chỉnh lại UUID thay vì STRING để đồng bộ với bảng Device
                allowNull: false,
                references: {
                    model: {
                        schema,
                        tableName: "devices",
                    },
                    key: "device_id",
                },
                onDelete: "CASCADE",
            },
            max_power: {
                type: DataTypes.INTEGER,
                defaultValue: 2000, // Ngưỡng công suất tối đa (W)
            },
            max_current: {
                type: DataTypes.INTEGER,
                defaultValue: 10, // Ngưỡng dòng điện tối đa (A)
            },
            notify_via: {
                type: DataTypes.JSONB, // JSONB giúp lưu mảng ["EMAIL", "PUSH", "SMS"]
                defaultValue: ["PUSH"],
            },
            createdAt: {
                type: DataTypes.DATE,
                defaultValue: DataTypes.NOW,
            },
            updatedAt: {
                type: DataTypes.DATE,
                allowNull: true,
                defaultValue: DataTypes.NOW,
            },
        },
        {
            tableName: "alert_thresholds",
            schema, // Áp dụng schema nếu có
            timestamps: true, // Thêm timestamps để đồng nhất với các bảng khác
        }
    );

    // Associations (nếu cần)
    AlertThreshold.associate = (models) => {
        AlertThreshold.belongsTo(models.User, {
            foreignKey: "user_id",
            as: "user",
        });

        AlertThreshold.belongsTo(models.Device, {
            foreignKey: "device_id",
            as: "device",
        });
    };

    return AlertThreshold;
};
