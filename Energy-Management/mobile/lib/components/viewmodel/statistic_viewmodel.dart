import 'dart:convert';
import 'package:energymanagement/components/models/HouseModel.dart';
import 'package:energymanagement/riverpod/house_data_provider.dart';
import 'package:energymanagement/riverpod/house_statistic_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/material.dart';

import '../../riverpod/statistic_data_provider.dart';
import '../models/ChartData.dart';
import '../models/RoomModel.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

Color getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255, // opacity (255 = full opaque)
    random.nextInt(256), // red
    random.nextInt(256), // green
    random.nextInt(256), // blue
  );
}

DateTime parseFlexibleDate(String raw) {
  try {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
      return DateTime.parse(raw); // yyyy-MM-dd
    } else if (RegExp(r'^\d{4}-\d{2}$').hasMatch(raw)) {
      final parts = raw.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1])); // yyyy-MM => set to 1st of month
    } else {
      throw FormatException("Unknown date format: $raw");
    }
  } catch (e) {
    print('⚠️ Date parsing failed: $raw - $e');
    return DateTime.now();
  }
}

class StatisticViewModel {
  final String _baseUrl = dotenv.env['DEVICE_IP'] != null
      ? "http://${dotenv.env['DEVICE_IP']}:3001"
      : 'https://localhost:3001';
  final Ref ref;
  late IO.Socket socket; // 🛜 Socket client

  StatisticViewModel(this.ref) {
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket.io/', // ✅ THÊM DÒNG NÀY!
      'autoConnect': true,
      'forceNew': true, // Optional: luôn tạo mới kết nối
    });

    socket.onConnect((_) {
      print('[Socket] Connected to server!');
      _registerHouseRealtimeUpdates(); // Đăng ký lắng nghe
    });

    socket.onDisconnect((_) => print('[Socket] Disconnected'));
    socket.onError((error) => print('[Socket] Error: $error'));
  }


  void _registerHouseRealtimeUpdates() {
    final houses = ref.read(houseProvider);

    for (final house in houses) {
      final eventKey = 'house:${house.id}:hourly_updated';
      print('[Socket] Listening event: $eventKey');

      socket.on(eventKey, (data) {
        if (data != null) {
          print('[Socket] 🔥 Event received: $data');
          final updatedEnergy = (data['total_energy'] as num).toDouble();
          _updateHouseEnergy(house.id, updatedEnergy);
        }
      });
    }
  }

  void _updateHouseEnergy(String houseId, double newTotalEnergy) {
    final houseStatNotifier = ref.read(houseStatisticProvider.notifier);
    houseStatNotifier.updateHouseEnergy(houseId, newTotalEnergy);
  }

  void dispose() {
    socket.dispose();
  }



  Future FetchHousesEnergyUse() async {
    try {
      final houses = ref.read(houseProvider);
      final statisticNotifier = ref.read(houseStatisticProvider.notifier);
      List<HouseStatistic> allHouseStatistics = [];

      for (final h in houses) {
        final response = await http.get(
          Uri.parse("$_baseUrl/summary/energy-consumption/house/${h.id}"),
        );
        if (response.statusCode >= 200 || response.statusCode < 300){
          final json = jsonDecode(response.body);
          final houseSumData = json["data"];
          print("Got Statistic data: $houseSumData");

          final houseColor = getRandomColor();
          final List contributors = houseSumData["contributors"] ?? [];
          if(contributors.length > 0) {
            final roomList = contributors
                .map<RoomSummaryStatistic>((r) =>
                RoomSummaryStatistic(
                  id: r["roomId"],
                  totalEnergy: r["total_energy"],
                )).toList();

            allHouseStatistics.add(
              HouseStatistic(
                houseMarkColor: houseColor,
                houseName: h.name,
                totalEnergy: houseSumData["totalEnergy"],
                rooms: roomList,
                id: h.id
              ),
            );
          }
          // else{
          //   final roomListRaw = await Future.wait(
          //       h.rooms.map((r) => FetchRoomEnergyUse(r.id!, r.name))
          //   );
          //   final roomList = roomListRaw.whereType<RoomSummaryStatistic>().toList();
          //   allHouseStatistics.add(
          //     HouseStatistic(
          //       houseMarkColor: houseColor,
          //       houseName: h.name,
          //       totalEnergy: houseSumData["totalEnergy"],
          //       rooms: roomList,
          //         id: h.id
          //     ),
          //   );
          // }
        }
      }
      statisticNotifier.setHouseStatisticData(allHouseStatistics);
    } catch (e) {
      print("Can't get houses energy use: $e");
    }
  }

  //TODO: Check missing data of current date somewhere!!
  Future<void> fetchAllChartData() async {
    final houses = ref.read(houseProvider);
    final houseChartData = <String, HouseStatisticData>{};
    final roomChartData = <String, HouseStatisticData>{};

    await Future.wait(houses.map((house) async {
      // Lấy dữ liệu house
      final dailyHouseFuture = http.get(
        Uri.parse("$_baseUrl/summary/house/${house.id}?period=daily"),
      );
      final monthlyHouseFuture = http.get(
        Uri.parse("$_baseUrl/summary/house/${house.id}?period=monthly"),
      );

      final dailyHouseResponse = await dailyHouseFuture;
      final monthlyHouseResponse = await monthlyHouseFuture;
      final List<ChartData> dailyHouseData = dailyHouseResponse.statusCode == 200
          ? convertToChartData({house.name: List<Map<String, dynamic>>.from(jsonDecode(dailyHouseResponse.body))})
          : [];

      final List<ChartData> monthlyHouseData = monthlyHouseResponse.statusCode == 200
          ? convertToChartData({house.name: List<Map<String, dynamic>>.from(jsonDecode(monthlyHouseResponse.body))})
          : [];

      houseChartData[house.id] = HouseStatisticData(
        dailyData: dailyHouseData,
        monthlyData: monthlyHouseData,
      );

      // Lấy dữ liệu room trong house
      final Map<String, List<Map<String, dynamic>>> dailyRoomMap = {};
      final Map<String, List<Map<String, dynamic>>> monthlyRoomMap = {};

      await Future.wait(house.rooms.map((room) async {
        final dailyRoomResponse = await http.get(Uri.parse("$_baseUrl/summary/room/${room.id}?period=daily"));
        final monthlyRoomResponse = await http.get(Uri.parse("$_baseUrl/summary/room/${room.id}?period=monthly"));

        if (dailyRoomResponse.statusCode == 200) {
          dailyRoomMap[room.name] = List<Map<String, dynamic>>.from(jsonDecode(dailyRoomResponse.body));
        }

        if (monthlyRoomResponse.statusCode == 200) {
          monthlyRoomMap[room.name] = List<Map<String, dynamic>>.from(jsonDecode(monthlyRoomResponse.body));
        }

        // Sau khi đã gom xong, bạn chỉ cần gọi:
        final List<ChartData> dailyRoomData = convertToChartData(dailyRoomMap);
        final List<ChartData> monthlyRoomData = convertToChartData(monthlyRoomMap);

        // Lưu vào
        roomChartData[house.id] = HouseStatisticData(
          dailyData: dailyRoomData,
          monthlyData: monthlyRoomData,
        );
      }));

    }));
    print("House status: ${houseChartData}, Room status: ${roomChartData}");
    // Cập nhật state vào Notifier
    ref.read(houseChartDataProvider.notifier).update(houseChartData);
    ref.read(roomChartDataProvider.notifier).update(roomChartData);
  }

  List<ChartData> convertToChartData(Map<String, List<Map<String, dynamic>>> dataPerItem) {
    final List<String> names = dataPerItem.keys.toList();

    int numDays = dataPerItem[names.first]?.length ?? 0;
    List<ChartData> chartDataList = [];

    for (int i = 0; i < numDays; i++) {
      List<double> yValues = [];
      double minY = double.infinity;
      double maxY = double.negativeInfinity;
      DateTime date = DateTime.now();

      for (String name in names) {
        var data = dataPerItem[name]?[i];
        double energy = (data?['total_energy'] ?? 0).toDouble();
        yValues.add(energy);
        if (energy < minY) minY = energy;
        if (energy > maxY) maxY = energy;

        if (name == names.first) {
          date = parseFlexibleDate(data?['period_value']);
        }
      }

      chartDataList.add(
        ChartData(
          xValues: names,
          yValues: yValues,
          minY: minY == double.infinity ? 0 : minY,
          maxY: maxY == double.negativeInfinity ? 0 : maxY,
          date: date,
        ),
      );
    }

    return chartDataList;
  }

  Future<RoomSummaryStatistic?> FetchRoomEnergyUse(String roomId, String roomName) async {
    try{
      final response = await http.get(
        Uri.parse("$_baseUrl/summary/energy-consumption/room/${roomId}"),
      );
      if (response.statusCode == 200){
        final json = jsonDecode(response.body);
        final roomSumData = json["data"];
        final currentRoomData = RoomSummaryStatistic(id: roomName, totalEnergy: roomSumData["totalEnergy"]);
        return currentRoomData;
      }
      return null;
    }catch(e){
      print("Could not get room summary energy use! $e");
      return null;
    }
  }
}

final statisticVMProvider = Provider<StatisticViewModel>((ref){
  return StatisticViewModel(ref);
});