const cron = require("node-cron");
const { dailySummaryQueue, energySummaryQueue } = require("../queue");
const { House, Room, Device } = require("../models/index");
const { Sequelize } = require("sequelize");
const moment = require("moment-timezone");

// async function getHousesByDistrict(district) {
//     const houses = await House.findAll({
//         where: {
//             district: {
//                 district: `%${district}%`,
//             },
//         },
//     });

//     if (!houses || houses.length === 0) {
//         console.log(`[District Summary] No houses found in district: ${district}`);
//         return null;
//     }

//     console.log(`[District Summary] Found ${houseIds.length} houses in district: ${district}`);
//     return houses;
// }

async function addDistrictSummaryJobs() {
    try {
        const districts = [
            "Cau Giay",
            "Ba Dinh",
            "Dong Da",
            "Hai Ba Trung",
            "Long Bien",
        ]; //etc

        // const now = moment()
        //     .tz("Asia/Ho_Chi_Minh")
        //     .subtract(1, "month")
        //     .startOf("month");
        // const date = now.format("YYYY-MM");

        for (const district of districts) {
            await energySummaryQueue.add("summary-district-job", {
                district: district
            });
        }
    } catch (err) {
        console.error(`Error while creating district summary jobs: ${err}`);
    }
}

cron.schedule("20 7 1 * *", () => {
    console.log("Run district summary... monthly");
    addDistrictSummaryJobs();
});
