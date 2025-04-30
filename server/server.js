require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const http = require("http"); 

const { initSocket } = require('./sockets/socketServer');
const { initPubSub } = require('./sockets/redisPubSub');


const {
    sequelize,
    connectToMongoDB
} = require("./config");
const errorHandler = require("./middlewares/errorHandler");

// Import routes
const userRoutes = require("./routes/user.routes");
const houseRoutes = require("./routes/house.routes");
const roomRoutes = require("./routes/room.routes");
const deviceRoutes = require("./routes/device.routes");
const permissionRoutes = require("./routes/permission.routes");
const notificationRoutes = require("./routes/notification.routes");
const roleRoutes = require("./routes/role.routes");
const alertThresholdRoutes = require("./routes/alertthreshold.route");
const energyUsageRoutes = require("./routes/energyusage.routes");
const deviceTokenRoutes = require("./routes/devicetoken.route");
const summaryRoutes = require("./routes/summary.routes");
const costThresholdRoutes = require("./routes/costthreshold.route");
const resourcesharingRoutes = require("./routes/resourcesharing.route");
const messageRoutes = require("./routes/message.route");



// Initialize Express app
const app = express();
const port = process.env.SERVER_PORT || 3001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(cookieParser());


// Connect to MongoDB
connectToMongoDB();

sequelize
    .sync({ force: false }) // Set to `force: true` to drop and recreate tables
    .then(() => {
        console.log("Sequelize models synchronized!");
    })
    .catch((err) => {
        console.error("Error syncing Sequelize models:", err);
    });


const server = http.createServer(app);


initSocket(server);   // Khởi tạo socket.io
initPubSub();         // Khởi tạo redis pub/sub




// Mounting Routers
app.use("/users", userRoutes);
app.use("/houses", houseRoutes);
app.use("/rooms", roomRoutes);
app.use("/devices", deviceRoutes);
app.use("/permissions", permissionRoutes);
app.use("/notifications", notificationRoutes);
app.use("/roles", roleRoutes);
app.use("/alertthresholds", alertThresholdRoutes);
app.use("/energyusages", energyUsageRoutes);
app.use("/devicetokens", deviceTokenRoutes);
app.use("/summary", summaryRoutes);
app.use("/costthresholds", costThresholdRoutes);
app.use("/resourcesharing", resourcesharingRoutes);
app.use("/chat", messageRoutes);

// Mounting custom error handler
// app.use(errorHandler);


//worker

// require("./workers/telemetryWorker");
// require("./jobs/telemetryProducer");

// require("./workers/dailySummaryWorkerHouse");
// require("./jobs/dailyEnergySummaryHouse");


// require("./workers/dailySummaryWorkerRoom");
// require("./jobs/dailyEnergySummaryRoom");

// require("./workers/dailySummaryWorkerDevice");
// require("./workers/energySummaryWorker");


// require("./workers/realtimeSummaryWorker");
// require("./jobs/dailyEnergySummaryDevice");

// require("./workers/deviceWorker");
// require("./jobs/checkDeviceStatus");


// require("./workers/checkCostThresholdWorker");
// require("./jobs/checkCostThreshold");


require("./workers/notification.worker");

// Start the server
// app.listen(port, () => {
//     console.log(`Server is running on port ${port}`);
// });
server.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });

