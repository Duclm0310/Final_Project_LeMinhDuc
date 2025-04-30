const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender_id: { type: String, required: true },
  receiver_id: { type: String, required: true }, 
  group_id: { type: String }, 
  content: { type: String, required: true },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Message", messageSchema);