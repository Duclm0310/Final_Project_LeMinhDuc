import 'package:energymanagement/components/models/RoomModel.dart';
import 'package:energymanagement/components/models/device_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedRoomProvider = StateProvider<RoomModel?>((ref) => null);

class DeviceInRoomNotifier extends StateNotifier<List<DeviceModel>>{
  DeviceInRoomNotifier() : super([]);

  void addDevice(DeviceModel newDevice){
    state = [...state, newDevice];
  }

  void setDevices(List<DeviceModel> devices){
    state = devices;
  }

  void removeDevice(DeviceModel selectedDevice){
    // final deviceToRemove = state.firstWhere(
    //       (d) => d.id == selectedDevice.id
    // );

    // if(deviceToRemove.id.isNotEmpty){
      state = state.where((d) => d.id != selectedDevice.id).toList();
    // }
  }
}

final deviceInRoomProvider = StateNotifierProvider<DeviceInRoomNotifier, List<DeviceModel>>((ref) => DeviceInRoomNotifier());