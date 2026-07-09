import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/widgets/transaction_tile.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<TransactionBloc>()..add(const LoadTransactions()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transactionsTitle)),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  hintText: 'Search transactions',
                  leading: const Icon(Icons.search),
                  onChanged: (query) => context.read<TransactionBloc>().add(
                    SearchTransactions(query),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<TransactionBloc>().add(
                      const RefreshTransactions(),
                    );
                  },
                  child: _TransactionsList(state: state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final TransactionState state;

  const _TransactionsList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.filteredTransactions.isEmpty) {
      return state.transactions.isEmpty
          ? const _EmptyState(
              icon: Icons.description_outlined,
              message: 'No transactions available',
            )
          : const _EmptyState(
              icon: Icons.search_off,
              message: 'No matching transactions',
            );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.filteredTransactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          TransactionTile(transaction: state.filteredTransactions[index]),
    );
  }
}

/// Shared empty-state layout, kept scrollable so pull-to-refresh still
/// works when the list has nothing to show.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
