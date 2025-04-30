class RoomModel {
  String? id;
  String name;
  String roomType;
  List<String>? roomResident;
  String? house_id;
  RoomModel({required this.id, required this.name, required this.roomType, this.roomResident, this.house_id});

  RoomModel copyWith({String? id, String? name, String? roomType, List<String>? roomResident, String? house_id}) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      roomType: roomType ?? this.roomType,
      roomResident: roomResident ?? this.roomResident,
      house_id: house_id ?? this.house_id
    );
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['room_id'],
      name: json['room_name'],
      roomType: json['room_description'],
      roomResident: json['room_residents'] != null
          ? List<String>.from(json['room_residents'])
          : [],
      house_id: json['house_id'],
    );
  }
}