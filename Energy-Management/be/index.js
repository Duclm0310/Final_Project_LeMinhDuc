require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log("Server running on port 5000");
});

app.use(cors());
app.use(express.json());

//Connect to DB
mongoose
  .connect(process.env.MONGO_URI, { dbName: "energy_management" })
  .then(() => console.log("✅ MongoDB Connected - DB: energy_management"))
  .catch((err) => console.error("❌ MongoDB Error:", err));

app.use("/devices", require("./routes/DeviceRoute"));

app.use("/api/devicelogs", require("./routes/DeviceLogRoute"));

app.use("/users", require("./routes/UserRoute"));

app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
});
