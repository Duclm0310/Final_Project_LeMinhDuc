import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:energymanagement/components/models/ChatUser.dart';

final chatUsersProvider = FutureProvider<List<ChatUser>>((ref) async {
  final dio = Dio();
  final response = await dio.get('http://192.168.63.101:3001/users');

  final List<dynamic> data = response.data;
  return data.map((e) => ChatUser.fromJson(e)).toList();
});