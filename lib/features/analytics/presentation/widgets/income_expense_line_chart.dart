import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

/// Simple line chart comparing income vs expense across the selected
/// months. Income and expense use the same green/red convention as the
/// rest of the app - no external legend.
class IncomeExpenseLineChart extends StatelessWidget {
  final List<MonthlyTotal> data;

  const IncomeExpenseLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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

    final highest = data
        .map(
          (point) =>
              point.income > point.expense ? point.income : point.expense,
        )
        .reduce((a, b) => a > b ? a : b);
    final chartMax = highest <= 0 ? 100.0 : highest * 1.2;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMax,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
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
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
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
                },
              ),
            ),
          ),
          lineBarsData: [
            _lineFor(
              data.map((point) => point.income).toList(),
              AppColors.success,
            ),
            _lineFor(
              data.map((point) => point.expense).toList(),
              AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineFor(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (index) => FlSpot(index.toDouble(), values[index]),
      ),
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }
}
