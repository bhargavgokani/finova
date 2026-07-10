import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/greeting_helper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import '../../../subscriptions/data/models/subscription_model.dart';
import '../../../subscriptions/presentation/pages/subscriptions_page.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/monthly_spending_chart.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';

// Adding a transaction happens through its own TransactionBloc, separate
// from DashboardBloc, so the dashboard is told to refresh once the user
// comes back - keeping balances/charts/recent transactions in sync.
Future<void> _openAddTransactionPage(BuildContext context) async {
  final dashboardBloc = context.read<DashboardBloc>();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            locator<TransactionBloc>()..add(const LoadTransactions()),
        child: const AddTransactionPage(),
      ),
    ),
  );
  dashboardBloc.add(const RefreshDashboard());
}

// Receipt scanning can end with a new transaction too, so refresh the
// dashboard once the user is back from that flow as well.
Future<void> _openReceiptScannerPage(BuildContext context) async {
  final dashboardBloc = context.read<DashboardBloc>();
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ReceiptScannerPage()),
  );
  dashboardBloc.add(const RefreshDashboard());
}

Future<void> _openSubscriptionsPage(BuildContext context) async {
  final dashboardBloc = context.read<DashboardBloc>();
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SubscriptionsPage()),
  );
  dashboardBloc.add(const RefreshDashboard());
}

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
                  const _QuickActions(),
                  const SizedBox(height: 24),
                  _MonthlySpendingSection(state: state),
                  const SizedBox(height: 24),
                  _BudgetOverviewSection(state: state),
                  const SizedBox(height: 24),
                  _SubscriptionsSection(state: state),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.add_circle_outline,
                label: 'Add Transaction',
                onTap: () => _openAddTransactionPage(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.bar_chart_outlined,
                label: 'View Reports',
                onTap: () => context.push(AppRoutes.analytics),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.document_scanner_outlined,
                label: 'Scan Receipt',
                onTap: () => _openReceiptScannerPage(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthlySpendingSection extends StatelessWidget {
  final DashboardState state;

  const _MonthlySpendingSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSpending = state.weeklySpending.any((amount) => amount > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Spending',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hasSpending)
          MonthlySpendingChart(weeklySpending: state.weeklySpending)
        else
          const EmptyState(
            icon: Icons.bar_chart_outlined,
            title: 'No spending yet',
            message:
                'Your weekly spending chart will appear once you add '
                'expenses.',
            padding: EdgeInsets.symmetric(vertical: 24),
          ),
      ],
    );
  }
}

class _BudgetOverviewSection extends StatelessWidget {
  final DashboardState state;

  const _BudgetOverviewSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Overview',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.budgetOverview.isEmpty)
          const EmptyState(
            icon: Icons.savings_outlined,
            title: 'No Budget Overview',
            message: 'Create a budget to see your spending progress here.',
            padding: EdgeInsets.symmetric(vertical: 24),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.budgetOverview.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                BudgetOverviewCard(item: state.budgetOverview[index]),
          ),
      ],
    );
  }
}

class _SubscriptionsSection extends StatelessWidget {
  final DashboardState state;

  const _SubscriptionsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasSubscriptions = state.monthlySubscriptionCost > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subscriptions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _openSubscriptionsPage(context),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (!hasSubscriptions)
          const EmptyState(
            icon: Icons.subscriptions_outlined,
            title: 'No Subscription Summary',
            message: 'Add a subscription to see its cost and renewals here.',
            padding: EdgeInsets.symmetric(vertical: 24),
          )
        else ...[
          SummaryCard(
            icon: Icons.subscriptions_outlined,
            title: 'Monthly Subscription Cost',
            value: formatCurrency(state.monthlySubscriptionCost),
          ),
          const SizedBox(height: 16),
          Text(
            'Upcoming Renewals',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (state.upcomingRenewals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No renewals in the next 7 days',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.upcomingRenewals.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _UpcomingRenewalTile(
                subscription: state.upcomingRenewals[index],
              ),
            ),
        ],
      ],
    );
  }
}

class _UpcomingRenewalTile extends StatelessWidget {
  final SubscriptionModel subscription;

  const _UpcomingRenewalTile({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.subscriptions_outlined,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(subscription.name),
      subtitle: Text(
        'Renews ${DateFormat('dd MMM yyyy').format(subscription.nextRenewalDate)}',
      ),
      trailing: Text(
        formatCurrency(subscription.amount),
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
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
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Recent Transactions',
            message: 'Your latest transactions will show up here.',
            padding: const EdgeInsets.symmetric(vertical: 24),
            actionLabel: 'Add Transaction',
            onAction: () => _openAddTransactionPage(context),
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
