const { Worker } = require("bullmq");
const { connection } = require("../queue.js");
const { House, EnergySummary } = require("../models/index");
const { Op } = require("sequelize");
const redisClient = require("../config/redisClient");
const DistrictSummary = require("../models/mongodb/district_summary.model");

const worker = new Worker(
    "district-summary",
    async (job) => {
        if (job.name === "summary-district-job") {
            try {
                const start = moment()
                    .tz("Asia/Ho_Chi_Minh")
                    .subtract(1, "month")
                    .startOf("month");
                const end = moment(start).endOf("month");

                const { district } = job.data;
                console.log(
                    `[Worker] Processing summary for district ${district}`
                );

                const houses = await House.findAll({
                    where: {
                        district: {
                            [Op.like]: `%${district}%`,
                        },
                    },
                });

                const houseIds = houses.map((house) => house.house_id);

                const housesMonthlyData = await EnergySummary.findAll({
                    where: {
                        reference_id: { [Op.in]: houseIds },
                        summary_level: "house",
                        period_type: "monthly",
                        period_value: {
                            [Op.between]: [
                                start.format("YYYY-MM-DD"),
                                end.format("YYYY-MM-DD"),
                            ],
                        },
                    },
                    raw: true,
                });

                const total_energy = housesMonthlyData.reduce((sum, row) => sum + (row.total_energy || 0), 0);
                const average_power = housesMonthlyData.length === 0 ? 0 :
                    housesMonthlyData.reduce((sum, row) => sum + (row.average_power || 0), 0) / housesMonthlyData.length;
                const peak_energy = housesMonthlyData.length === 0 ? 0 :
                    Math.max(...housesMonthlyData.map(row => row.peak_energy || 0));
                const downtime_minutes = housesMonthlyData.reduce((sum, row) => sum + (row.downtime_minutes || 0), 0);
                const house_count = houseIds.length;

                await DistrictSummary.create({
                    district,
                    house_ids: houseIds,
                    house_count,
                    total_energy,
                    average_power,
                    peak_energy,
                    downtime_minutes,
                });

                await redisClient.set(
                    `district_summary_${district}_${start.format("YYYY-MM")}`,
                    JSON.stringify({
                        district,
                        house_ids: houseIds,
                        house_count,
                        total_energy,
                        average_power,
                        peak_energy,
                        downtime_minutes,
                    }),
                    "EX",
                    3600 * 24 * 30
                );
            } catch (err) {
                console.error(`[Worker] Error processing job: ${err.message}`);
            }
        }
    },
    { connection }
);

worker.on("failed", (job, err) => {
    console.error(`[Worker] Job ${job.id} failed with error: ${err.message}`);
});
