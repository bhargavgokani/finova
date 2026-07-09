enum BudgetPeriod { monthly, weekly }

extension BudgetPeriodLabel on BudgetPeriod {
  String get label {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.weekly:
        return 'Weekly';
    }
  }
}

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final BudgetPeriod period;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
  });
}
