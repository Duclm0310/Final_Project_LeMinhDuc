  class NotificationModel {
    final String id;
    final String userId;
    final String? deviceId;
    final String type;
    final String title;
    final String message;
    final String status;
    final DateTime createdAt;

    NotificationModel({
      required this.id,
      required this.userId,
      this.deviceId,
      required this.type,
      required this.title,
      required this.message,
      required this.status,
      required this.createdAt,
    });

    factory NotificationModel.fromJson(Map<String, dynamic> json) {
      return NotificationModel(
        id: json['_id'],
        userId: json['user_id'],
        deviceId: json['device_id'],
        type: json['type'],
        title: json['title'],
        message: json['message'],
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
      );
    }

    Map<String, dynamic> toJson() {
      return {
        '_id': id,
        'user_id': userId,
        'device_id': deviceId,
        'type': type,
        'title': title,
        'message': message,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
    }
  }
