import 'package:energymanagement/components/models/UserModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/models/NotificationModel.dart';
import '../components/viewmodel/notification_viewmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


final notificationProvider =
StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
        (ref) => NotificationNotifier());


class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    _setupFCM();
  }

  final NotificationViewModel _notificationVM = NotificationViewModel();

  Future<void> loadNotifications() async {
    final notifications = await _notificationVM.fetchNotifications();
    state = notifications;
  }

  void addNotification(NotificationModel newNotification) {
    state = [newNotification, ...state];
  }

  void _setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("📩 New FCM notification: ${message.notification?.title}");
      await loadNotifications();
    });
  }
}
