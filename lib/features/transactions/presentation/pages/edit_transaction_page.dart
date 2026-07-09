import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/transaction_form.dart';

/// Edits an existing transaction using the TransactionBloc shared with
/// TransactionsPage, so the list refreshes automatically once this screen
/// is popped.
class EditTransactionPage extends StatelessWidget {
  final TransactionModel transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransactionForm(
          initialTransaction: transaction,
          submitLabel: 'Update',
          onSubmit: (updated) {
            context.read<TransactionBloc>().add(UpdateTransaction(updated));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
