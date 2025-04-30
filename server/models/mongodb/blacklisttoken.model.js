const mongoose = require("mongoose");

const BlacklistTokenSchema = new mongoose.Schema({
    token: { type: String, required: true, unique: true },
    createdAt: { type: Date, default: Date.now, expires: "7d" } // Token tự động xóa sau 7 ngày
});

module.exports = mongoose.model("BlacklistToken", BlacklistTokenSchema);
