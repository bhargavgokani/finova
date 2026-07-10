import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

/// Simple, non-AI insights derived purely from the current and previous
/// month's transaction data. Always shows 2-4 insights.
class FinancialInsightsCard extends StatelessWidget {
  final MonthlyTotal currentMonth;
  final Map<String, double> currentMonthExpenseByCategory;
  final Map<String, double> previousMonthExpenseByCategory;

  const FinancialInsightsCard({
    super.key,
    required this.currentMonth,
    required this.currentMonthExpenseByCategory,
    required this.previousMonthExpenseByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final insights = _generateInsights();

    if (insights.isEmpty) {
      return Text(
        'Not enough data yet for insights.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < insights.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(insights[i], style: textTheme.bodyMedium)),
            ],
          ),
          if (i != insights.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<String> _generateInsights() {
    final insights = <String>[];

    if (currentMonth.income > 0) {
      final savingsRate =
          ((currentMonth.income - currentMonth.expense) / currentMonth.income) *
          100;
      insights.add(
        savingsRate >= 0
            ? 'You saved ${savingsRate.toStringAsFixed(0)}% of your income this month.'
            : 'You spent ${(-savingsRate).toStringAsFixed(0)}% more than you earned this month.',
      );
    }

    final totalExpense = currentMonthExpenseByCategory.values.fold(
      0.0,
      (sum, value) => sum + value,
    );
    if (totalExpense > 0) {
      final topEntry = currentMonthExpenseByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final sharePercentage = (topEntry.value / totalExpense) * 100;

      insights.add(
        sharePercentage >= 40
            ? 'Your ${topEntry.key} expenses make up ${sharePercentage.toStringAsFixed(0)}% '
                  'of total spending. Consider setting a lower monthly budget for it.'
            : 'Your highest expense category this month is ${topEntry.key} '
                  'at ${formatCurrency(topEntry.value)}.',
      );
    }

    final increasedCategory = _biggestIncrease(
      from: previousMonthExpenseByCategory,
      to: currentMonthExpenseByCategory,
    );
    if (increasedCategory != null) {
      insights.add(
        '$increasedCategory expenses increased compared to last month.',
      );
    }

    if (insights.length < 4) {
      final decreasedCategory = _biggestIncrease(
        from: currentMonthExpenseByCategory,
        to: previousMonthExpenseByCategory,
      );
      if (decreasedCategory != null) {
        insights.add(
          '$decreasedCategory expenses decreased compared to last month.',
        );
      }
    }

    return insights.take(4).toList();
  }

  // Category in [to] with the largest positive increase over its amount
  // in [from]. Swap the arguments to find the largest decrease instead.
  String? _biggestIncrease({
    required Map<String, double> from,
    required Map<String, double> to,
  }) {
    String? biggest;
    double largestIncrease = 0;
    for (final entry in to.entries) {
      final increase = entry.value - (from[entry.key] ?? 0);
      if (increase > largestIncrease) {
        largestIncrease = increase;
        biggest = entry.key;
      }
    }
    return biggest;
  }
}
