import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/draft_transaction_service.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/transaction_form.dart';

/// Adds a transaction using the TransactionBloc shared with TransactionsPage,
/// so the list refreshes automatically once this screen is popped.
///
/// Automatically restores a previously saved draft, if there is one.
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late final Future<TransactionModel?> _draftFuture;

  @override
  void initState() {
    super.initState();
    _draftFuture = locator<DraftTransactionService>().getDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<TransactionModel?>(
          future: _draftFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return TransactionForm(
              initialDraft: snapshot.data,
              onSubmit: (transaction) {
                context.read<TransactionBloc>().add(
                  AddTransaction(transaction),
                );
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
