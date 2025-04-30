import 'dart:convert';
import 'package:energymanagement/components/models/RoomModel.dart';
import 'package:energymanagement/riverpod/auth_data_provider.dart';
import 'package:energymanagement/riverpod/house_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../riverpod/device_data_provider.dart';
import '../../riverpod/temp_house_provider.dart';
import '../models/HouseModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/device_model.dart';
import 'device_viewmodel.dart';

// class HouseViewModel {
//   String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://localhost:5000';
//   final String apiBaseUrl = "http://10.0.2.2:3001/houses";
//
//   Future<List<HouseModel>> fetchAllHouses(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse("${_baseUrl}/houses"),
//         headers: {"Authorization": "Bearer $token"},
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => HouseModel.fromJson(json)).toList();
//       } else {
//         throw Exception("Failed to fetch houses");
//       }
//     } catch (e) {
//       print("Error fetching houses: $e");
//       return tempHouses;
//     }
//   }
//
//   Future<List<HouseModel>> fetchHousesByUser(
//       String userId, String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse("${_baseUrl}/houses/user/$userId"),
//         headers: {"Authorization": "Bearer $token"},
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => HouseModel.fromJson(json)).toList();
//       } else {
//         throw Exception("Failed to fetch user's houses");
//       }
//     } catch (e) {
//       print("Error fetching houses by user: $e");
//       return [];
//     }
//   }
//
//   Future<bool> addHouse(HouseModel house, String token) async {
//     try {
//       final response = await http.post(
//         Uri.parse("${_baseUrl}/houses"),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token"
//         },
//         body: jsonEncode(house.toJson()),
//       );
//
//       return response.statusCode == 201;
//     } catch (e) {
//       print("Error adding house: $e");
//       return false;
//     }
//   }
//
//   Future<bool> updateHouse(HouseModel updatedHouse, String token) async {
//     try {
//       final response = await http.put(
//         Uri.parse("${_baseUrl}/houses/${updatedHouse.id}"),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token"
//         },
//         body: jsonEncode(updatedHouse.toJson()),
//       );
//
//       return response.statusCode == 200;
//     } catch (e) {
//       print("Error updating house: $e");
//       return false;
//     }
//   }
//
//   Future<bool> deleteHouse(String houseId, String token) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("${_baseUrl}/houses/$houseId"),
//         headers: {"Authorization": "Bearer $token"},
//       );
//
//       return response.statusCode == 200;
//     } catch (e) {
//       print("Error deleting house: $e");
//       return false;
//     }
//   }
// }

class HouseViewModel {
  String _baseUrl = dotenv.env['DEVICE_IP'] != null
      ? "http://${dotenv.env['DEVICE_IP']}:3001"
      : 'https://localhost:3001';
  final Ref ref;

  HouseViewModel(this.ref);

  Future fetchAllHouses() async {
    final token = ref.read(authProvider)?.token;
    final housePvd = ref.read(houseProvider.notifier);
    final userId = ref.read(authProvider)?.userId;
    final deviceProd = ref.read(deviceProvider.notifier);
    // Get Devices by Rooms
    try {
      final houseRes = await http.get(
        Uri.parse("${_baseUrl}/houses/user/${userId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (houseRes.statusCode == 200) {
        final List<HouseModel> houses = (jsonDecode(houseRes.body) as List)
            .map((e) => HouseModel.fromJson(e))
            .toList();
        List<DeviceModel> devicesList = [];
        for (var h in houses) {
          final fetchedRooms = await getRoomForHouse(h.id, token!);
          h.setRooms(fetchedRooms);
          // TODO: Add set devices and store all devices to state provider!
          final devices = await getDevicesByHouse(h.rooms, token);
          devicesList.addAll(devices);
          // if (fetchedRooms.isNotEmpty) {
          //   print(
          //       "House Data: ${h.name}, ${h.ownerId}, ${fetchedRooms[0].name}");
          // }
        }
        deviceProd.setDeviceList(devicesList);
        housePvd.setHouses(houses);
      } else {
        throw Exception("Failed to fetch houses");
      }
    } catch (e) {
      print("Error fetching houses: $e");
    }
  }

  Future<List<RoomModel>> getRoomForHouse(String houseID, String token) async {
    try {
      final roomRes = await http.get(
          Uri.parse("${_baseUrl}/rooms/house/$houseID/rooms"),
          headers: {"Authorization": "Bearer $token"});
      //print("Rooms of house response: ${roomRes.body}");
      final List<RoomModel> rooms = (jsonDecode(roomRes.body) as List)
          .map((e) => RoomModel.fromJson(e))
          .toList();
      //Consider to get devices here!
      return rooms;
    } catch (e) {
      print("Error collecting room: $e");
      return [];
    }
  }

  Future<List<DeviceModel>> getDevicesByHouse(List<RoomModel> rooms, String token) async {
    try{
      final deviceProd = ref.read(deviceViewModelProvider);
      List<DeviceModel> devices = [];
      for(RoomModel r in rooms) {
        final devicesFromRoom = await deviceProd.getDeviceByRoomId(r.id!, token);
        devices.addAll(devicesFromRoom);
      }
      return devices; // List<DeviceModel>
    }catch(e){
      print("Could not get devices while getting houses $e");
      return [];
    }
  }

  Future submitHouse() async {
    final houseData = ref.read(tempHouseProvider);
    final provider = ref.read(houseProvider.notifier);
    final tempHouse = ref.read(tempHouseProvider.notifier);
    final token = ref.read(authProvider)?.token;
    print("Is Edit? ${tempHouse.isEdit}");

    for (var r in houseData.rooms) {
      print("- Room: name=${r.name}, type=${r.roomType}");
    }
    try {
      if (tempHouse.isEdit) {
        // Call API update!
        final updateHouseRes = await http.put(
            Uri.parse("${_baseUrl}/houses/${houseData.id}"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "house_name": houseData.name,
              "house_address": houseData.address
            }));
        if (updateHouseRes.statusCode >= 200 && updateHouseRes.statusCode < 300) {
          final List<RoomModel> currentRooms =
              await getRoomForHouse(houseData.id, token!);
          final updatedRooms = houseData.rooms;
          print(" Room before update: ${currentRooms.length},Rooms updated: ${houseData.rooms.length}");
          final syncRoomStatus = await syncRooms(
              currentRooms: currentRooms,
              updatedRooms: updatedRooms,
              token: token);
          if (syncRoomStatus) {
            print("Update house success!");
            provider.updateHouse(houseData);
          }
        }
      } else {
        // Call API add!
        final addHouseRes = await http.post(Uri.parse("${_baseUrl}/houses"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode({
              "house_name": houseData.name,
              "house_address": houseData.address
            }));
        if ( addHouseRes.statusCode >= 200 && addHouseRes.statusCode < 300) {
          final houseJson = jsonDecode(addHouseRes.body);
          final newHouseId = houseJson['house_id'];
          // Gửi tất cả phòng trong một lần với Future.wait
          await Future.wait(houseData.rooms.map((r) async {
            final response = await http.post(
              Uri.parse("$_baseUrl/rooms"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $token"
              },
              body: jsonEncode({
                "room_name": r.name,
                "room_description": r.roomType,
                "house_id": newHouseId,
              }),
            );
            return response;
          }));
          print("Add house success!");
          final houseWithNewId = houseData.copyWith(id: newHouseId);
          provider.addHouse(houseWithNewId);
        }
      }
      tempHouse.reset();
      fetchAllHouses();
    } catch (e) {
      print("Error submitting house: $e");
    }
  }

  // Could not delete rooms when update house!!!
  Future<bool> syncRooms({
    required List<RoomModel> currentRooms,
    required List<RoomModel> updatedRooms,
    required String token,
  }) async {
    final currentRoomMap = {for (var room in currentRooms) room.id: room};
    final updatedRoomMap = {for (var room in updatedRooms) room.id: room};

    final currentIds = currentRoomMap.keys.toSet();
    final updatedIds = updatedRoomMap.keys.toSet();

    final toDelete = currentIds.difference(updatedIds);
    final toAdd =
        updatedRooms.where((room) => !currentIds.contains(room.id)).toList();

    try {
      // Xóa phòng
      final deleteResponses = await Future.wait(toDelete.map((id) async {
        final res = await http.delete(
          Uri.parse("$_baseUrl/rooms/$id"),
          headers: {
            "Authorization": "Bearer $token",
          },
        );
        return res.statusCode >= 200 && res.statusCode < 300;
      }));

      // Thêm phòng
      final addResponses = await Future.wait(toAdd.map((room) async {
        final res = await http.post(
          Uri.parse("$_baseUrl/rooms"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "room_name": room.name,
            "room_description": room.roomType,
            "house_id": room.house_id,
          }),
        );
        return res.statusCode >= 200 && res.statusCode < 300;
      }));

      final allSuccess =
          [...deleteResponses, ...addResponses].every((success) => success);
      print("Sync rooms complete!");
      return allSuccess;
    } catch (e) {
      print("❌ Sync rooms failed: $e");
      return false;
    }
  }

  Future<bool> deleteHouse(HouseModel deleteHouse) async {
    final token = ref.read(authProvider)?.token;
    try{
      final res = await http.delete(
          Uri.parse("$_baseUrl/houses/${deleteHouse.id}"),
          headers: {
            "Authorization": "Bearer $token",
          }
      );
      if(res.statusCode == 200){
        print("Delete complete!");
        await fetchAllHouses();
        return true;
      }
      return false;
    }catch(e){
      print("Can't delete house, $e");
      return false;
    }
  }
}

final houseViewModelProvider = Provider<HouseViewModel>((ref) {
  return HouseViewModel(ref);
});
