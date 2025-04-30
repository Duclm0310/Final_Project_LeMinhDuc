const summaryService = require("../services/summary.service");

exports.getDeviceSummary = async (req, res) => {
  const { deviceId } = req.params;
  const { period = "hourly", limit = 24 } = req.query;
  try {
    const result = await summaryService.getSummary("device", deviceId, period, Number(limit));
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getRoomSummary = async (req, res) => {
  const { roomId } = req.params;
  const { period = "daily", limit = 7 } = req.query;
  try {
    const result = await summaryService.getSummary("room", roomId, period, Number(limit));
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.getHouseSummary = async (req, res) => {
  const { houseId } = req.params;
  const { period = "monthly", limit = 6 } = req.query;
  try {
    const result = await summaryService.getSummary("house", houseId, period, Number(limit));
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// API cho tiền điện
exports.getElectricityCost = async (req, res) => {
  const { level, id } = req.params;
  const { period = "hourly", start, end } = req.query;

  try {
    const data = await summaryService.getElectricityCost(level, id, period, start, end);
    res.json({ success: true, data });
  } catch (err) {
    console.error("[Electricity Cost Controller]", err);
    res.status(500).json({ success: false, message: err.message });
  }
};


// contribute for house
exports.getHouseEnergyConsumption = async (req, res) => {
  const { houseId } = req.params;
  const { period = "monthly", start, end } = req.query;

  try {
    const data = await summaryService.getHouseSummaryData(houseId, period, start, end);
    res.json({ success: true, data });
  } catch (err) {
    console.error("[House Energy Consumption Controller]", err);
    res.status(500).json({ success: false, message: err.message });
  }
};


exports.getRoomEnergyConsumption = async (req, res) => {
  const { roomId } = req.params;
  const { period = "monthly", start, end } = req.query;

  try {
    const data = await summaryService.getRoomSummaryData(roomId, period, start, end);
    res.json({ success: true, data });
  } catch (err) {
    console.error("[Room Energy Consumption Controller]", err);
    res.status(500).json({ success: false, message: err.message });
  }
};