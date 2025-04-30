import 'package:energymanagement/components/models/NotificationModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để format ngày giờ

class NotifiItem extends StatelessWidget {
  final NotificationModel notif; // Thay vì Map<String, dynamic>

  const NotifiItem({Key? key, required this.notif}) : super(key: key);

  IconData _getIconByType(String type) {
    switch (type) {
      case "ALERT":
        return Icons.warning_amber_rounded;
      case "REMINDER":
        return Icons.alarm;
      case "SUMMARY":
        return Icons.article;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime createdAt) { // Sửa thành DateTime
    return DateFormat('HH:mm dd/MM').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              _getIconByType(notif.type),
              color: Colors.blue.shade800,
            ),
          ),
          title: Text(notif.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            notif.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(_formatDate(notif.createdAt)),
        ),
      ),
    );
  }
}
