import 'RoomModel.dart';

class HouseModel {
  final String id;
  final String name;
  final String address;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<RoomModel> rooms;

  HouseModel({
    required this.id,
    required this.name,
    required this.address,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.rooms,
  });

  void setRooms(List<RoomModel> roomList){
    rooms = roomList;
  }

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['house_id'],
      name: json['house_name'],
      address: json['house_address'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      rooms: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house_id': id,
      'house_name': name,
      'house_address': address,
      'owner_id': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HouseModel copyWith({
    String? id,
    String? name,
    String? address,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RoomModel>? rooms,
  }) {
    return HouseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rooms: rooms ?? this.rooms,
    );
  }
}
