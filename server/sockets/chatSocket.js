const Message = require('../models/mongodb/message.model');

const users = {}; // socketId => userId

function setupChatSocket(io) {
  io.on('connection', (socket) => {
    console.log("🔌 New socket connected:", socket.id);

    socket.on('test_message', (data) => {
        console.log('📥 Received from Flutter:', data);
    
        // Gửi lại cho chính socket vừa gửi (hoặc broadcast)
        socket.emit('test_response', {
          from: 'server',
          received: data,
          time: new Date()
        });
      });


    // User join 1-1 hoặc nhóm
    socket.on('join', ({ userId, peerId, groupId }) => {
      if (groupId) {
        socket.join(groupId);
        console.log(`📥 User ${userId} joined group ${groupId}`);
      } else if (peerId) {
        const roomId = [userId, peerId].sort().join('_');
        socket.join(roomId);
        console.log(`📥 User ${userId} joined room ${roomId}`);
      }
      users[socket.id] = userId;
    });

    // Gửi tin nhắn cá nhân
    socket.on('send_private_message', async ({ sender_id, receiver_id, content }) => {
      const roomId = [sender_id, receiver_id].sort().join('_');
      const messageData = {
        sender_id,
        receiver_id,
        content,
        created_at: new Date(),
      };

      try {
        const savedMessage = await Message.create(messageData);
        io.to(roomId).emit('receive_private_message', savedMessage);
        console.log('📤 Private message emitted to', roomId);
      } catch (err) {
        console.error('❌ Error saving private message:', err);
        socket.emit('error_message', { error: 'Could not save private message' });
      }
    });

    // Gửi tin nhắn nhóm
    socket.on('send_group_message', async ({ sender_id, group_id, content }) => {
      const messageData = {
        sender_id,
        group_id,
        content,
        created_at: new Date(),
      };

      try {
        const savedMessage = await Message.create(messageData);
        io.to(group_id).emit('receive_group_message', savedMessage);
        console.log('📤 Group message emitted to group', group_id);
      } catch (err) {
        console.error('❌ Error saving group message:', err);
        socket.emit('error_message', { error: 'Could not save group message' });
      }
    });

    socket.on('disconnect', () => {
      const userId = users[socket.id];
      console.log(`❌ User disconnected: ${socket.id} (${userId})`);
      delete users[socket.id];
    });
  });
}

module.exports = setupChatSocket;
