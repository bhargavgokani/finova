import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../bloc/dashboard_state.dart';

/// Card showing a single budget's spend-vs-limit progress, used in the
/// dashboard's Budget Overview section.
class BudgetOverviewCard extends StatelessWidget {
  final BudgetOverviewItem item;

  const BudgetOverviewCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progressColor = item.isOverBudget
        ? colorScheme.error
        : colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.category,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: textTheme.titleMedium?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: progressColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountLabel(label: 'Budget', value: item.budgetAmount),
                _AmountLabel(label: 'Spent', value: item.spentAmount),
                _AmountLabel(label: 'Remaining', value: item.remainingAmount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final double value;

  const _AmountLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          formatCurrency(value),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
