const Redis = require('ioredis');
const { getIO } = require('./socketServer');

const pub = new Redis();
const sub = new Redis();

function initPubSub() {
  sub.subscribe('realtime-channel', (err) => {
    if (err) {
      console.error("Redis Subcribe Error:", err);
    } else {
      console.log("Redis Subscribed to realtime-channel");
    }
  });

  sub.on('message', (channel, message) => {
    console.log(`[Redis PubSub] Message received: ${message}`);
    const parsed = JSON.parse(message);

    const io = getIO();
    io.emit(parsed.event, parsed.data);
  });
}

function publishEvent(event, data) {
  pub.publish('realtime-channel', JSON.stringify({ event, data }));
}

module.exports = {
  initPubSub,
  publishEvent,
};
