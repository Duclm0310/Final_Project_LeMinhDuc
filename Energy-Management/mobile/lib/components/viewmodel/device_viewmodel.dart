import 'dart:convert';
import 'dart:developer';
import 'package:energymanagement/components/models/device_model.dart';
import 'package:energymanagement/riverpod/auth_data_provider.dart';
import 'package:energymanagement/riverpod/device_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../riverpod/house_data_provider.dart';

class Device_ViewModel {
  final Ref ref;
  String _baseUrl = dotenv.env['DEVICE_IP'] != null
      ? "http://${dotenv.env['DEVICE_IP']}:3001"
      : 'https://localhost:3001';

  Device_ViewModel(this.ref);

  Future<bool> getDeviceByQr (url) async{
    try {
      final api = Uri.parse(url);
      final response = await http.get(api);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        log("Dữ liệu nhận được: ${jsonData["data"]}");
        DeviceModel newDevice = DeviceModel.fromJson(jsonData["data"]);
        addNewDevice(newDevice);
        return true;
      } else {
        log("API Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Error, cant retrieve data: $e");
      return false;
    }
  }

  // TODO: Fix Get Function here!
  Future<bool> getAllDevice() async {
    try{
      final houses = ref.read(houseProvider);
      final token = ref.read(authProvider)?.token;
      final deviceProd = ref.read(deviceProvider);
      final deviceRes = await http.get(Uri.parse("$_baseUrl/devices"),
          headers: {"Authorization": "Bearer $token"}
      );
      final List<dynamic> deviceData = jsonDecode(deviceRes.body);
      final allRoomIds = houses
          .expand((house) => house.rooms)
          .map((room) => room.id)
          .toSet();

      final devicesInAllHouses = deviceData
          .where((device) => allRoomIds.contains(device["room_id"]))
          .toList();

      for (var d in devicesInAllHouses) {
        print("Device data: $d");
        deviceProd.add(DeviceModel.fromJson(d)); // change to set so that devices wont duplicating
      }
      print("Device list length: ${deviceProd.length}");
      return true;
    }catch(e){
      print("Error getting devices $e");
      return false;
    }
  }

  Future<List<DeviceModel>> getDeviceByRoomId(String id, String token) async {
    try{
      final deviceRes = await http.get(Uri.parse("$_baseUrl/devices"),
          headers: {"Authorization": "Bearer $token"}
      );
      if(deviceRes.statusCode == 200){
        final List<dynamic> deviceData = jsonDecode(deviceRes.body);
        final filteredDevices = deviceData.where((device) {
          return device['room_id'] == id;
        }).toList();
        return filteredDevices
            .map((deviceJson) => DeviceModel.fromJson(deviceJson))
            .toList();
      }
      print("Got no devices data from server!");
      return [];
    }catch(e){
      print("Error while getting devices by room id: $e");
      return [];
    }
  }
  //TODO: Get Device by room id
  // Future GetDevicesByRoomId(){
  //
  // }

  void addNewDevice(DeviceModel newDevice){
    ref.read(deviceProvider.notifier).addDevice(newDevice);
    ref.read(deviceTypeProvider.notifier).addDeviceType(newDevice.deviceType);
  }

  void removeDevice(String id){
    // TODO: remove device and device type

  }

  void toggleDevice(String id){
    // TODO: set device status

  }
}

final deviceViewModelProvider = Provider<Device_ViewModel>((ref){
  return Device_ViewModel(ref);
});