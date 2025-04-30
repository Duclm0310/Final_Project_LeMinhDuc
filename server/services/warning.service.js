const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const accountService = require("../config/push_notification_key.json");
const redisService = require("../services/redis.service");
const redisClient = require("../config/redisClient");
const devicetoken_service = require("../services/devicetoken_service");

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(accountService),
    });
}

const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
        user: process.env.EMAIL_USERNAME,
        pass: process.env.EMAIL_PASSWORD,
    },
});

class WarningService {
    // Gửi thông báo đến Firebase Cloud Messaging (FCM)
    static async sendNotification(token, title, message, data = {}) {
        try {
            console.log("🚀 Đang gửi thông báo...");

            if (!token || typeof token !== "string") {
                throw new Error(`FCM token không hợp lệ: ${JSON.stringify(token)}`);
            }
    
            const notificationMessage = {
                token: token.trim(), 
                notification: { title, body: message },
                data: data,
            };
    
            const response = await admin.messaging().send(notificationMessage);
    
            console.log(`✅ Gửi thông báo thành công đến token: ${token}`);
            return { success: true, response };
        } catch (error) {
            console.error("❌ Gửi thông báo thất bại:", error.message);

            const userId = await redisClient.get("logged_in_user:id");
            if (
                error.message.includes("Requested entity was not found") ||
                error.message.includes("The registration token is not a valid FCM registration token")
            ) {
                console.warn(`⚠️ Token không hợp lệ: ${token}. Đang cập nhật lại Redis...`);
                await devicetoken_service.removeDeviceToken( token);
                await redisService.updateInvalidToken(userId);
            }

            return { success: false, message: error.message };
        }
    }
    

    static async sendEmailNotification(email, title, message) {
        try {
            console.log(`🚀 Đang gửi email tới: ${email}...`);
    
            const mailOptions = {
                from: process.env.EMAIL_USERNAME,
                to: email,
                subject: title,
                text: message,
            };
    
            const info = await transporter.sendMail(mailOptions);
            console.log("✅ Gửi email thành công!", info.response);
            return { success: true, message: "Email sent successfully" };
    
        } catch (error) {
            console.error("❌ Gửi email thất bại:", error.message);

            return { success: false, message: error.message };
        }
    }
}

module.exports = WarningService;
