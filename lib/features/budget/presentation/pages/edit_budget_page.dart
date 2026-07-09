import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/budget_model.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../widgets/budget_form.dart';

/// Edits an existing budget using the BudgetBloc shared with BudgetPage, so
/// the list refreshes automatically once this screen is popped.
class EditBudgetPage extends StatelessWidget {
  final BudgetModel budget;

  const EditBudgetPage({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BudgetForm(
          initialBudget: budget,
          submitLabel: 'Update',
          onSubmit: (updated) {
            context.read<BudgetBloc>().add(UpdateBudget(updated));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
