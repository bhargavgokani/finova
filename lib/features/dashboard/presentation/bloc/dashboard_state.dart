import 'package:equatable/equatable.dart';

import '../../../transactions/data/models/transaction_model.dart';

class DashboardState extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double savingsRate;
  final List<TransactionModel> recentTransactions;
  final bool isLoading;

  const DashboardState({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.savingsRate = 0,
    this.recentTransactions = const [],
    this.isLoading = true,
  });

  DashboardState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? savingsRate,
    List<TransactionModel>? recentTransactions,
    bool? isLoading,
  }) {
    return DashboardState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      savingsRate: savingsRate ?? this.savingsRate,
      recentTransactions: recentTransactions ?? this.recentTransactions,
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
    isLoading,
  ];
}
