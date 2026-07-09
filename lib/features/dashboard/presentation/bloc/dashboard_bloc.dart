import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/data/repositories/transaction_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionRepository _transactionRepository;

  DashboardBloc(this._transactionRepository) : super(const DashboardState()) {
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
      isLoading: false,
    );
  }

  double _calculateSavingsRate(double income, double expense) {
    if (income <= 0) return 0;
    return ((income - expense) / income) * 100;
  }
}
