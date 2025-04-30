import 'package:energymanagement/components/models/HouseModel.dart';
import 'package:energymanagement/components/models/RoomModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TempHouseNotifier extends StateNotifier<HouseModel> {
  bool isEdit = false;
  TempHouseNotifier()
      : super(
    HouseModel(
      id: DateTime.now().millisecond.toString(),
      name: 'House',
      address: '',
      ownerId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rooms: [],
    ),
  );

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setAddress(String address) {
    state = state.copyWith(address: address);
  }

  void addRoom(RoomModel room) {
    final updatedRooms = [...state.rooms, room];
    state = state.copyWith(rooms: updatedRooms);
  }

  void removeRoomById(String roomId) {
    final updatedRooms = state.rooms.where((r) => r.id != roomId).toList();
    state = state.copyWith(rooms: updatedRooms);
  }

  void updateRoom(RoomModel updatedRoom) {
    final updatedRooms = state.rooms
        .map((r) => r.id == updatedRoom.id ? updatedRoom : r)
        .toList();
    state = state.copyWith(rooms: updatedRooms);
  }

  void setHouse(HouseModel house) {
    isEdit = true;
    state = house;
  }

  void reset() {
    state = HouseModel(
      id: DateTime.now().millisecond.toString(),
      name: 'Home',
      address: '',
      ownerId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rooms: [],
    );
    isEdit = false;
  }
}

final tempHouseProvider =
StateNotifierProvider<TempHouseNotifier, HouseModel>((ref) {
  return TempHouseNotifier();
});