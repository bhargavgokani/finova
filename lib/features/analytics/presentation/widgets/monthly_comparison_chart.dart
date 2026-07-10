import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/chart_titles.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

/// Simple vertical bar chart showing monthly expense for the previous 6
/// months (oldest to newest, ending at the current month).
class MonthlyComparisonChart extends StatelessWidget {
  final List<MonthlyTotal> data;

  const MonthlyComparisonChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final highestExpense = data
        .map((point) => point.expense)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = highestExpense <= 0 ? 100.0 : highestExpense * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: simpleBottomAxisTitles((index) {
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('MMM').format(data[index].month),
                style: textTheme.bodySmall,
              ),
            );
          }),
          barGroups: List.generate(data.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].expense,
                  color: AppColors.error,
                  width: 20,
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
