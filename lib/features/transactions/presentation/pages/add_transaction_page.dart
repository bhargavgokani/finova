import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/transaction_form.dart';

/// Adds a transaction using the TransactionBloc shared with TransactionsPage,
/// so the list refreshes automatically once this screen is popped.
class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionForm(
          onSubmit: (transaction) {
            context.read<TransactionBloc>().add(AddTransaction(transaction));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
