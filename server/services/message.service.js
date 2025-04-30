const Message = require('../models/mongodb/message.model');

const createMessage = async (data) => {
  const message = await Message.create(data);
  return message;
};

const getPersonalMessages = async (user1, user2) => {
  const messages = await Message.find({
    $or: [
      { sender_id: user1, receiver_id: user2 },
      { sender_id: user2, receiver_id: user1 }
    ]
  }).sort({ created_at: 1 });
  return messages;
};

const getGroupMessages = async (groupId) => {
  const messages = await Message.find({ group_id: groupId }).sort({ created_at: 1 });
  return messages;
};

module.exports = {
  createMessage,
  getPersonalMessages,
  getGroupMessages,
};
