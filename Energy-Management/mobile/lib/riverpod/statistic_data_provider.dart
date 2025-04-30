import 'package:energymanagement/components/models/ChartData.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimePeriod { day, month }

final selectedPeriodProvider =
    StateProvider<TimePeriod>((ref) => TimePeriod.day);

final statisticsProvider = StateProvider<Map<String, dynamic>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  return _getStatistics(period);
});

Map<String, dynamic> _getStatistics(TimePeriod period) {
  switch (period) {
    case TimePeriod.day:
      return {
        'energyUsed': 1.276,
        'change': -0.131,
        'changePercent': 9,
        'isIncrease': false,
        'stats': [
          {'value': 1.276, 'label': 'Today'},
          {'value': 30.276, 'label': 'This month'},
          {'value': 398.0, 'label': 'All time'},
        ],
      };
    case TimePeriod.month:
      return {
        'energyUsed': 30.276,
        'change': -2.131,
        'changePercent': 14,
        'isIncrease': false,
        'stats': [
          {'value': 1.276, 'label': 'Today'},
          {'value': 30.276, 'label': 'This month'},
          {'value': 398.0, 'label': 'All time'},
        ],
      };
  }
}

class HouseDetailChartDataNotifier extends StateNotifier<Map<String, HouseStatisticData>> {
  HouseDetailChartDataNotifier() : super({});

  void update(Map<String, HouseStatisticData> newData) {
    state = newData;
  }
}

class RoomDetailChartDataNotifier extends StateNotifier<Map<String, HouseStatisticData>> {
  RoomDetailChartDataNotifier() : super({});
  void update(Map<String, HouseStatisticData> newData) {
    state = newData;
  }
}

final houseChartDataProvider =
StateNotifierProvider<HouseDetailChartDataNotifier, Map<String, HouseStatisticData>>(
      (ref) => HouseDetailChartDataNotifier(),
);

final roomChartDataProvider =
StateNotifierProvider<RoomDetailChartDataNotifier, Map<String, HouseStatisticData>>(
      (ref) => RoomDetailChartDataNotifier(),
);

final selectedHouseDetail = StateProvider<String>((ref)=>"");
