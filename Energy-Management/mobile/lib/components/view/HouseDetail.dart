import 'package:energymanagement/components/models/HouseModel.dart';
import 'package:energymanagement/components/models/RoomModel.dart';
import 'package:energymanagement/components/viewmodel/house_viewmodel.dart';
import 'package:energymanagement/riverpod/house_data_provider.dart';
import 'package:energymanagement/riverpod/room_data_provider.dart';
import 'package:energymanagement/riverpod/temp_house_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Change UI color base on Statistics screen // Login Screen
// TODO: Add room detail screen and navigation!

class HouseDetailScreen extends ConsumerWidget {
  const HouseDetailScreen({Key? key}) : super(key: key);

  String _shortenName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length <= 3) return name;
    return words.sublist(0, 3).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final house = ref.watch(selectedHouseProvider)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, house),
            const SizedBox(height: 20),
            _buildWeatherAndTemp(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildRoomsSection(house, context, size, ref),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new room or device
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new room or device')),
          );
        },
        backgroundColor: const Color(0xFF6B76F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, HouseModel house) {
    final tempProvider = ref.read(tempHouseProvider.notifier);
    final houseVM = ref.read(houseViewModelProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF6B76F2),
                size: 18,
              ),
            ),
          ),
          Text(
            _shortenName(house.name),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B76F2),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<int>(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF6B76F2), size: 18),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Delete"),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  tempProvider.setHouse(house);
                  Navigator.pushNamed(context, "createhouse");
                } else if (value == 2) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Text("Are you sure you want to delete this house?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text("Confirm", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    final deleteStatus = await houseVM.deleteHouse(house);
                    if (deleteStatus && context.mounted) {
                      Navigator.pop(context); // Quay lại sau khi xóa
                    }
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeatherAndTemp() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoCard(
            icon: Icons.cloud,
            title: "Partly Cloudy",
            subtitle: "Weather",
            iconColor: const Color(0xFF6B76F2),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildInfoCard(
            icon: Icons.thermostat,
            title: "28°C",
            subtitle: "Indoor Temp",
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection(HouseModel house, BuildContext context, Size size, WidgetRef ref) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Rooms",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // View all rooms
                },
                icon: const Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: Color(0xFF6B76F2),
                ),
                label: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF6B76F2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: const Color(0xFFEEEEF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: house.rooms.length,
              itemBuilder: (context, index) {
                final room = house.rooms[index];
                return _buildRoomCard(room, context, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room, BuildContext context, WidgetRef ref) {
    IconData getRoomIcon() {
      switch (room.roomType.toLowerCase()) {
        case 'living room':
          return Icons.weekend;
        case 'bedroom':
          return Icons.bed;
        case 'kitchen':
          return Icons.kitchen;
        case 'bathroom':
          return Icons.bathtub;
        case 'office':
          return Icons.desktop_mac;
        default:
          return Icons.room;
      }
    }

    // Calculate a random number of active devices (1-4)
    final activeDevices = (room.hashCode % 4) + 1;
    final totalDevices = activeDevices + ((room.hashCode % 3) + 1);
    final roomProvider = ref.read(selectedRoomProvider.notifier);
    return GestureDetector(
      onTap: () {
        // Navigate to your existing RoomDetailScreen with just the room name
        roomProvider.state = room;
        Navigator.pushNamed(context, "roomDetail");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEEEEF6),
              const Color(0xFFE6E9F9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B76F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getRoomIcon(),
                    size: 24,
                    color: const Color(0xFF6B76F2),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeDevices > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activeDevices > 0 ? "$activeDevices Active" : "No Devices",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: activeDevices > 0 ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$totalDevices Devices",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
