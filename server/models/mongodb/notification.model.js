const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
    user_id: { 
        type: String, 
        ref: "User", 
        required: true 
    },
    device_id: { 
        type: String,  
        required: false
    },
    type: { 
        type: String, 
        enum: ["ALERT", "REMINDER", "SUMMARY"], 
        required: true 
    },
    title: { 
        type: String, 
        required: true 
    },
    message: { 
        type: String, 
        required: true 
    },
    status: { 
        type: String, 
        enum: ["UNREAD", "READ"], 
        default: "UNREAD" 
    },
    created_at: { 
        type: Date, 
        default: Date.now 
    }
},
//  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);