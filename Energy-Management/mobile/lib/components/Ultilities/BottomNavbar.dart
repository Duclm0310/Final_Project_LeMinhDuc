import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../riverpod/screen_data_provider.dart';

class BottomNavbar extends ConsumerWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homePageProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6B76F2),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4), // Đổ bóng xuống dưới
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFD9D9D9).withOpacity(0.7),
            unselectedItemColor: Colors.white,
            items: [
              _buildNavItem("assets/images/home-icon.png", 'Home', 0, currentIndex),
              _buildNavItem("assets/images/statistic-icon.png", 'Statistics', 1, currentIndex),
              _buildNavItem("assets/images/device-icon.png", 'Devices', 2, currentIndex),
              _buildNavItem("assets/images/house-management-icon.png", 'Houses', 3, currentIndex),
              _buildNavItem("assets/images/team-icon.png", 'Family', 4, currentIndex),
            ],
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(homePageProvider.notifier).changeIndex(index);
            },
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label, int index, int currentIndex) {
    bool isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ImageIcon(
            AssetImage(iconPath),
            size: 24,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ],
      ),
      label: label,
    );
  }
}