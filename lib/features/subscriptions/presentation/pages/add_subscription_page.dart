import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../widgets/subscription_form.dart';

/// Adds a subscription using the SubscriptionBloc shared with
/// SubscriptionsPage, so the list refreshes automatically once this
/// screen is popped.
class AddSubscriptionPage extends StatelessWidget {
  const AddSubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SubscriptionForm(
          onSubmit: (subscription) {
            context.read<SubscriptionBloc>().add(AddSubscription(subscription));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
