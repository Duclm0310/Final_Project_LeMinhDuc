class ChartData {
  List<String> xValues;
  List<double> yValues;
  double minY;
  double maxY;
  String? title;
  DateTime date;

  ChartData.empty()
  : xValues = [],
  yValues = [],
  minY = 0,
  maxY = 0,
  title = "",
  date = DateTime.now();

  ChartData({
    required this.xValues,
    required this.yValues,
    required this.minY,
    required this.maxY,
    required this.date,
    this.title,
  });
}

class HouseStatisticData{
  final List<ChartData> dailyData;
  final List<ChartData> monthlyData;

  HouseStatisticData({required this.dailyData, required this.monthlyData});

  HouseStatisticData.empty()
      : dailyData = [],
        monthlyData = [];
}