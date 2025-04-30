import 'package:energymanagement/components/models/HouseModel.dart';
import 'package:energymanagement/riverpod/house_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Ultilities/HouseStatsCard.dart';

class HousesScreen extends ConsumerWidget {
  const HousesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houses = ref.watch(houseProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "createhouse"),
        backgroundColor: const Color(0xFF6B76F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _housesSumData(ref),
          Expanded(
            child: houses.isEmpty
                ? _emptyHouseView(context)
                : _houseListView(context, houses),
          ),
        ],
      ),
    );
  }

  Widget _houseListView(BuildContext context, List<HouseModel> houses) {
    return ListView.builder(
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        return HouseStatsCard(house: house);
      },
    );
  }

  Widget _emptyHouseView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No house available", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "createhouse"),
            child: const Text("Add House"),
          ),
        ],
      ),
    );
  }

  Widget _housesSumData(WidgetRef ref) {
    final houses = ref.watch(houseProvider);
    final totalRooms = ref.watch(houseProvider.notifier).totalRooms;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E6F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryColumn("Total House", houses.length.toString()),
          _divider(),
          _summaryColumn("Total Rooms", totalRooms.toString()),
        ],
      ),
    );
  }

  Widget _summaryColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Asul',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B76F2),
              fontSize: 22,
              fontFamily: 'Asul',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 3,
      height: 81,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
    );
  }
}