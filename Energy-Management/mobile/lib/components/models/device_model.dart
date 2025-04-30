class DeviceModel {
  final String id;
  final String deviceName;
  final String deviceType;
  final String status;
  bool isActive;
  final String description;
  String? roomId;
  String? userId;

  DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.status,
    required this.isActive,
    required this.description,
    this.roomId,
    this.userId
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json["device_id"],
      deviceName: json["device_name"],
      deviceType: json["device_type"],
      status: json["status"],
      isActive: json["is_active"],
      description: json["device_description"],
      roomId: json["room_id"],
      userId: json["user_id"] ?? ""
    );
  }

  void changeActiveStatus(){
    isActive = !isActive;
  }
}