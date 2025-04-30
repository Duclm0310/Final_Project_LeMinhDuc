const IORedis = require('ioredis');

const redisClient = new IORedis({
    host: 'localhost', // Nếu chạy trong Docker, dùng 'my-redis'
    port: 6379,
    password: process.env.REDIS_PASSWORD || "", // Nếu Redis có mật khẩu
    maxRetriesPerRequest: null, // Tránh lỗi reconnect liên tục
});

redisClient.on('connect', () => {
    console.log("🚀 Redis Connected!");
});

redisClient.on('error', (err) => {
    console.error("❌ Redis Error:", err);
});

module.exports = redisClient;
