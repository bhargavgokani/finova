import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;

  BudgetBloc(this._budgetRepository) : super(const BudgetState()) {
    // Currently both events reload the budget list.
    // Keeping separate events allows different behavior later.
    on<LoadBudgets>((event, emit) => emit(_loadBudgets()));
    on<RefreshBudgets>((event, emit) => emit(_loadBudgets()));
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  void _onAddBudget(AddBudget event, Emitter<BudgetState> emit) {
    _budgetRepository.addBudget(event.budget);
    emit(_loadBudgets());
  }

  void _onUpdateBudget(UpdateBudget event, Emitter<BudgetState> emit) {
    _budgetRepository.updateBudget(event.budget);
    emit(_loadBudgets());
  }

  void _onDeleteBudget(DeleteBudget event, Emitter<BudgetState> emit) {
    _budgetRepository.deleteBudget(event.id);
    emit(_loadBudgets());
  }

  BudgetState _loadBudgets() {
    return BudgetState(
      budgets: _budgetRepository.getBudgets(),
      isLoading: false,
    );
  }
}
