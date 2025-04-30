// class UserModel {
//   final String? userId;
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   String? token;
//
//   UserModel({
//     this.userId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     this.token
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json){
//     return UserModel(
//         userId: json["user_id"] ?? "",
//         name: json["name"] ?? "",
//         email: json["email"] ?? "",
//         phone: json["phone"] ?? "",
//         address: json["address"] ?? "",
//         token: json["token"] ?? ""
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "name": name,
//       "email": email,
//       "phone": phone,
//       "address": address,
//       "token": token,
//     };
//   }
//
//
//   void setToken(String token){
//     this.token = token;
//   }
// }


class UserModel {
  final String? userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatar; // 🛠 THÊM avatar
  String? token;

  UserModel({
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatar, // 🛠 thêm vào constructor
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      avatar: (json["avatar"] != null && json["avatar"].toString().isNotEmpty)
          ? json["avatar"]
          : "https://via.placeholder.com/150", // Avatar mặc định nếu thiếu
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "avatar": avatar, // 🛠 đừng quên thêm avatar vào toJson()
      "token": token,
    };
  }

  void setToken(String token) {
    this.token = token;
  }
}
