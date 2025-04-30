const { Worker } = require("bullmq");
const moment = require("moment-timezone");
const EnergyUsage = require("../models/mongodb/energy_usage.model");
const { setDeviceHourlySummary } = require("../services/redis.service");
const { connection } = require("../queue");
const { handleRoomHourlyRealtime } = require("../services/summaryenergyroom.service");
const { handleHouseHourlyRealtime } = require("../services/summaryenergyhouse.service");
const { Device, Room } = require("../models/index");
const { publishEvent } = require('../sockets/redisPubSub'); // 


const realtimeWorker = new Worker(
  "realtimeQueue",
  async (job) => {
    if (job.name !== "realtime-summary") return;

        const { device_id } = job.data;
        if (!device_id) throw new Error("Missing device_id");

        const now = moment().tz("Asia/Ho_Chi_Minh");
        const startOfHour = now.clone().startOf("hour");
        const end = now;

        const hourKey = startOfHour.format("YYYY-MM-DD HH:00:00");

    try {

      const result = await EnergyUsage.aggregate([
        {
          $match: {
            recorded_at: {
              $gte: startOfHour.toDate(),
              $lte: end.toDate(),
            },
            device_id: device_id,
          },
        },
        {
          $group: {
            _id: "$device_id",
            total_energy: { $sum: "$energy_used" },
            average_power: { $avg: "$power" },
            peak_energy: { $max: "$power" },
          },
        },
      ]);

      // 2. Tính downtime
      const telemetryData = await EnergyUsage.aggregate([
        {
          $match: {
            recorded_at: {
              $gte: startOfHour.toDate(),
              $lte: end.toDate(),
            },
            device_id: device_id,
          },
        },
        { $sort: { recorded_at: 1 } },
        {
          $setWindowFields: {
            partitionBy: "$device_id",
            sortBy: { recorded_at: 1 },
            output: {
              prev_time: {
                $shift: {
                  by: -1,
                  output: "$recorded_at"
                },
              },
            },
          },
        },
        {
          $addFields: {
            diff_in_sec: {
              $divide: [
                { $subtract: ["$recorded_at", "$prev_time"] },
                1000,
              ],
            },
          },
        },
        {
          $match: {
            diff_in_sec: { $lte: 900 }, // max 15 phút
          },
        },
        {
          $group: {
            _id: "$device_id",
            total_alive_seconds: { $sum: "$diff_in_sec" },
          },
        }
      ]);

      const total_alive_minutes = telemetryData.length > 0
        ? Math.round(telemetryData[0].total_alive_seconds / 60)
        : 0;

      const downtime_minutes = 60 - total_alive_minutes;

      if (result.length > 0) {
        const data = {
          total_energy: result[0].total_energy,
          average_power: result[0].average_power,
          peak_energy: result[0].peak_energy,
          downtime_minutes,
        };
        await setDeviceHourlySummary(device_id, hourKey, data);

       publishEvent(`house:${device_id}:updated`, {
          hourKey,
          data
      });

        const device = await Device.findByPk(device_id, {
          include: [{ model: Room }],
        });
        if (device && device.Room) {
          const room_id = device.room_id;
          const house_id = device.Room.house_id;

          await handleRoomHourlyRealtime(room_id, hourKey);
          await handleHouseHourlyRealtime(house_id, hourKey);
        }

        console.log(`[Realtime][${device_id}] ✅ Cached summary for ${hourKey}`);
      } else {
        console.log(`[Realtime][${device_id}] ⚠️ No data found`);
      }
    } catch (err) {
      console.error(`[Realtime][${device_id}] ❌`, err);
    }
  },
  { connection, concurrency: 10 }
);

module.exports = realtimeWorker;
