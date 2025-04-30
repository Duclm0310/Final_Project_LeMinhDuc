import 'package:flutter_riverpod/flutter_riverpod.dart';

final screenDataProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'title': 'Home Page'},
    {'title': 'Energy Statistic'},
    {'title': 'Device Management'},
    {'title': 'House Management'},
    {'title': 'Chatting'},
  ];
});

final homeCardData = Provider<List<Map<String, dynamic>>>((ref){
  return [
    {'title': 'Energy Statistic', 'image': 'assets/images/statistics.png', "pathIndex": 1},
    {'title': 'Devices', 'image': 'assets/images/device-management.png', "pathIndex": 2},
    {'title': 'Houses', 'image': 'assets/images/home-management.png', "pathIndex": 3},
    {'title': 'Family Members', 'image': 'assets/images/family-members.png', "pathIndex": 4},
  ];
});
// TODO: make this provider manage tabs
class HomePageNotifier extends StateNotifier<int> {
  HomePageNotifier() : super(0);

  void changeIndex(int newIndex) {
    state = newIndex;
  }
}

final homePageProvider = StateNotifierProvider<HomePageNotifier, int>((ref) {
  return HomePageNotifier();
});
