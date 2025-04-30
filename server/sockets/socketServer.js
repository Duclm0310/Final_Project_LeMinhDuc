const { Server } = require('socket.io');
const setupChatSocket = require('./chatSocket');

let io = null;

function initSocket(server) {
  io = new Server(server, {
    cors: {
      origin: "*", 
    }
  });


  setupChatSocket(io); 

  io.on('connection', (socket) => {
    console.log("Socket.IO client connected:", socket.id);

    socket.on('disconnect', () => {
      console.log("Socket.IO client disconnected:", socket.id);
    });
  });

  return io;
}

function getIO() {
  if (!io) throw new Error("Socket.IO not initialized");
  return io;
}

module.exports = {
  initSocket,
  getIO,
};




// const { Server } = require('socket.io');

// let io = null;
// const users = {}; // map: socketId => userId

// function initSocket(server) {
//   io = new Server(server, {
//     cors: {
//       origin: "*",
//       methods: ["GET", "POST"],
//     },
//   });

//   io.on('connection', (socket) => {
//     console.log("⚡ User connected:", socket.id);

//     socket.on('join', ({ userId, peerId }) => {
//       const roomId = [userId, peerId].sort().join('_');
//       socket.join(roomId);
//       users[socket.id] = userId;
//       console.log(`${userId} joined room ${roomId}`);
//     });

//     socket.on('send_message', ({ from, to, content }) => {
//       const roomId = [from, to].sort().join('_');
//       const message = { from, to, content, timestamp: new Date() };

//       io.to(roomId).emit('receive_message', message);
//       console.log('💬 Message sent in room', roomId, ':', message);
//     });

//     socket.on('disconnect', () => {
//       const userId = users[socket.id];
//       console.log(`❌ User disconnected: ${socket.id} (${userId})`);
//       delete users[socket.id];
//     });
//   });

//   return io;
// }

// function getIO() {
//   if (!io) throw new Error("Socket.IO not initialized");
//   return io;
// }

// module.exports = {
//   initSocket,
//   getIO,
// };
