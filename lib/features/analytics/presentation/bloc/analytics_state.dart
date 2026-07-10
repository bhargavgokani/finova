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
  // Always the previous 6 months, independent of selectedDateRange - used
  // by the Monthly Comparison chart.
  final List<MonthlyTotal> monthlyComparison;
  // Always this/last calendar month, independent of selectedDateRange -
  // used by the Insights & Recommendations section.
  final Map<String, double> currentMonthExpenseByCategory;
  final Map<String, double> previousMonthExpenseByCategory;
  final bool isLoading;

  const AnalyticsState({
    this.selectedDateRange = AnalyticsDateRange.thisMonth,
    this.expenseByCategory = const {},
    this.incomeVsExpense = const [],
    this.monthlyComparison = const [],
    this.currentMonthExpenseByCategory = const {},
    this.previousMonthExpenseByCategory = const {},
    this.isLoading = true,
  });

  AnalyticsState copyWith({
    AnalyticsDateRange? selectedDateRange,
    Map<String, double>? expenseByCategory,
    List<MonthlyTotal>? incomeVsExpense,
    List<MonthlyTotal>? monthlyComparison,
    Map<String, double>? currentMonthExpenseByCategory,
    Map<String, double>? previousMonthExpenseByCategory,
    bool? isLoading,
  }) {
    return AnalyticsState(
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      incomeVsExpense: incomeVsExpense ?? this.incomeVsExpense,
      monthlyComparison: monthlyComparison ?? this.monthlyComparison,
      currentMonthExpenseByCategory:
          currentMonthExpenseByCategory ?? this.currentMonthExpenseByCategory,
      previousMonthExpenseByCategory:
          previousMonthExpenseByCategory ?? this.previousMonthExpenseByCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    selectedDateRange,
    expenseByCategory,
    incomeVsExpense,
    monthlyComparison,
    currentMonthExpenseByCategory,
    previousMonthExpenseByCategory,
    isLoading,
  ];
}
