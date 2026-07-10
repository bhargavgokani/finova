import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/subscription_model.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../widgets/subscription_form.dart';

/// Edits an existing subscription using the SubscriptionBloc shared with
/// SubscriptionsPage, so the list refreshes automatically once this
/// screen is popped.
class EditSubscriptionPage extends StatelessWidget {
  final SubscriptionModel subscription;

  const EditSubscriptionPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SubscriptionForm(
          initialSubscription: subscription,
          submitLabel: 'Update',
          onSubmit: (updated) {
            context.read<SubscriptionBloc>().add(UpdateSubscription(updated));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
