import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/budget_model.dart';
import '../bloc/budget_state.dart';

/// Rounded budget summary card, used in the budgets list. Shows
/// budget/spent/remaining/percentage plus a threshold-colored progress
/// bar and status label (Healthy/Warning/Critical).
class BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback? onTap;

  const BudgetCard({super.key, required this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final budget = progress.budget;
    final statusColor = _statusColor(colorScheme, progress.percentageUsed);
    final statusLabel = _statusLabel(progress.percentageUsed);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      _categoryIcon(budget.category),
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          budget.period.label,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${progress.percentageUsed.toStringAsFixed(0)}% used',
                  style: textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.progressFraction,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AmountColumn(label: 'Budget', value: budget.amount),
                  _AmountColumn(label: 'Spent', value: progress.spentAmount),
                  _AmountColumn(
                    label: 'Remaining',
                    value: progress.remainingAmount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 0-49% primary, 50-74% amber, 75-89% orange, 90%+ red.
  Color _statusColor(ColorScheme colorScheme, double percentage) {
    if (percentage >= 90) return colorScheme.error;
    if (percentage >= 75) return AppColors.warning;
    if (percentage >= 50) return AppColors.tertiary;
    return colorScheme.primary;
  }

  String _statusLabel(double percentage) {
    if (percentage >= 90) return 'Critical';
    if (percentage >= 50) return 'Warning';
    return 'Healthy';
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.local_gas_station_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'bills':
        return Icons.receipt_long_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'healthcare':
        return Icons.medical_services_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double value;

  const _AmountColumn({required this.label, required this.value});

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
