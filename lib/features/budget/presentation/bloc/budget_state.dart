import 'package:equatable/equatable.dart';

import '../../data/models/budget_model.dart';

/// A single budget paired with how much has actually been spent in its
/// category, computed by BudgetBloc from TransactionRepository.
class BudgetProgress {
  final BudgetModel budget;
  final double spentAmount;

  const BudgetProgress({required this.budget, required this.spentAmount});

  double get remainingAmount => budget.amount - spentAmount;

  double get percentageUsed =>
      budget.amount <= 0 ? 0 : (spentAmount / budget.amount) * 100;

  // Clamped to [0, 1] for LinearProgressIndicator's value.
  double get progressFraction =>
      budget.amount <= 0 ? 0 : (spentAmount / budget.amount).clamp(0, 1);
}

class BudgetState extends Equatable {
  final List<BudgetProgress> budgetProgress;
  final bool isLoading;

  const BudgetState({this.budgetProgress = const [], this.isLoading = true});

  BudgetState copyWith({
    List<BudgetProgress>? budgetProgress,
    bool? isLoading,
  }) {
    return BudgetState(
      budgetProgress: budgetProgress ?? this.budgetProgress,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [budgetProgress, isLoading];
}
