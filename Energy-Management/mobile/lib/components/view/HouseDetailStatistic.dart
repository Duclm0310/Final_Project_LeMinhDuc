import 'package:energymanagement/components/Ultilities/ElectricUseChart.dart';
import 'package:energymanagement/riverpod/statistic_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ChartData.dart';

class HouseDetailStatistic extends ConsumerStatefulWidget {
  const HouseDetailStatistic({super.key});

  @override
  ConsumerState<HouseDetailStatistic> createState() =>
      _HouseDetailStatisticState();
}

class _HouseDetailStatisticState extends ConsumerState<HouseDetailStatistic> {
  int currentIndex = 5;
  double? deviceWidth, deviceHeight;

  void nextChart(List<ChartData> data) {
    setState(() {
      currentIndex = (currentIndex + 1) % data.length;
    });
  }

  void previousChart(List<ChartData> data) {
    setState(() {
      currentIndex = (currentIndex - 1 + data.length) % data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    // TODO: add selectedHouse.

    final selectedPeriod = ref.watch(selectedPeriodProvider);
    //final statistics = ref.watch(statisticsProvider);
    final theme = Theme.of(context);
    final selectedHouseId = ref.watch(selectedHouseDetail);
    final houseChartData = ref.watch(houseChartDataProvider);
    final HouseStatisticData? houseData = houseChartData[selectedHouseId];

    if (houseData == null) {
      return const Center(
          child: Text(
        "No data were found to display!",
        style: TextStyle(color: Colors.red),
      ));
    }

    //print("Lấy thành công dữ liệu cho nhà ${houseData}");
    final List<ChartData> displayingList = selectedPeriod == TimePeriod.day
        ? houseData.dailyData
        : houseData.monthlyData;

    final ChartData displayData = displayingList.elementAt(currentIndex);

    if (currentIndex >= displayingList.length) {
      setState(() {
        currentIndex = displayingList.length;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("House Statistic"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnergyCard(context, displayData),
                SizedBox(height: deviceHeight! * 0.04),
                _buildTimePeriodSelector(context, ref, selectedPeriod),
                SizedBox(height: deviceHeight! * 0.02),
                // Passing HouseStatistic Data here!
                ElectricUseChart(index: currentIndex, deviceWidth: deviceWidth, deviceHeight: deviceHeight),
                SizedBox(height: deviceHeight! * 0.02),

                // Build button to switch data!!
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeButton(
                      icon: Icons.arrow_back_ios_rounded,
                      label: 'Previous',
                      onPressed: () => previousChart(displayingList),
                      theme: theme,
                    ),
                    _buildTimeButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      label: 'Next',
                      onPressed: () => nextChart(displayingList)
                      ,
                      theme: theme,
                      isIconLeading: false,
                    ),
                  ],
                ),
                //_buildStatisticBoxes(context, statistics),
                SizedBox(height: deviceHeight! * 0.02),
                _buildRecommendationsCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyCard(BuildContext context, ChartData displayData) {
    //TODO: Make this display house daily or monthly data
    final theme = Theme.of(context);
    //final isIncrease = statistics['isIncrease'] as bool;
    final isIncrease = true;
    final changeColor = isIncrease ? Colors.red : Colors.green;
    final changeIcon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Energy Used: ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Electricity',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${displayData.yValues.first} kWh',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  changeIcon,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '(1kWh %)',
                  // ${statistics['change'].abs().toStringAsFixed(3)} kWh (${statistics['changePercent']}
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector(
    BuildContext context,
    WidgetRef ref,
    TimePeriod selectedPeriod,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TimePeriod.values.map((period) {
            final isSelected = period == selectedPeriod;
            return _buildTimePeriodButton(
              context,
              label: _getPeriodLabel(period),
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedPeriodProvider.notifier).state = period;
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return 'Day';
      case TimePeriod.month:
        return 'Month';
    }
  }

  Widget _buildTimePeriodButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticBoxes(
      BuildContext context, Map<String, dynamic> statistics) {
    final stats = statistics['stats'] as List;
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: stat == stats.last ? 0 : 8,
            ),
            child: _buildStatisticBox(
              context,
              value: stat['value'],
              label: stat['label'],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatisticBox(
    BuildContext context, {
    required double value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(value < 10 ? 3 : 1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: ' kWh',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // color: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Energy Saving Tips',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.access_time,
              title: 'Off-peak Usage',
              description:
                  'Use high-energy appliances during off-peak hours to save up to 20%.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              context,
              icon: Icons.thermostat,
              title: 'Optimal Temperature',
              description:
                  'Set your thermostat to 68°F in winter and 78°F in summer.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              context,
              icon: Icons.power,
              title: 'Standby Power',
              description:
                  'Unplug devices when not in use to eliminate phantom energy usage.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isIconLeading = true,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: theme.colorScheme.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIconLeading) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 8),
          ],
          Text(label),
          if (!isIconLeading) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 16),
          ],
        ],
      ),
    );
  }
}
