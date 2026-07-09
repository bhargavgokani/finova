import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount);
}
