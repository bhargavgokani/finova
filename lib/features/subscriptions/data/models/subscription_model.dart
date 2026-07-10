enum BillingCycle { weekly, monthly, yearly }

extension BillingCycleLabel on BillingCycle {
  String get label {
    switch (this) {
      case BillingCycle.weekly:
        return 'Weekly';
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }
}

class SubscriptionModel {
  final String id;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextRenewalDate;
  final String category;

  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextRenewalDate,
    required this.category,
  });
}
