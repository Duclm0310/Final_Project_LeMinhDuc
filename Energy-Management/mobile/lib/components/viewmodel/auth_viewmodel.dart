import 'dart:convert';
import 'package:energymanagement/components/models/UserModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../riverpod/auth_data_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthViewModel {
  final Ref ref;
  String _baseUrl = dotenv.env['DEVICE_IP'] != null ? "http://${dotenv.env['DEVICE_IP']}:3001" : 'https://localhost:3001';
  String errorMsg = "";
  String? device_ip = dotenv.env['DEVICE_IP'];
  AuthViewModel(this.ref);

  Future<void> storeDataToLocalStorage(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> getDataFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  String? _parseCookie(String rawCookie, String key) {
    final cookies = rawCookie.split(';');
    for (var cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == key) {
        return parts[1];
      }
    }
    return null;
  }

  Future<bool> handleLogin(String email, String password, WidgetRef ref) async {
    try{
      final response = await http.post(
        Uri.parse("$_baseUrl/users/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['accesstoken'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken["payload"]["user_id"];
        await storeDataToLocalStorage("user_id", userId);
        await storeDataToLocalStorage("token", token);
        await storeDataToLocalStorage("username", jsonResponse["name"]);
        final loginUser = await getUserById(userId);
        final rawCookie = response.headers['set-cookie'];
        final refreshToken = _parseCookie(rawCookie!, 'refreshtoken');
        print("Refresh token: $refreshToken");
        if(refreshToken != null){
          await storeDataToLocalStorage("refreshtoken", refreshToken);
        }
        if (loginUser != null) {
          loginUser.setToken(token);
          await storeDataToLocalStorage("user_data", jsonEncode(loginUser.toJson()));
          ref.read(authProvider.notifier).setCurrentUser(loginUser);
          print("User Login Data: ${jsonEncode(loginUser.toJson())}");
          return true;
        }
      }
      errorMsg = "Server returned an error: ${response.statusCode}";
      return false;
    } catch (e) {
      print("Error in handleLogin: $e");
      errorMsg = "$e";
      return false;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final userResponse = await http.get(Uri.parse("$_baseUrl/users/$id"));
      if (userResponse.statusCode >= 200 || userResponse.statusCode < 300) {
        final userJson = jsonDecode(userResponse.body);
        final userData = UserModel.fromJson(userJson["user"]);
        final refreshToken = await getDataFromLocalStorage("refreshtoken");
        if (refreshToken != null) {
          final tokenResponse = await http.post(
            Uri.parse("$_baseUrl/users/token"),
            headers: {
              "Cookie": "refreshtoken=$refreshToken",
            },
          );

          if (tokenResponse.statusCode == 200) {
            final tokenJson = jsonDecode(tokenResponse.body);
            final newAccessToken = tokenJson["accessToken"];
            userData.setToken(newAccessToken);
            await storeDataToLocalStorage("token", newAccessToken);
            print("✅ Token refreshed successfully: $newAccessToken");
          } else {
            print("❌ Failed to refresh token: ${tokenResponse.statusCode}, current refresh token: $refreshToken");
          }
        }
        return userData;
      } else {
        print("❌ Failed to get user by ID: ${userResponse.statusCode}");
      }
    } catch (e) {
      print("🔥 Exception while getting user by ID: $e");
    }

    return null;
  }

  //TODO: add login with phone from BE then implement to FE to handle login using phone number!
  Future<bool> loginWithPhone(String phone) async {
    try{
      final res = await http.post(Uri.parse("http://$device_ip:5000/users/phone"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phone": phone,
          }));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final dataDecoded = JwtDecoder.decode(data["token"]);
        final userData = UserModel.fromJson(dataDecoded);
        ref.read(authProvider.notifier).setCurrentUser(userData);
        await storeDataToLocalStorage("user_data", jsonEncode(userData));
        return true;
      }
      return false;
    }catch(e){
      print("Failed to login with phone number, $e");
      return false;
    }
  }

  Future<bool> handleSignUp(String name, String email, String password, String address, String phone) async {
    try{
      if(name.isEmpty || email.isEmpty || password.isEmpty || address.isEmpty || phone.isEmpty) return false;
      final res = await http.post(Uri.parse("$_baseUrl/users/signup"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name":name,
            "email": email,
            "password": password,
            'address': address,
            "phone": phone
          }));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final dataDecoded = JwtDecoder.decode(data["token"]);
        final userData = UserModel.fromJson(dataDecoded);
        //print(userData);
        ref.watch(authProvider.notifier).setCurrentUser(userData);
        await storeDataToLocalStorage("user_data", jsonEncode(userData.toJson()));
        return true;
      }
      return false;
    }catch(e){
      print("Failed to create new account!: $e");
      return false;
    }
  }

  Future<void> handleSignOut() async {
    String? reftoken = await getDataFromLocalStorage("refreshtoken");
    if(reftoken!= null){
      final res = await http.post(Uri.parse("$_baseUrl/users/logout"),
          headers: {"Cookie": "refreshtoken=$reftoken"});
      final prefs = await SharedPreferences.getInstance();
      ref.read(authProvider.notifier).removeCurrentUser();
      await prefs.clear();
    }
  }

  Future<bool> verifyEmail(String email, String OTP) async {
    try{
      final verifyRes = await http.post(
        Uri.parse("$_baseUrl/users/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": OTP}),
      );
      if (verifyRes.statusCode == 200) {
        print("Verified email");
        return true;
      }
      return false;
    }catch(e){
      print("Cant verify email, $e");
      return false;
    }
  }

  Future<bool> resendOTP(String email) async {
    try{
      final sentRes = await http.post(
        Uri.parse("$_baseUrl/users/resend-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      if (sentRes.statusCode >= 200 || sentRes.statusCode < 300) {
        print("New OTP sent!");
        return true;
      }
      return false;
    }catch(e){
      print("Cant sent new OTP, $e");
      return false;
    }
  }

  Future<bool> isLogin() async {
    String? userID = await getDataFromLocalStorage("user_id");
    if(userID != null){
      final UserModel? foundUser = await getUserById(userID);
      print("Check Login Data: ${jsonEncode(foundUser?.toJson())}, ${foundUser?.userId}");
      ref.read(authProvider.notifier).setCurrentUser(foundUser!);
      await storeDataToLocalStorage("user_data", jsonEncode(foundUser.toJson()));
      return true;
    }
    return false;
  }

  UserModel? getLoginUser() {
    final userData = ref.read(authProvider);
    if(userData != null) return userData;
    return null;
  }
}

final authViewModelProvider = Provider<AuthViewModel>((ref){
  return AuthViewModel(ref);
});
