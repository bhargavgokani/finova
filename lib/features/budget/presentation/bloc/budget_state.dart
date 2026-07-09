import 'package:equatable/equatable.dart';

import '../../data/models/budget_model.dart';

class BudgetState extends Equatable {
  final List<BudgetModel> budgets;
  final bool isLoading;

  const BudgetState({this.budgets = const [], this.isLoading = true});

  BudgetState copyWith({List<BudgetModel>? budgets, bool? isLoading}) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [budgets, isLoading];
}
