const nodemailer = require("nodemailer");
require("dotenv").config();
const { User, OtpUser } = require("../models/index");
const { BaseError,
    BadRequestError,
    NotFoundError,
    UnauthorizedError,
    ValidationError,
    ForbiddenError,
    ConflictError, } = require("../utils/errors/index");

const sendOtp = async (email, otp = null) => {
    try {
        const user = await User.findOne({ where: { email: email } });
        if (!user) {
            throw new NotFoundError("User not found");
        }

        if (!otp) {
            otp = generateOtp();
        }

        await OtpUser.destroy({ where: { email: email } });

        await OtpUser.create({
            email,
            otp,
            user_id: user.user_id,
            expires_at: new Date(Date.now() + 5 * 60 * 1000),
        });

        await sendOtpEmail(email, otp);
        result = {
            status: "Success",
            message: "OTP has been sent successfully!",
            email: email,
            otp: otp,
        };
        console.log(result);
        return {
            status: "Success",
            message: "OTP has been sent successfully!",
            email: email,
            otp: otp,
        };
    } catch (err) {
        console.error("Error sending OTP: ", err.message);
        throw err;
    }
};

const resendOtp = async (email) => {
    try {
        const existingOtp = await OtpUser.findOne({
            where: { email: email },
        });

        if (!existingOtp) {
            throw new Error("No OTP exists for this user.");
        }

        const currentTime = new Date();
        const otpCreatedAt = new Date(existingOtp.createdAt);
        const timeDiff = currentTime - otpCreatedAt;

        if (timeDiff < 1 * 60 * 1000) {
            console.log("Existing OTP: ", existingOtp.dataValues);
            throw new Error(
                "You must wait at least 1 minute before requesting a new OTP."
            );
        }

        sendOtp(email);
    } catch (err) {
        console.error("Error resending OTP: ", err.message);
        throw new Error(err);
    }
};

const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
        user: process.env.EMAIL_USERNAME,
        pass: process.env.EMAIL_PASSWORD,
    },
});

const generateOtp = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

const sendOtpEmail = async (email, otp) => {
    console.log("email: ", email, "otp:", otp)
    try {
        const mailOptions = {
            from: process.env.EMAIL_USERNAME,
            to: email,
            subject: "Xác nhận tài khoản của bạn",
            text: `Mã OTP của bạn là: ${otp}. Mã này có hiệu lực trong 5 phút.`,
        };

        await transporter.sendMail(mailOptions);
    } catch (err) {
        console.error("Error sending email:", err.message);
        throw err;
    }
};

const verifyOtp = async (email, otp) => {
    const otpRecord = await OtpUser.findOne({
        where: { email: email, otp: otp },
    });

    if (!otpRecord || otpRecord.expires_at < new Date()) {
        return false;
    }

    await OtpUser.destroy({ where: { email: email } });

    return true;
};

module.exports = { sendOtp, resendOtp, verifyOtp, generateOtp, sendOtpEmail };
