const cron = require("node-cron");
const { dailySummaryQueue } = require("../queue");
const moment = require("moment-timezone");
const{getOrUpdateActiveHouses} = require("../services/redis.service");

async function addHouseSummaryJobs(period) {
    let now = moment().tz("Asia/Ho_Chi_Minh");
    let date;

    switch (period) {
        case "hourly":
            now = now
            // .subtract(1, "hour")
            .startOf("hour");
            date = now.format("YYYY-MM-DDTHH"); // Bao gồm cả giờ
            break;
        case "daily":
            now = now.subtract(1, "day").startOf("day");
            date = now.format("YYYY-MM-DD");
            break;
        case "weekly":
            now = now.subtract(1, "week").startOf("isoWeek");
            date = now.format("YYYY-[W]WW"); // ISO tuần
            break;
        case "monthly":
            now = now.subtract(1, "month").startOf("month");
            date = now.format("YYYY-MM");
            break;
        default:
            console.warn(`[Cron] Unknown period: ${period}`);
            return;
    }


    const houses = await getOrUpdateActiveHouses();

    console.log(`[Cron] Found ${houses.length} houses with active devices`);

    
    for (const house of houses) {
        // const deviceIds = [];

        // if (deviceIds.length > 0) {
        //     console.log(`[Cron] Adding ${period} summary job for house ${house.house_id} (${deviceIds.length} devices) on ${date}`);

            await dailySummaryQueue.add("summary-house-job", {
                house_id: house.house_id,
                period,
                date,
            });
        // }
    }
}


cron.schedule("* * * * *", () => {
    console.log("Run house summary... hourly");
    addHouseSummaryJobs("hourly");
});

cron.schedule("14 0 * * *", () => {
    console.log("Run house summary... daily");
    addHouseSummaryJobs("daily");
});


cron.schedule("20 0 * * 1", () => {
    console.log("Run house summary... weekly");
    addHouseSummaryJobs("weekly");
});

cron.schedule("35 1 1 * *", () => {
    console.log("Run house summary... monthly");
    addHouseSummaryJobs("monthly");
});
