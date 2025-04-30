import 'package:energymanagement/components/view/HouseDetail.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
//TODO: Create chat page state and view model
//TODO: handle search for people in state!
//TODO: add button that dropdown and add people through email or QR

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  // Sample data - in a real app, this would come from an API or database
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

  double get _totalEnergy => _housesData.values
      .map((house) => house['energy'] as double)
      .reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Energy Statistics'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Energy distribution pie chart
          _buildPieChart(),

          // House cards
          Expanded(
            flex: 5, // Increased to give more space for cards
            child: _buildHouseCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
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
                    sections: _housesData.entries.map((entry) {
                      final houseName = entry.key;
                      final houseData = entry.value;
                      final houseEnergy = houseData['energy'] as double;
                      final percentage = (houseEnergy / _totalEnergy) * 100;

                      return PieChartSectionData(
                        color: houseData['color'] as Color,
                        value: houseEnergy,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 35,
                        // Reduced to make the pie chart thinner
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Text(
                  '${_totalEnergy.toStringAsFixed(1)} kWh',
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
            children: _housesData.entries.map((entry) {
              final houseName = entry.key;
              final houseData = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: houseData['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(houseName),
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
              itemCount: _housesData.length,
              itemBuilder: (context, index) {
                final entry = _housesData.entries.elementAt(index);
                final houseName = entry.key;
                final houseData = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHouseCard(houseName, houseData),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseCard(String houseName, Map<String, dynamic> houseData) {
    final houseEnergy = houseData['energy'] as double;
    final devices = houseData['devices'] as List<Map<String, dynamic>>;
    final houseColor = houseData['color'] as Color;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: houseColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HouseStatisticDetailScreen(
          //       houseName: houseName,
          //       houseData: houseData,
          //     ),
          //   ),
          // );
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
                      color: houseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    houseName,
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
                      color: houseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${houseEnergy.toStringAsFixed(1)} kWh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: houseColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...devices.map((device) {
                final deviceName = device['name'] as String;
                final deviceEnergy = device['energy'] as double;
                final percentage = (deviceEnergy / houseEnergy) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(deviceName),
                      Row(
                        children: [
                          Text('${deviceEnergy.toStringAsFixed(1)} kWh'),
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => HouseStatisticDetailScreen(
                    //       houseName: houseName,
                    //       houseData: houseData,
                    //     ),
                    //   ),
                    // );
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
