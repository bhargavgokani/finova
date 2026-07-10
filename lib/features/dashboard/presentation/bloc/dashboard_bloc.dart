import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../budget/data/repositories/budget_repository.dart';
import '../../../subscriptions/data/repositories/subscription_repository.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final SubscriptionRepository _subscriptionRepository;

  DashboardBloc(
    this._transactionRepository,
    this._budgetRepository,
    this._subscriptionRepository,
  ) : super(const DashboardState()) {
    // Currently both events reload the dashboard.
    // Keeping separate events allows different behavior later.
    on<LoadDashboard>((event, emit) => emit(_loadDashboardData()));
    on<RefreshDashboard>((event, emit) => emit(_loadDashboardData()));
  }

  DashboardState _loadDashboardData() {
    final monthlyIncome = _transactionRepository.calculateMonthlyIncome();
    final monthlyExpense = _transactionRepository.calculateMonthlyExpense();

    return DashboardState(
      totalBalance: _transactionRepository.calculateTotalBalance(),
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      savingsRate: _calculateSavingsRate(monthlyIncome, monthlyExpense),
      recentTransactions: _transactionRepository.getRecentTransactions(5),
      budgetOverview: _buildBudgetOverview(),
      weeklySpending: _transactionRepository.calculateWeeklySpending(),
      monthlySubscriptionCost: _subscriptionRepository.calculateMonthlyCost(),
      upcomingRenewals: _subscriptionRepository.getUpcomingRenewals(),
      isLoading: false,
    );
  }

  List<BudgetOverviewItem> _buildBudgetOverview() {
    return _budgetRepository.getBudgets().map((budget) {
      return BudgetOverviewItem(
        category: budget.category,
        budgetAmount: budget.amount,
        spentAmount: _transactionRepository.calculateSpentForCategory(
          budget.category,
        ),
      );
    }).toList();
  }

  double _calculateSavingsRate(double income, double expense) {
    if (income <= 0) return 0;
    return ((income - expense) / income) * 100;
  }
}
