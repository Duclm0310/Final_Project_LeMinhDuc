const messageService = require('../services/message.service');

const sendMessage = async (req, res) => {
  try {
    const message = await messageService.createMessage(req.body);
    res.status(201).json(message);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to send message" });
  }
};

const fetchPersonalMessages = async (req, res) => {
  const { user1, user2 } = req.params;
  try {
    const messages = await messageService.getPersonalMessages(user1, user2);
    res.json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch personal messages" });
  }
};

const fetchGroupMessages = async (req, res) => {
  const { groupId } = req.params;
  try {
    const messages = await messageService.getGroupMessages(groupId);
    res.json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch group messages" });
  }
};

module.exports = {
  sendMessage,
  fetchPersonalMessages,
  fetchGroupMessages,
};
