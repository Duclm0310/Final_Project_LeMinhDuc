import 'dart:convert';
import 'package:energymanagement/components/models/UserModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/NotificationModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationViewModel {
  String _baseUrl =
      dotenv.env['DEVICE_IP'] != null ? "http://${dotenv.env['DEVICE_IP']}:3001" : 'https://localhost:3001';

  //final String _baseUrl = "http://10.0.2.2:3001/notifications/user";

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("user_id"); // Lấy userId từ SharedPreferences
      print("userid: " + userId!);

      if (userId == null || userId.isEmpty) {
        print("⚠️ User ID not found in SharedPreferences");
        return [];
      }
      print("✅ User ID from SharedPreferences: $userId");

      // final response = await http.get(Uri.parse("$_baseUrl/user/$userId"));
      final response = await http.get(Uri.parse("$_baseUrl/$userId"));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Kiểm tra response có key "data" không
        if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
          List<dynamic> jsonData = responseData["data"]; // Lấy danh sách từ "data"
          return jsonData.map((data) => NotificationModel.fromJson(data)).toList();
        } else {
          throw Exception("Invalid API response format: missing 'data'");
        }
      } else {
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  Future<bool> sendDeviceToken() async {
    try {
      final FirebaseMessaging _fcm = FirebaseMessaging.instance;
      NotificationSettings settings = await _fcm.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString("user_id");
        String? userToken = prefs.getString("token");
        // Get token from firebase
        String? token = await _fcm.getToken();
        // print("UserID: $userId");
        // print('📱 Device Token: $token');
        // Send token to server
        await http.post(Uri.parse("${_baseUrl}/devicetokens"),
            headers: {"Content-Type": "application/json",
              "Authorization": "Bearer ${userToken}"},
            body: jsonEncode({"user_id": userId, "device_token": token, "device_type": "Android"}));
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Push Notification permission denied, error: $e');
      return false;
    }
  }

  // TODO: handle when user logout
}
