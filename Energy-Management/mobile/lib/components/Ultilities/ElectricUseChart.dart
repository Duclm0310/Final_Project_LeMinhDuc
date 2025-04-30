import 'package:energymanagement/components/models/ChartData.dart';
import 'package:energymanagement/riverpod/statistic_data_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 //TODO: Fix display data at viewmodel
class ElectricUseChart extends ConsumerWidget {
  final int index;
  final double? deviceWidth, deviceHeight;

  const ElectricUseChart(
      {super.key, required this.index, required this.deviceWidth, required this.deviceHeight});

  String displayDate(DateTime showTime, TimePeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final showDate = DateTime(showTime.year, showTime.month, showTime.day);

    if (period == TimePeriod.day) {
      if (showDate == today) {
        return "Present";
      } else if (showDate == yesterday) {
        return "Yesterday";
      } else {
        return "${showTime.day}/${showTime.month}/${showTime.year}";
      }
    } else if (period == TimePeriod.month) {
      if (showTime.year == now.year && showTime.month == now.month) {
        return "This month";
      } else if (showTime.year == now.year &&
          showTime.month == now.month - 1) {
        return "Last month";
      } else {
        return "${showTime.month}/${showTime.year}";
      }
    }
    return "${showTime.day}/${showTime.month}/${showTime.year}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final roomProvider = ref.watch(roomChartProvider); // List<ChartData>
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final selectedHouseId = ref.watch(selectedHouseDetail);
    final houseChartData = ref.watch(roomChartDataProvider);
    final HouseStatisticData? houseData = houseChartData[selectedHouseId];

    if (houseData == null) {
      return const CircularProgressIndicator();
    }

    final List<ChartData> roomList = selectedPeriod == TimePeriod.day
        ? houseData.dailyData
        : houseData.monthlyData;

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    final showChartData = selectedPeriod == TimePeriod.day ? roomList.elementAt(
        index)
        : roomList.elementAt(index);

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.fromLTRB(5, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartHeader(context, showChartData, selectedPeriod),
            SizedBox(height: deviceHeight! * 0.04),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  minY: showChartData.minY,
                  maxY: showChartData.maxY,
                  gridData: _buildGridData(primaryColor),
                  titlesData: _buildTitlesData(showChartData, theme),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor, width: 1),
                      left: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  lineBarsData: [
                    _buildLineChartBarData(showChartData, primaryColor),
                  ],
                  lineTouchData: _buildTouchData(theme),
                ),
              ),
            ),
            SizedBox(height: deviceHeight! * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context, ChartData showChartData,
      TimePeriod selectedPeriod) {
    return Center(
      child: Text(
        "${displayDate(
            showChartData.date, selectedPeriod)} electricity consumption",
        style: Theme
            .of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  FlGridData _buildGridData(Color primaryColor) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      horizontalInterval: 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: primaryColor.withOpacity(0.2),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
      drawVerticalLine: false,
    );
  }

  FlTitlesData _buildTitlesData(ChartData chartData, ThemeData theme) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          'kWh',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toInt().toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index >= 0 && index < chartData.xValues.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  chartData.xValues[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          reservedSize: 30,
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(ChartData chartData,
      Color primaryColor) {
    return LineChartBarData(
      spots: List.generate(
        chartData.yValues.length,
            (index) => FlSpot(index.toDouble(), chartData.yValues[index]),
      ),
      isCurved: true,
      color: primaryColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: primaryColor,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: primaryColor.withOpacity(0.15),
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.3),
            primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  LineTouchData _buildTouchData(ThemeData theme) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: theme.colorScheme.surface,
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // tooltipShadowColor: Colors.black26,
        // tooltipShadowBlurRadius: 8,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            return LineTooltipItem(
              '${barSpot.y.toStringAsFixed(1)} kWh',
              const TextStyle(
                color: Color(0xFF6B76F2),
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
      touchSpotThreshold: 20,
    );
  }
}
