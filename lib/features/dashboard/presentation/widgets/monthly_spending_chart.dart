import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Simple bar chart showing this month's spending broken into 4 weeks.
class MonthlySpendingChart extends StatelessWidget {
  final List<double> weeklySpending;

  const MonthlySpendingChart({super.key, required this.weeklySpending});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final highestWeek = weeklySpending.isEmpty
        ? 0.0
        : weeklySpending.reduce((a, b) => a > b ? a : b);
    final chartMax = highestWeek <= 0 ? 100.0 : highestWeek * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Week ${value.toInt() + 1}',
                    style: textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
          barGroups: List.generate(weeklySpending.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklySpending[index],
                  color: colorScheme.primary,
                  width: 24,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
