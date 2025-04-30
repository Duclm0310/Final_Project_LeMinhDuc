import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomSummaryStatistic{
  final String id;
  final double totalEnergy;

  RoomSummaryStatistic({required this.id, required this.totalEnergy});
}

class HouseStatistic {
  final String id;
  final String houseName;
  final double totalEnergy;
  final Color houseMarkColor;
  List<RoomSummaryStatistic>? rooms;
  HouseStatistic({required this.houseMarkColor, required this.houseName, required this.totalEnergy, this.rooms, required this.id});
}

class HouseStatisticNotifier extends StateNotifier<List<HouseStatistic>>{
  HouseStatisticNotifier(): super([]);

  void addHouseData(Color houseColor, String houseName, double energyUsed, List<RoomSummaryStatistic> roomsData, String id){
    final house = HouseStatistic(houseMarkColor: houseColor, houseName: houseName, totalEnergy: energyUsed, id: id);
    if(roomsData.isNotEmpty){
      house.rooms = roomsData;
    }
    state = [...state, house];
  }

  void setHouseStatisticData(List<HouseStatistic> houseStatisticList){
    state = houseStatisticList;
  }

  void updateHouseEnergy(String houseId, double newTotalEnergy) {
    state = [
      for (final house in state)
        if (house.id == houseId)
          house.copyWith(totalEnergy: newTotalEnergy)
        else
          house,
    ];
  }

}

final houseStatisticProvider = StateNotifierProvider<HouseStatisticNotifier, List<HouseStatistic>>((ref){
  return HouseStatisticNotifier();
});

extension HouseStatisticCopy on HouseStatistic {
  HouseStatistic copyWith({
    String? houseName,
    double? totalEnergy,
    List<RoomSummaryStatistic>? rooms,
    String? id,
    Color? houseMarkColor,
  }) {
    return HouseStatistic(
      houseName: houseName ?? this.houseName,
      totalEnergy: totalEnergy ?? this.totalEnergy,
      rooms: rooms ?? this.rooms,
      id: id ?? this.id,
      houseMarkColor: houseMarkColor ?? this.houseMarkColor,
    );
  }
}