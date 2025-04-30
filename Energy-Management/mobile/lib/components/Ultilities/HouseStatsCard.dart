import 'package:energymanagement/components/models/HouseModel.dart';
import 'package:energymanagement/riverpod/house_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _titleStyle = TextStyle(
  color: Color(0xFF6B76F2),
  fontSize: 24,
  fontFamily: 'Asul',
  fontWeight: FontWeight.w700,
);

const _infoStyle = TextStyle(
  color: Color(0xFF6B76F2),
  fontSize: 18,
  fontFamily: 'Asul',
  fontWeight: FontWeight.w400,
);

class HouseStatsCard extends ConsumerWidget {
  HouseModel house;
  double? screenWidth, screenHeight;

  HouseStatsCard({
    super.key,
    required this.house
  });

  String _shortenName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length <= 3) return name;
    return words.sublist(0, 3).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(20),
      width: screenWidth! * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E6F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(
                _shortenName(house.name),
                style: _titleStyle,
              ),
              IconButton(
                  onPressed: () {
                    ref.watch(selectedHouseProvider.notifier).state = house;
                    Navigator.pushNamed(context, "houseDetail");
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                    weight: 800,
                  ))
            ],
          ),
          // House Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(iconPath: 'assets/icons/room_color_icon.png', text: '${house.rooms.length} Rooms'),
                  const SizedBox(height: 43),
                  InfoRow(iconPath: 'assets/icons/childrens_color_icon.png', text: '0 Members'),
                ],
              ),
              Container(
                width: 3,
                height: 120,
                color: Colors.white,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(iconPath: 'assets/icons/energy_color_icon.png', text: '0 Kw'),
                  const SizedBox(height: 43),
                  InfoRow(iconPath: 'assets/icons/iot_devices_color_icon.png', text: '0 Devices'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String iconPath;
  final String text;

  const InfoRow({
    super.key,
    required this.iconPath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(iconPath, width: 30, height: 30),
        const SizedBox(width: 8),
        Text(text, style: _infoStyle),
      ],
    );
  }
}