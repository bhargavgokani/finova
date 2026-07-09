import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../widgets/budget_form.dart';

/// Adds a budget using the BudgetBloc shared with BudgetPage, so the list
/// refreshes automatically once this screen is popped.
class AddBudgetPage extends StatelessWidget {
  const AddBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BudgetForm(
          onSubmit: (budget) {
            context.read<BudgetBloc>().add(AddBudget(budget));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
