const mongoose = require("mongoose");

const energyUsageSchema = new mongoose.Schema({
    device_id: { 
        type: String,  // UUID hoặc ID của thiết bị 
        required: true, 
        index: true 
    },
    energy_used: { 
        type: Number,  // Đơn vị kWh 
        required: true 
    },
    voltage: { 
        type: Number, // Điện áp (V) 
        required: true 
    },
    current: { 
        type: Number, // Dòng điện (A) 
        required: true 
    },
    power: { 
        type: Number, // Công suất tức thời (W), có thể tính lại nếu cần 
        default: function () { return this.voltage * this.current; } 
    },
    // frequency: { 
    //     type: Number, // Tần số (Hz), cần thiết nếu có AC điện 
    //     default: 50 
    // },
    // power_factor: { 
    //     type: Number, // Hệ số công suất, giúp xác định hiệu quả sử dụng điện
    //     default: 1 
    // },
    recorded_at: { 
        type: Date, 
        default: Date.now, 
        index: true // Hỗ trợ truy vấn nhanh theo thời gian 
    }
}, { timestamps: true });

module.exports = mongoose.model("EnergyUsage", energyUsageSchema);
