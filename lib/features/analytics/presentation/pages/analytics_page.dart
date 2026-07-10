import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/section_card.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/financial_insights_card.dart';
import '../widgets/income_expense_line_chart.dart';
import '../widgets/monthly_comparison_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AnalyticsBloc>()..add(const LoadAnalytics()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analyticsTitle)),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DateRangeSelector(selected: state.selectedDateRange),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Expense Breakdown',
                child: ExpensePieChart(
                  expenseByCategory: state.expenseByCategory,
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Income vs Expense',
                child: IncomeExpenseLineChart(data: state.incomeVsExpense),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Monthly Comparison',
                child: MonthlyComparisonChart(data: state.monthlyComparison),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Top Spending Categories',
                child: _TopSpendingCategories(
                  expenseByCategory: state.expenseByCategory,
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Insights & Recommendations',
                child: FinancialInsightsCard(
                  currentMonth: state.monthlyComparison.last,
                  currentMonthExpenseByCategory:
                      state.currentMonthExpenseByCategory,
                  previousMonthExpenseByCategory:
                      state.previousMonthExpenseByCategory,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final AnalyticsDateRange selected;

  const _DateRangeSelector({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton<AnalyticsDateRange>(
        segments: AnalyticsDateRange.values
            .map(
              (range) => ButtonSegment(value: range, label: Text(range.label)),
            )
            .toList(),
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          context.read<AnalyticsBloc>().add(ChangeDateRange(selection.first));
        },
      ),
    );
  }
}

/// Top 5 categories from the selected date range's expense breakdown.
/// Used only on this page, so it stays private here rather than in
/// widgets/.
class _TopSpendingCategories extends StatelessWidget {
  final Map<String, double> expenseByCategory;

  const _TopSpendingCategories({required this.expenseByCategory});

  @override
  Widget build(BuildContext context) {
    final total = expenseByCategory.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    if (total <= 0) {
      final colorScheme = Theme.of(context).colorScheme;
      return Text(
        'No expenses in this period',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }

    final topCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topCategories.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < top5.length; i++) ...[
          _CategoryRow(
            category: top5[i].key,
            amount: top5[i].value,
            percentage: (top5[i].value / total) * 100,
          ),
          if (i != top5.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formatCurrency(amount),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(0)}% of total expenses',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
