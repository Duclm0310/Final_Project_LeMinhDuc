const Notification = require("../models/mongodb/notification.model");

class NotificationService {
    async createNotification(notificationData) {
        try {
            const notification = await Notification.create(notificationData);
            return { success: true, data: notification, message: "Notification created successfully" };
        } catch (error) {
            throw new Error(error.message);
        }
    }

    async getNotificationById(notification_id) {
        const notification = await Notification.findById(notification_id);
        if (!notification) {
            return { success: false, data: null, message: "Notification not found" };
        }
        return { success: true, data: notification, message: "Notification retrieved successfully" };
    }

    async getAllNotifications() {
        const notifications = await Notification.find();
        return { success: true, data: notifications, message: "All notifications retrieved successfully" };
    }

    async updateNotification(notification_id, updateData) {
        const notification = await Notification.findByIdAndUpdate(notification_id, updateData, { new: true });
        if (!notification) {
            return { success: false, data: null, message: "Notification not found" };
        }
        return { success: true, data: notification, message: "Notification updated successfully" };
    }

    async deleteNotification(notification_id) {
        const notification = await Notification.findByIdAndDelete(notification_id);
        if (!notification) {
            return { success: false, data: null, message: "Notification not found" };
        }
        return { success: true, message: "Notification deleted successfully" };
    }

    async deleteAllNotifications() {
        await Notification.deleteMany({});
        return { success: true, message: "All notifications deleted successfully" };
    }

    async getNotificationByUserId(user_id) {
        const notifications = await Notification.find({ user_id });
        return { success: true, data: notifications, message: "Notifications retrieved successfully" };
    }

}

module.exports = new NotificationService();
