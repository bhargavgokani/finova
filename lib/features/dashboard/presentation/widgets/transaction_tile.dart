import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/data/models/transaction_model.dart';

/// List tile used for a single transaction, shared by any screen that
/// lists transactions (currently just the dashboard's recent list).
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isIncome = transaction.transactionType == TransactionType.income;
    final amountColor = isIncome ? AppColors.success : AppColors.error;
    final amountPrefix = isIncome ? '+' : '-';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          _categoryIcon(transaction.category),
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(transaction.title),
      subtitle: Text(DateFormat('dd MMM yyyy').format(transaction.date)),
      trailing: Text(
        '$amountPrefix${formatCurrency(transaction.amount)}',
        style: textTheme.titleSmall?.copyWith(
          color: amountColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
      case 'freelance':
        return Icons.attach_money;
      case 'groceries':
        return Icons.local_grocery_store_outlined;
      case 'subscription':
        return Icons.subscriptions_outlined;
      case 'transport':
        return Icons.local_gas_station_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      case 'food & dining':
        return Icons.restaurant_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
