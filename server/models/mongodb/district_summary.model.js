const mongoose = require("mongoose");

const districtSummarySchema = new mongoose.Schema(
    {
        district: {
            type: String,
            required: true,
        },
        house_ids: {
            type: [String],
        },
        house_count: {
            type: Number,
        },
        total_energy: {
            type: Number,
            required: true,
        },
        average_power: {
            type: Number,
            required: true,
        },
        peak_energy: {
            type: Number,
            required: true,
        },
        downtime_minutes: {
            type: Number,
            default: 0,
        },
        recorded_at: {
            type: Date,
            default: Date.now,
            index: true, // Hỗ trợ truy vấn nhanh theo thời gian
        },
    },
    { timestamps: true }
);

module.exports = mongoose.model("DistrictSummary", districtSummarySchema);
