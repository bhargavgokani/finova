import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../dashboard/presentation/widgets/summary_card.dart';
import '../../data/models/subscription_model.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../widgets/subscription_card.dart';
import 'add_subscription_page.dart';
import 'edit_subscription_page.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<SubscriptionBloc>()..add(const LoadSubscriptions()),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subscriptionsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSubscriptionPage(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SubscriptionBloc>().add(
                const RefreshSubscriptions(),
              );
            },
            child: _SubscriptionList(state: state),
          );
        },
      ),
    );
  }

  void _openAddSubscriptionPage(BuildContext context) {
    final subscriptionBloc = context.read<SubscriptionBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: subscriptionBloc,
          child: const AddSubscriptionPage(),
        ),
      ),
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  final SubscriptionState state;

  const _SubscriptionList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.subscriptions.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: EmptyState(
                  icon: Icons.subscriptions_outlined,
                  title: 'No subscriptions added',
                  message:
                      'Add a recurring subscription to keep track of its '
                      'renewals and cost.',
                  actionLabel: 'Add Subscription',
                  onAction: () => _openAddSubscriptionPage(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SummaryCard(
          icon: Icons.subscriptions_outlined,
          title: 'Monthly Subscription Cost',
          value: formatCurrency(state.monthlyCost),
        ),
        const SizedBox(height: 24),
        for (final subscription in state.subscriptions) ...[
          Dismissible(
            key: ValueKey(subscription.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            confirmDismiss: (_) => _confirmDelete(context),
            onDismissed: (_) => context.read<SubscriptionBloc>().add(
              DeleteSubscription(subscription.id),
            ),
            child: SubscriptionCard(
              subscription: subscription,
              onTap: () => _openEditSubscriptionPage(context, subscription),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: const Text(
          'Are you sure you want to delete this subscription?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _openEditSubscriptionPage(
    BuildContext context,
    SubscriptionModel subscription,
  ) {
    final subscriptionBloc = context.read<SubscriptionBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: subscriptionBloc,
          child: EditSubscriptionPage(subscription: subscription),
        ),
      ),
    );
  }

  void _openAddSubscriptionPage(BuildContext context) {
    final subscriptionBloc = context.read<SubscriptionBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: subscriptionBloc,
          child: const AddSubscriptionPage(),
        ),
      ),
    );
  }
}
