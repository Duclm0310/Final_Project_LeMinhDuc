const otpService = require("../services/otp.service");

// Send OTP for the first time
const sendOtp = async (req, res, next) => {
    try {
        const { email } = req.body;

        const result = await otpService.sendOtp(email);

        res.status(200).json(result);
    } catch (error) {
        console.error("Error sending OTP: ", error);
        next(err);
    }
};

// Resend OTP
const resendOtp = async (req, res, next) => {
    try {
        const { email } = req.body;

        const result = await otpService.resendOtp(email);

        res.status(200).json(result);
    } catch (error) {
        console.error("Error resending OTP: ", error);
        next(err);
    }
};

module.exports = { sendOtp, resendOtp };
