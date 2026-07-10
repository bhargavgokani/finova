import 'package:equatable/equatable.dart';

import '../../data/models/subscription_model.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {
  const LoadSubscriptions();
}

class RefreshSubscriptions extends SubscriptionEvent {
  const RefreshSubscriptions();
}

class AddSubscription extends SubscriptionEvent {
  final SubscriptionModel subscription;

  const AddSubscription(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class UpdateSubscription extends SubscriptionEvent {
  final SubscriptionModel subscription;

  const UpdateSubscription(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class DeleteSubscription extends SubscriptionEvent {
  final String id;

  const DeleteSubscription(this.id);

  @override
  List<Object?> get props => [id];
}
