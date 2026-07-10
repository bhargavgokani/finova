import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionBloc(this._subscriptionRepository)
    : super(const SubscriptionState()) {
    // Currently both events reload the subscription list.
    // Keeping separate events allows different behavior later.
    on<LoadSubscriptions>((event, emit) => emit(_loadSubscriptions()));
    on<RefreshSubscriptions>((event, emit) => emit(_loadSubscriptions()));
    on<AddSubscription>(_onAddSubscription);
    on<UpdateSubscription>(_onUpdateSubscription);
    on<DeleteSubscription>(_onDeleteSubscription);
  }

  void _onAddSubscription(
    AddSubscription event,
    Emitter<SubscriptionState> emit,
  ) {
    _subscriptionRepository.addSubscription(event.subscription);
    emit(_loadSubscriptions());
  }

  void _onUpdateSubscription(
    UpdateSubscription event,
    Emitter<SubscriptionState> emit,
  ) {
    _subscriptionRepository.updateSubscription(event.subscription);
    emit(_loadSubscriptions());
  }

  void _onDeleteSubscription(
    DeleteSubscription event,
    Emitter<SubscriptionState> emit,
  ) {
    _subscriptionRepository.deleteSubscription(event.id);
    emit(_loadSubscriptions());
  }

  SubscriptionState _loadSubscriptions() {
    return SubscriptionState(
      subscriptions: _subscriptionRepository.getSubscriptions(),
      monthlyCost: _subscriptionRepository.calculateMonthlyCost(),
      isLoading: false,
    );
  }
}
