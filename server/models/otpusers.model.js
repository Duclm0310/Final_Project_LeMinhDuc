const { allow } = require("joi");
const { DataTypes, UUID } = require("sequelize");

module.exports = (sequelize, schema) => {
    const OtpUser = sequelize.define(
        "OtpUser",
        {
            email: {
                type: DataTypes.STRING,
                allowNull: false,
                unique: true,
                validate: {
                    isEmail: true,
                },
            },
            user_id: {
                type: DataTypes.UUID,
                allowNull: false,
            },
            otp: {
                type: DataTypes.STRING,
                allowNull: false,
            },
            expires_at: {
                type: DataTypes.DATE,
                allowNull: false,
            },
        },
        {
            timestamps: false,
            underscored: true,
            tableName: "otpusers",
            schema: schema,
        }
    );
    return OtpUser;
};
