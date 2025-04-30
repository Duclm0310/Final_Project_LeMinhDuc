const mongoose = require("mongoose");
const EnergyUsage = require("../server/models/mongodb/energy_usage.model"); // Import model

require("dotenv").config();

// Kết nối MongoDB
mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("Connected to MongoDB"))
  .catch(err => console.error("Could not connect to MongoDB", err));

let count = 0;
const maxCount = 10;

const insertData = () => {
    if (count >= maxCount) {
        console.log("Insertion completed");
        mongoose.connection.close();
        return;
    }

    const energyData = new EnergyUsage({
        device_id: `device_${count + 1}`,
        energy_used: (Math.random() * 10).toFixed(2), // Random từ 0-10 kWh
        voltage: 220,
        current: (Math.random() * 10).toFixed(2), // Random dòng điện
        frequency: 50,
        power_factor: (Math.random() * 1).toFixed(2) // Random hệ số công suất 0-1
    });

    energyData.save()
        .then(() => console.log(`Inserted data ${count + 1}`))
        .catch(err => console.error("Error inserting data", err));

    count++;
};

// Chạy insertData mỗi 10 giây
const interval = setInterval(insertData, 10000);

// Dừng sau 100 giây
setTimeout(() => clearInterval(interval), 100000);