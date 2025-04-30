const notificationService = require("../services/notification.service");
const admin = require("firebase-admin");
const accountService = require("../config/push_notification_key.json");

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(accountService),
    });
}

class NotificationController {
    async createNotification(req, res) {
        try {
            const result = await notificationService.createNotification(req.body);
            res.status(201).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async getNotificationById(req, res) {
        try {
            const result = await notificationService.getNotificationById(req.params.id);
            res.status(result.success ? 200 : 404).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async getAllNotifications(req, res) {
        try {
            const result = await notificationService.getAllNotifications();
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async updateNotification(req, res) {
        try {
            const result = await notificationService.updateNotification(req.params.id, req.body);
            res.status(result.success ? 200 : 404).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async deleteNotification(req, res) {
        try {
            const result = await notificationService.deleteNotification(req.params.id);
            res.status(result.success ? 200 : 404).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async deleteAllNotifications(req, res) {
        try {
            const result = await notificationService.deleteAllNotifications();
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async sendNotification(req, res) {
        try {
            const { fcm_token, title, body, data } = req.body;
            if (!fcm_token) {
                return res.status(400).json({ success: false, message: "FCM token is required" });
            }

            const message = {
                token: fcm_token,
                notification: { title: title || "Default Title", body: body || "Default Body" },
                data: data || {},
            };

            const response = await admin.messaging().send(message);
            res.status(200).json({ success: true, message: "Notification sent successfully", response });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    async getNotificationByUserId(req, res) {
        try {
            const result = await notificationService.getNotificationByUserId(req.params.user_id);
            res.status(result.success ? 200 : 404).json(result);
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }


}

module.exports = new NotificationController();
