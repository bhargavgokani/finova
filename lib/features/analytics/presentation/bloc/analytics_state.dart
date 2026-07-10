import 'package:equatable/equatable.dart';

import '../../../transactions/data/repositories/transaction_repository.dart';

enum AnalyticsDateRange { thisMonth, last3Months }

extension AnalyticsDateRangeLabel on AnalyticsDateRange {
  String get label {
    switch (this) {
      case AnalyticsDateRange.thisMonth:
        return 'This Month';
      case AnalyticsDateRange.last3Months:
        return 'Last 3 Months';
    }
  }

  int get monthsBack {
    switch (this) {
      case AnalyticsDateRange.thisMonth:
        return 1;
      case AnalyticsDateRange.last3Months:
        return 3;
    }
  }
}

class AnalyticsState extends Equatable {
  final AnalyticsDateRange selectedDateRange;
  final Map<String, double> expenseByCategory;
  final List<MonthlyTotal> incomeVsExpense;
  final bool isLoading;

  const AnalyticsState({
    this.selectedDateRange = AnalyticsDateRange.thisMonth,
    this.expenseByCategory = const {},
    this.incomeVsExpense = const [],
    this.isLoading = true,
  });

  AnalyticsState copyWith({
    AnalyticsDateRange? selectedDateRange,
    Map<String, double>? expenseByCategory,
    List<MonthlyTotal>? incomeVsExpense,
    bool? isLoading,
  }) {
    return AnalyticsState(
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      incomeVsExpense: incomeVsExpense ?? this.incomeVsExpense,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    selectedDateRange,
    expenseByCategory,
    incomeVsExpense,
    isLoading,
  ];
}
