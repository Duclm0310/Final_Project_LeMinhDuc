const cron = require("node-cron");
const {dailySummaryQueue} = require("../queue");
const moment = require('moment-timezone');
const {getOrUpdateActiveRooms, buildRoomDevices} = require("../services/redis.service");
const redisClient = require("../config/redisClient");


async function addRoomSummaryJobs(period) {
    let now = moment().tz("Asia/Ho_Chi_Minh");
    let date;

    switch (period) {
        case "hourly":
            now = now
            // .subtract(1, "hour")
            .startOf("hour");
            date = now.format("YYYY-MM-DD HH:00:00");
            break;
        case "daily":
            now = now.subtract(1, "day").startOf("day");
            date = now.format("YYYY-MM-DD");
            break;
        case "weekly":
            now = now.subtract(1, "week").startOf("isoWeek");
            date = now.format("YYYY-[W]WW");
            break;
        case "monthly":
            now = now.subtract(1, "month").startOf("month");
            date = now.format("YYYY-MM");
            break;
        default:
            console.warn(`[Cron] Unknown period: ${period}`);
            return;
    }

    const rooms = await getOrUpdateActiveRooms();
    console.log(`[Cron] Found ${rooms.length} rooms with active devices`);

    const jobs = [];

    for (const room of rooms) {
        let deviceIds = await redisClient.smembers(`room:${room.room_id}:devices`);

        if (!deviceIds || deviceIds.length === 0) {
            console.warn(`[Cron] Room ${room.room_id} has no devices in cache, rebuilding...`);
            await buildRoomDevices(room.room_id);
            deviceIds = await redisClient.smembers(`room:${room.room_id}:devices`);
        }

        if (!deviceIds || deviceIds.length === 0) {
            console.warn(`[Cron] Room ${room.room_id} still has no devices after rebuild, skipping...`);
            continue;
        }

        console.log(`[Cron] Adding ${period} summary job for room ${room.room_id} (${deviceIds.length} devices) for date ${date}`);

        jobs.push(dailySummaryQueue.add("summary-room-job", {
            room_id: room.room_id,
            device_ids: deviceIds,
            period,
            date,
        }));
    }

    await Promise.all(jobs);
}

cron.schedule("* * * * *", () => {
    console.log("Run report date... hourly");
    addRoomSummaryJobs("hourly"); // mỗi giờ
});

cron.schedule("12 0 * * *", () => {
    console.log("Run report date... daily");
    addRoomSummaryJobs("daily"); // mỗi ngày lúc 00:05
});

cron.schedule("17 0 * * 1", () => {
    // cron.schedule("* * * * *", () => {
    console.log("Run report date... weekly");
    addRoomSummaryJobs("weekly"); // thứ 2 hàng tuần lúc 00:10
});

cron.schedule("30 1 1 * *", () => {
    console.log("Run report date... monthly" );
    addRoomSummaryJobs("monthly"); // ngày đầu mỗi tháng lúc 01:15
});


console.log("Scheduler is running...");
