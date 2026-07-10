import '../models/subscription_model.dart';

/// In-memory subscription data source.
///
/// There is no backend yet - everything lives in a local list. Swap this
/// out for a real data source later without changing the method signatures.
class SubscriptionRepository {
  final List<SubscriptionModel> _subscriptions = _buildMockSubscriptions();

  List<SubscriptionModel> getSubscriptions() =>
      List.unmodifiable(_subscriptions);

  void addSubscription(SubscriptionModel subscription) {
    _subscriptions.add(subscription);
  }

  void updateSubscription(SubscriptionModel subscription) {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index == -1) return;
    _subscriptions[index] = subscription;
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
  }

  // Normalizes every subscription's cost to a monthly equivalent and sums
  // them, so weekly/monthly/yearly plans can be compared on one basis.
  double calculateMonthlyCost() {
    return _subscriptions.fold(0.0, (sum, s) => sum + _monthlyEquivalent(s));
  }

  // Subscriptions renewing within the next [withinDays] days (today
  // included), soonest first.
  List<SubscriptionModel> getUpcomingRenewals({int withinDays = 7}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.add(Duration(days: withinDays));

    final upcoming =
        _subscriptions
            .where(
              (s) =>
                  !s.nextRenewalDate.isBefore(today) &&
                  !s.nextRenewalDate.isAfter(cutoff),
            )
            .toList()
          ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));

    return upcoming;
  }

  double _monthlyEquivalent(SubscriptionModel subscription) {
    switch (subscription.billingCycle) {
      case BillingCycle.weekly:
        return subscription.amount * 52 / 12;
      case BillingCycle.monthly:
        return subscription.amount;
      case BillingCycle.yearly:
        return subscription.amount / 12;
    }
  }

  // No seeded data - the user adds their own subscriptions.
  static List<SubscriptionModel> _buildMockSubscriptions() => [];
}
