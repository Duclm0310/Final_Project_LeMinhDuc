const redisClient = require("../config/redisClient");
const cron = require("node-cron");
const { Sequelize } = require("sequelize");
const {  House } = require("../models/index");
const { checkCostThresholdQueue } = require("../queue")

async function addCostThresholdJob() {
    const houseIds = await House.findAll({
        attributes: [[Sequelize.fn("DISTINCT", Sequelize.col("house_id")), "house_id"]],
        raw: true
    });
    
    console.log("Houses to process:", houseIds.length);
    for (const house of houseIds) {
        const houseId = house.house_id;
        const existingJobs = await checkCostThresholdQueue.getJobs(["delayed", "waiting"]);
        if (!existingJobs.some(job => job.data.houseId === houseId)) {
            await checkCostThresholdQueue.add("check-threshold", {
                houseId,
            });
            console.log(` Added job to check cost threshold for house ${houseId}`);
        }
    }

}

cron.schedule("* * * * *", async () => {
    console.log(" Check cost threshold ");
    await addCostThresholdJob();
});



