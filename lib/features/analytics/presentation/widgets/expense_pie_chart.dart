import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _PieColor {
  final Color background;
  final Color onColor;

  const _PieColor(this.background, this.onColor);
}

/// Simple pie chart showing expense share per category. Category name and
/// percentage are rendered directly on each slice - no external legend.
class ExpensePieChart extends StatelessWidget {
  final Map<String, double> expenseByCategory;

  const ExpensePieChart({super.key, required this.expenseByCategory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = expenseByCategory.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    if (total <= 0) {
      return Center(
        child: Text(
          'No expenses in this period',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final categories = expenseByCategory.keys.toList();
    final palette = _paletteFor(colorScheme);

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 32,
          pieTouchData: PieTouchData(enabled: false),
          sections: List.generate(categories.length, (index) {
            final category = categories[index];
            final amount = expenseByCategory[category]!;
            final percentage = (amount / total) * 100;
            final paletteEntry = palette[index % palette.length];

            return PieChartSectionData(
              value: amount,
              color: paletteEntry.background,
              title: '$category\n${percentage.toStringAsFixed(0)}%',
              radius: 70,
              titleStyle: textTheme.bodySmall?.copyWith(
                color: paletteEntry.onColor,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
      ),
    );
  }

  List<_PieColor> _paletteFor(ColorScheme colorScheme) {
    return [
      _PieColor(colorScheme.primary, colorScheme.onPrimary),
      _PieColor(colorScheme.secondary, colorScheme.onSecondary),
      _PieColor(colorScheme.tertiary, colorScheme.onTertiary),
      _PieColor(colorScheme.error, colorScheme.onError),
      _PieColor(colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      _PieColor(
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
    ];
  }
}
