const jwt = require("jsonwebtoken");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });

const generalAccessToken = async (payload) => {
    if (!payload) {
        throw new Error("payload is required");
    }
    const accessToken = jwt.sign(
        {
            payload,
        },
        process.env.ACCESS_TOKEN,
        { expiresIn: "1h" }
    );

    return accessToken;
};

const generalRefreshToken = async (payload) => {
    if (!payload) {
        throw new Error("payload is required");
    }
    console.log(payload);

    const refreshToken = jwt.sign(
        {
            payload,
        },
        process.env.REFRESH_TOKEN,
        { expiresIn: "7d" }
    );

    return refreshToken;
};

const getResetPasswordToken = async (payload) => {
    if (!payload) {
        throw new Error("payload is required");
    }
    console.log("payload: " + JSON.stringify(payload));
    return jwt.sign(payload, process.env.PASSWORD_RESET_TOKEN, {
        expiresIn: "5m",
    });
};

const provideToken = (token) => {
    return new Promise(async (resolve, reject) => {
        try {
            jwt.verify(token, process.env.REFRESH_TOKEN, async (err, user) => {
                if (err) {
                    return resolve({
                        status: "ERROR",
                        message: "Invalid refresh token",
                    });
                }

                const newAccessToken = await generalAccessToken({
                    id: user.user_id,
                });

                resolve({
                    status: "Success",
                    accessToken: newAccessToken,
                });
            });
        } catch (err) {
            reject({
                status: "Error",
                message: err.message,
            });
        }
    });
};

module.exports = {
    generalAccessToken,
    generalRefreshToken,
    provideToken,
    getResetPasswordToken,
};
