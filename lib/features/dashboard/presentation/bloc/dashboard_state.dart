import 'package:equatable/equatable.dart';

import '../../../transactions/data/models/transaction_model.dart';

/// A single budget's spend-vs-limit numbers, computed for the dashboard's
/// Budget Overview section.
class BudgetOverviewItem {
  final String category;
  final double budgetAmount;
  final double spentAmount;

  const BudgetOverviewItem({
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
  });

  double get remainingAmount => budgetAmount - spentAmount;

  bool get isOverBudget => spentAmount > budgetAmount;

  double get percentage =>
      budgetAmount <= 0 ? 0 : (spentAmount / budgetAmount) * 100;

  // Clamped to [0, 1] for LinearProgressIndicator's value.
  double get progress =>
      budgetAmount <= 0 ? 0 : (spentAmount / budgetAmount).clamp(0, 1);
}

class DashboardState extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double savingsRate;
  final List<TransactionModel> recentTransactions;
  final List<BudgetOverviewItem> budgetOverview;
  final List<double> weeklySpending;
  final bool isLoading;

  const DashboardState({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.savingsRate = 0,
    this.recentTransactions = const [],
    this.budgetOverview = const [],
    this.weeklySpending = const [0, 0, 0, 0],
    this.isLoading = true,
  });

  DashboardState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? savingsRate,
    List<TransactionModel>? recentTransactions,
    List<BudgetOverviewItem>? budgetOverview,
    List<double>? weeklySpending,
    bool? isLoading,
  }) {
    return DashboardState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      savingsRate: savingsRate ?? this.savingsRate,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      budgetOverview: budgetOverview ?? this.budgetOverview,
      weeklySpending: weeklySpending ?? this.weeklySpending,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    totalBalance,
    monthlyIncome,
    monthlyExpense,
    savingsRate,
    recentTransactions,
    budgetOverview,
    weeklySpending,
    isLoading,
  ];
}
