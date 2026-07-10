import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../../data/models/budget_model.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_card.dart';
import 'add_budget_page.dart';
import 'edit_budget_page.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<BudgetBloc>()..add(const LoadBudgets()),
      child: const _BudgetView(),
    );
  }
}

class _BudgetView extends StatelessWidget {
  const _BudgetView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.budgetTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddBudgetPage(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BudgetBloc>().add(const RefreshBudgets());
            },
            child: _BudgetList(budgetProgress: state.budgetProgress),
          );
        },
      ),
    );
  }

  void _openAddBudgetPage(BuildContext context) {
    final budgetBloc = context.read<BudgetBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: budgetBloc, child: const AddBudgetPage()),
      ),
    );
  }
}

class _BudgetSummaryRow extends StatelessWidget {
  final List<BudgetProgress> budgetProgress;

  const _BudgetSummaryRow({required this.budgetProgress});

  @override
  Widget build(BuildContext context) {
    final totalBudget = budgetProgress.fold(
      0.0,
      (sum, p) => sum + p.budget.amount,
    );
    final totalSpent = budgetProgress.fold(
      0.0,
      (sum, p) => sum + p.spentAmount,
    );
    final totalRemaining = totalBudget - totalSpent;

    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Total Budget',
            value: formatCurrency(totalBudget),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            icon: Icons.arrow_upward_rounded,
            title: 'Total Spent',
            value: formatCurrency(totalSpent),
            valueColor: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            icon: Icons.savings_outlined,
            title: 'Remaining',
            value: formatCurrency(totalRemaining),
            valueColor: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _BudgetList extends StatelessWidget {
  final List<BudgetProgress> budgetProgress;

  const _BudgetList({required this.budgetProgress});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BudgetSummaryRow(budgetProgress: budgetProgress),
        const SizedBox(height: 24),
        if (budgetProgress.isEmpty)
          const _EmptyBudgets()
        else
          for (final progress in budgetProgress) ...[
            Dismissible(
              key: ValueKey(progress.budget.id),
              direction: DismissDirection.endToStart,
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              confirmDismiss: (_) => _confirmDelete(context),
              onDismissed: (_) => context.read<BudgetBloc>().add(
                DeleteBudget(progress.budget.id),
              ),
              child: BudgetCard(
                progress: progress,
                onTap: () => _openEditBudgetPage(context, progress.budget),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _openEditBudgetPage(BuildContext context, BudgetModel budget) {
    final budgetBloc = context.read<BudgetBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: budgetBloc,
          child: EditBudgetPage(budget: budget),
        ),
      ),
    );
  }
}

class _EmptyBudgets extends StatelessWidget {
  const _EmptyBudgets();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.savings_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No budgets available',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
