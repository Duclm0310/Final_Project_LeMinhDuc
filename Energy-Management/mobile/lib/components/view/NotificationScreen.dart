import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Ultilities/Notifi_item.dart';
import '../../riverpod/notification_data_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationProvider.notifier).loadNotifications();
        },
        child: notifications.isEmpty
            ? Center(child: Text("No notifications"))
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotifiItem(notif: notifications[index]);
          },
        ),
      ),
    );
  }
}
