const { Room, Device, House } = require("./models/index"); 
const { buildRoomDevices,
    rebuildHouseCache, } = require("./services/redis.service");

async function syncAllRedisMappings() {
    console.log("🚀 Bắt đầu sync toàn bộ Redis mapping...");

    const houses = await House.findAll({ attributes: ["house_id"] });

    for (const house of houses) {
        const houseId = house.house_id;

        console.log(`\n🏠 Sync cache cho house: ${houseId}`);
        await rebuildHouseCache(houseId);

        // Lấy room_ids của nhà
        const rooms = await Room.findAll({ where: { house_id: houseId } });

        for (const room of rooms) {
            const roomId = room.room_id;
            await buildRoomDevices(roomId);
        }
    }

    console.log("\n🎉 Đã sync xong toàn bộ Redis cache từ DB!");
    process.exit(0);
}

syncAllRedisMappings().catch((err) => {
    console.error("❌ Lỗi khi sync Redis:", err);
    process.exit(1);
});

/* 
Tạo 1 route để trigger tạo mapping cho house device room trên redis.
Route này sẽ chạy khi người dùng ứng dụng truy cập vào thông tin của house/room/device.
*/