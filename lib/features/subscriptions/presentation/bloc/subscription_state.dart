import 'package:equatable/equatable.dart';

import '../../data/models/subscription_model.dart';

class SubscriptionState extends Equatable {
  final List<SubscriptionModel> subscriptions;
  final double monthlyCost;
  final bool isLoading;

  const SubscriptionState({
    this.subscriptions = const [],
    this.monthlyCost = 0,
    this.isLoading = true,
  });

  SubscriptionState copyWith({
    List<SubscriptionModel>? subscriptions,
    double? monthlyCost,
    bool? isLoading,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [subscriptions, monthlyCost, isLoading];
}
