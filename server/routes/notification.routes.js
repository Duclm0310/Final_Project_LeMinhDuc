const express = require("express");
const notificationController = require("../controllers/notification.controller");
const router = express.Router();
const { validateNotification } = require("../middlewares/validation");

// GET
router.get("/", notificationController.getAllNotifications);
router.get("/:notification_id", notificationController.getNotificationById);
router.get("/user/:user_id", notificationController.getNotificationByUserId);


// POST
router.post(
    "/",
    // validateNotification,
    notificationController.createNotification
);

router.post(
    "/pushnotification",
    notificationController.sendNotification
);



// UPDATE
router.put(
    "/:notification_id",
    validateNotification,
    notificationController.updateNotification
);

// DELETE
router.delete("/:notification_id", notificationController.deleteNotification);
//router.delete('/notification/', notificationController.deleteAllNotifications);

module.exports = router;
////// DISCUSS ABOUT THE SENDING NOTIFICATION TO USERS //////
