import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/data/repositories/transaction_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final TransactionRepository _transactionRepository;

  AnalyticsBloc(this._transactionRepository) : super(const AnalyticsState()) {
    on<LoadAnalytics>(
      (event, emit) => emit(_loadAnalytics(state.selectedDateRange)),
    );
    on<ChangeDateRange>((event, emit) => emit(_loadAnalytics(event.dateRange)));
  }

  AnalyticsState _loadAnalytics(AnalyticsDateRange dateRange) {
    return AnalyticsState(
      selectedDateRange: dateRange,
      expenseByCategory: _transactionRepository.calculateExpenseByCategory(
        monthsBack: dateRange.monthsBack,
      ),
      incomeVsExpense: _transactionRepository.calculateIncomeVsExpense(
        monthsBack: dateRange.monthsBack,
      ),
      isLoading: false,
    );
  }
}
