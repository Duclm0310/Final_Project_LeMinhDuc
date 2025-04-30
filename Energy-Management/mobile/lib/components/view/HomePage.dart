import 'package:energymanagement/components/Ultilities/BottomNavbar.dart';
import 'package:energymanagement/components/view/DevicesScreen.dart';
import 'package:energymanagement/components/view/FamilyScreen.dart';
import 'package:energymanagement/components/view/HomeScreen.dart';
import 'package:energymanagement/components/view/HousesScreen.dart';
import 'package:energymanagement/components/view/NotificationScreen.dart';
import 'package:energymanagement/components/view/StatisticsScreen.dart';
import 'package:energymanagement/components/viewmodel/auth_viewmodel.dart';
import 'package:energymanagement/riverpod/screen_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  final List<Widget> _pages = [
    const HomeScreen(),
    const StatisticScreen(),
    DeviceScreen(),
    const HousesScreen(),
    const FamilyScreen(),
    NotificationScreen()
  ];

  MainScreen({super.key});

  Widget DropdownBtn(BuildContext context, WidgetRef ref) => PopupMenuButton<int>(
      icon: const ImageIcon(
            AssetImage("assets/images/setting-icon.png"),
            color: Colors.white,
          ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              ImageIcon(
                AssetImage("assets/images/avatar-icon.png"),
                color: Color(0xFF6B76F2),
              ),
              SizedBox(width: 8),
              Text("Info"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text("Settings"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text("Exit"),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value){
          case 1:
            print("User info");
            break;
          case 2:
            print("Setting");
            break;
          case 3:
            await ref.read(authViewModelProvider).handleSignOut();
            Navigator.pushReplacementNamed(context, "login");
            break;
        }
      },
    );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataList = ref.watch(screenDataProvider);
    final currentIndex = ref.watch(homePageProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B76F2),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                dataList[currentIndex]["title"]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight, // Đưa icon vào bên phải
              child: DropdownBtn(context, ref)
              // IconButton(
              //   onPressed: () {},
              //   icon: const ImageIcon(
              //     AssetImage("assets/images/setting-icon.png"),
              //     color: Colors.white,
              //   ),
              // ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: _pages[currentIndex],
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}
