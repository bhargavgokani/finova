import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/income_expense_line_chart.dart';

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
              _Section(
                title: 'Expense Breakdown',
                child: ExpensePieChart(
                  expenseByCategory: state.expenseByCategory,
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Income vs Expense',
                child: IncomeExpenseLineChart(data: state.incomeVsExpense),
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }
}
