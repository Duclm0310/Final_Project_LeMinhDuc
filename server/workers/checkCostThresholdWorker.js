const { Worker } = require("bullmq");
const { connection } = require("../queue.js");
const {checkCostThreshold} = require ("../services/alert.service.js");


const costThresholdWorker = new Worker("checkCostThresholdQueue", async (job) => {
    const { houseId } = job.data;
    try {
      console.log(`Processing cost threshold check for house ${houseId}`);
      await checkCostThreshold(houseId);
    } catch (err) {
      console.error(`Error processing cost threshold check for house ${houseId}:`, err);
    }
  }, {
    connection,
    concurrency: 5,
  });

  console.log("[Daily Summary Worker] is running...");
module.exports = costThresholdWorker;