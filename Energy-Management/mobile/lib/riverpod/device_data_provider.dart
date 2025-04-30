import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/models/device_model.dart';
import 'package:http/http.dart' as http;

class DeviceNotifier extends StateNotifier<List<DeviceModel>> {
  DeviceNotifier(this.ref) : super([]);

  final Ref ref;

  final List<Map<String, dynamic>> deviceTypeList = [];

  void setDeviceList(List<DeviceModel> devices){
    state = devices;

    final deviceTypeNotifier = ref.read(deviceTypeProvider.notifier);
    // Xóa danh sách device type cũ
    deviceTypeNotifier.clearList();

    // Bổ sung lại theo danh sách devices mới
    for (var device in devices) {
      deviceTypeNotifier.addDeviceType(device.deviceType);
    }
  }

  void addDevice(DeviceModel device) {
    state = [...state, device];
    // Lấy deviceTypeProvider ra
    final deviceTypeNotifier = ref.read(deviceTypeProvider.notifier);
  }

  void removeDevice(DeviceModel device) {
    state = state.where((device) => device.id != device.id).toList();
  }

  void toggleDevice(String id) {
    state = state.map((device) {
      if (device.id == id) {
        device.changeActiveStatus();
      }
    }).cast<DeviceModel>().toList();
  }
}

class DeviceTypeNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  DeviceTypeNotifier() : super([]);

  void addDeviceType(String deviceType) {
    final index = state.indexWhere((item) => item['type'] == deviceType);
    String iconPath="";
    if (index == -1) {
      switch(deviceType){
        case "Smart TV":
          iconPath = "assets/images/Tv-icon.png";
          break;
        case "Smart Light":
          iconPath = "assets/images/Lamp-icon.png";
          break;
        default:
          iconPath = "assets/images/ac-icon.png";
      }
      state = [...state, {'icon': iconPath, 'type': deviceType, 'quantity': 1}];
    } else {
      List<Map<String, dynamic>> updatedList = List.from(state);
      updatedList[index]['quantity'] += 1;
      state = updatedList;
    }
  }

  void removeDeviceType(String deviceType){

  }

  void clearList(){
    state = [];
  }
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, List<DeviceModel>>(
      (ref) => DeviceNotifier(ref),
);

final deviceTypeProvider =
StateNotifierProvider<DeviceTypeNotifier, List<Map<String, dynamic>>>(
      (ref) => DeviceTypeNotifier(),
);
