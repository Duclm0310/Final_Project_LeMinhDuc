import 'package:energymanagement/riverpod/statistic_data_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../riverpod/house_statistic_provider.dart';
import '../viewmodel/statistic_viewmodel.dart';

String shortenId(String id) {
  if (id.length <= 3) return id;
  return id.substring(0, 3) + "...";
}

class StatisticScreen extends ConsumerStatefulWidget {
  const StatisticScreen({super.key});

  @override
  ConsumerState<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends ConsumerState<StatisticScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, Map<String, dynamic>> _housesData = {
    'House 1': {
      'energy': 320.5,
      'color': const Color(0xFF26A69A),
      'devices': [
        {'name': 'Air Conditioner', 'energy': 125.3},
        {'name': 'Refrigerator', 'energy': 85.7},
        {'name': 'Lighting', 'energy': 45.2},
        {'name': 'TV & Electronics', 'energy': 64.3},
      ],
      'dailyData': [
        {'day': DateTime.now(), 'energy': 10.5},
        {
          'day': DateTime.now().subtract(const Duration(days: 1)),
          'energy': 11.2
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 2)),
          'energy': 9.8
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 3)),
          'energy': 12.3
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 4)),
          'energy': 10.9
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 5)),
          'energy': 11.5
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 6)),
          'energy': 10.2
        },
      ],
      'monthlyData': [
        {'month': 'Jan', 'energy': 310.5},
        {'month': 'Feb', 'energy': 290.2},
        {'month': 'Mar', 'energy': 305.8},
        {'month': 'Apr', 'energy': 320.3},
        {'month': 'May', 'energy': 335.9},
        {'month': 'Jun', 'energy': 350.5},
        {'month': 'Jul', 'energy': 365.2},
        {'month': 'Aug', 'energy': 340.8},
        {'month': 'Sep', 'energy': 325.3},
        {'month': 'Oct', 'energy': 315.9},
        {'month': 'Nov', 'energy': 305.5},
        {'month': 'Dec', 'energy': 320.2},
      ],
    },
    'House 2': {
      'energy': 245.8,
      'color': const Color(0xFF42A5F5),
      'devices': [
        {'name': 'Air Conditioner', 'energy': 95.2},
        {'name': 'Refrigerator', 'energy': 75.3},
        {'name': 'Lighting', 'energy': 35.8},
        {'name': 'TV & Electronics', 'energy': 39.5},
      ],
      'dailyData': [
        {'day': DateTime.now(), 'energy': 8.2},
        {
          'day': DateTime.now().subtract(const Duration(days: 1)),
          'energy': 7.9
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 2)),
          'energy': 8.5
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 3)),
          'energy': 9.1
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 4)),
          'energy': 8.3
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 5)),
          'energy': 7.8
        },
        {
          'day': DateTime.now().subtract(const Duration(days: 6)),
          'energy': 8.0
        },
      ],
      'monthlyData': [
        {'month': 'Jan', 'energy': 240.5},
        {'month': 'Feb', 'energy': 230.2},
        {'month': 'Mar', 'energy': 235.8},
        {'month': 'Apr', 'energy': 245.3},
        {'month': 'May', 'energy': 255.9},
        {'month': 'Jun', 'energy': 260.5},
        {'month': 'Jul', 'energy': 265.2},
        {'month': 'Aug', 'energy': 250.8},
        {'month': 'Sep', 'energy': 245.3},
        {'month': 'Oct', 'energy': 240.9},
        {'month': 'Nov', 'energy': 235.5},
        {'month': 'Dec', 'energy': 245.8},
      ],
    },
  };
  bool isLoading = false;
  String _shortenName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length <= 3) return name;
    return words.sublist(0, 3).join(' ') + '...';
  }

  double calculateTotalEnergy(List<HouseStatistic> houseList) {
    double result = 0;
    houseList.forEach((h)=> result += h.totalEnergy);
    return result;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.microtask(() async {
      await ref.read(statisticVMProvider).FetchHousesEnergyUse();
      await ref.read(statisticVMProvider).fetchAllChartData();
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final houseData = ref.watch(houseStatisticProvider);
    return houseData.isNotEmpty ? Column(
      children: [
        _buildPieChart(),
        Expanded(
          flex: 4, // Increased to give more space for cards
          child: _buildHouseCards(),
        ),
      ],
    ) : const Center(child: Text("No house available yet!"));
  }

  Widget _buildPieChart() {
    final houseData = ref.watch(houseStatisticProvider);
    double totalEnergy = calculateTotalEnergy(houseData);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Total Energy Consumption',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                    // Increased to make the pie chart thinner
                    sections: houseData.map((h) {
                      final houseName = h.houseName;
                      final houseEnergy = h.totalEnergy;
                      final percentage = (houseEnergy / totalEnergy) * 100;

                      return PieChartSectionData(
                        color: h.houseMarkColor,
                        value: houseEnergy,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 40,
                        // Reduced to make the pie chart thinner
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Text(
                  '${totalEnergy.toStringAsFixed(1)} kWh',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: houseData.map((h) {
              final houseName = h.houseName;
              final houseColor = h.houseMarkColor;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: houseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(_shortenName(houseName)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseCards() {
    final housesData = ref.watch(houseStatisticProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Houses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: housesData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHouseCard(housesData[index]),
                  // child: _buildHouseCard(houseName, houseData),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseCard(HouseStatistic house) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: house.houseMarkColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "houseStatisticDetail");
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: house.houseMarkColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    house.houseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: house.houseMarkColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${house.totalEnergy.toStringAsFixed(1)} kWh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: house.houseMarkColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...?house.rooms?.map((r) {
                final roomName = r.id;
                final roomEnergy = r.totalEnergy;
                final percentage = (r.totalEnergy / house.totalEnergy) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("House with id: ${shortenId(roomName)}"),
                      Row(
                        children: [
                          Text('${roomEnergy.toStringAsFixed(1)} kWh'),
                          const SizedBox(width: 8),
                          Text(
                            '(${percentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(selectedHouseDetail.notifier).state = house.id;
                    Navigator.pushNamed(context, "houseStatisticDetail");
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('View Detailed Statistics'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
