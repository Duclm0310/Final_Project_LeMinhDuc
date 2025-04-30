const mongoose = require("mongoose");
const DeviceLog = require("../server/models/mongodb/device.log.model"); // Import model
require("dotenv").config();

// Kết nối MongoDB
mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("Connected to MongoDB"))
  .catch(err => console.error("Could not connect to MongoDB", err));

let count = 0;
const maxCount = 10;

const insertData = async () => {
    if (count >= maxCount) {
        console.log("Insertion completed");
        mongoose.connection.close();
        return;
    }

    const statusOptions = ["ON", "OFF", "ERROR"];
    const deviceLog = new DeviceLog({
        device_id: `device_${count + 1}`,
        status: statusOptions[Math.floor(Math.random() * statusOptions.length)],
        message: "Auto-generated log entry",
    });

    try {
        await deviceLog.save();
        console.log(`Inserted log ${count + 1}`);
    } catch (err) {
        console.error("Error inserting log", err);
    }

    count++;
};

setInterval(insertData, 5000);
setTimeout(() => clearInterval(interval), 50000);
