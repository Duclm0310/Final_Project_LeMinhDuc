  import 'package:energymanagement/components/models/HouseModel.dart';
  import 'package:energymanagement/components/models/RoomModel.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/viewmodel/house_viewmodel.dart';

  class HouseNotifier extends StateNotifier<List<HouseModel>>{
    HouseNotifier() : super([]){
      _totalRooms = _calculateTotalRooms();
    }

    int _totalRooms = 0;

    int get totalRooms => _totalRooms;

    int _calculateTotalRooms() {
      return state.fold(0, (sum, house) => sum + house.rooms.length);
    }

    void addHouse(HouseModel house) {
      state = [...state, house];
      _totalRooms = _calculateTotalRooms();
    }

    void setHouses(List<HouseModel> houses){
      state = houses;
      _totalRooms = _calculateTotalRooms();
    }

    void updateHouse(HouseModel updatedHouse) {
      state = [
        for (final house in state)
          if (house.id == updatedHouse.id) updatedHouse else house
      ];
      _totalRooms = _calculateTotalRooms();
    }

    void removeHouse(String houseId) {
      final houseToRemove = state.firstWhere(
            (house) => house.id == houseId,
        orElse: () => HouseModel(
          id: '', name: '', address: '', ownerId: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), rooms: [],
        ),
      );

      if (houseToRemove.id.isNotEmpty) {
        _totalRooms -= houseToRemove.rooms.length;
      }

      state = state.where((house) => house.id != houseId).toList();
    }
  }

  final houseProvider = StateNotifierProvider<HouseNotifier, List<HouseModel>>((ref) => HouseNotifier());
  final selectedHouseProvider = StateProvider<HouseModel?>((ref) => null);
