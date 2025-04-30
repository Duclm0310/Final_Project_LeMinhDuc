import 'package:energymanagement/components/view/HouseDetailStatistic.dart';
import 'package:energymanagement/components/view/AddHouseScreen.dart';
import 'package:energymanagement/components/view/DevicesScreen.dart';
import 'package:energymanagement/components/view/FamilyScreen.dart';
import 'package:energymanagement/components/view/HomePage.dart';
import 'package:energymanagement/components/view/HouseDetail.dart';
import 'package:energymanagement/components/view/HousesScreen.dart';
import 'package:energymanagement/components/view/LoadingScreen.dart';
import 'package:energymanagement/components/view/LoginPage.dart';
import 'package:energymanagement/components/view/NotificationScreen.dart';
import 'package:energymanagement/components/view/PhoneAuthentication.dart';
import 'package:energymanagement/components/view/QRScanningScreen.dart';
import 'package:energymanagement/components/view/RegisterPage.dart';
import 'package:energymanagement/components/view/RoomDetail.dart';
import 'package:energymanagement/components/view/StatisticsScreen.dart';
import 'package:energymanagement/components/view/TestPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//TODO: handle check for error cant navigate to notification screen!

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔥 Khai báo plugin thông báo cục bộ
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// 📌 Hàm hiển thị thông báo khi ứng dụng đang mở
void showNotification(RemoteMessage message) async {
  var androidDetails = const AndroidNotificationDetails(
    "high_importance_channel",
    "High Importance Notifications",
    importance: Importance.high,
    priority: Priority.high,
  );

  var notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // ID
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
  );
}

// 📌 Xử lý thông báo khi app ở chế độ nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("_firebaseMessagingBackgroundHandler: $message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(url: dotenv.env["SUPABASE_URL"]!, anonKey: dotenv.env["SUPABASE_API_KEY"]!);
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🛑 Yêu cầu quyền thông báo (Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("🚨 Quyền thông báo bị từ chối!");
    } else {
      print("✅ Quyền thông báo đã được cấp!");
    }

    // 📌 Khởi tạo thông báo cục bộ
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(android: androidInitSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 📌 Nhận token Firebase
    FirebaseMessaging.instance.getToken().then((value) {
      //print("getToken: $value");
    });

    // 📌 Xử lý khi app đang chạy (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notification received in foreground!");
      showNotification(message);
    });

    // 📌 Xử lý khi app chạy nền và user mở app từ thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.data}");
      navigatorKey.currentState!.pushNamed(
        'notifidetail',
        arguments: message.data,
      );
    });

    // 📌 Xử lý khi app bị tắt và mở lên từ thông báo
    FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) {
        if (message != null) {
          navigatorKey.currentState!.pushNamed(
            'notifidetail',
            arguments: message.data,
          );
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    runApp(ProviderScope(child: MyApp()));
  } catch (e) {
    print("Error while trying to connect to mobile server!");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Energy Management',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      //   useMaterial3: true,
      // ),
      initialRoute: 'login',
      routes: {
        'register': (context) => RegisterScreen(),
        'login': (context) => LoginScreen(),
        'home': (context) => MainScreen(),
        'devices': (context) => DeviceScreen(),
        'statistic': (context) => StatisticScreen(),
        'houseStatisticDetail': (context) => HouseDetailStatistic(),
        'test': (context) => TestPage(),
        'houses': (context) => HousesScreen(),
        'createhouse': (context) => AddHouseScreen(),
        'loading': (context) => LottieLoadingScreen(),
        'qr-scan': (context) => QrScanningScreen(),
        'houseDetail': (context) => HouseDetailScreen(),
        'phone-auth': (context) => PhoneAuthentication(),
        'notification': (context) => NotificationScreen(),
        'family': (context) => FamilyScreen(),
        'roomDetail':(conext) => RoomDetailScreen(),
      },
    );
  }
}
