import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/greeting_helper.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<DashboardBloc>()..add(const LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const RefreshDashboard());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _Greeting(),
                  const SizedBox(height: 24),
                  _SummaryGrid(state: state),
                  const SizedBox(height: 24),
                  _RecentTransactions(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getGreeting(),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome back!',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final DashboardState state;

  const _SummaryGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        SummaryCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Total Balance',
          value: formatCurrency(state.totalBalance),
        ),
        SummaryCard(
          icon: Icons.arrow_downward_rounded,
          title: 'Monthly Income',
          value: formatCurrency(state.monthlyIncome),
          valueColor: AppColors.success,
        ),
        SummaryCard(
          icon: Icons.arrow_upward_rounded,
          title: 'Monthly Expense',
          value: formatCurrency(state.monthlyExpense),
          valueColor: AppColors.error,
        ),
        SummaryCard(
          icon: Icons.savings_outlined,
          title: 'Savings Rate',
          value: '${state.savingsRate.toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final DashboardState state;

  const _RecentTransactions({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (state.recentTransactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No transactions available')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentTransactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                TransactionTile(transaction: state.recentTransactions[index]),
          ),
      ],
    );
  }
}
