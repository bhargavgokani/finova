import 'package:shared_preferences/shared_preferences.dart';

import '../../features/transactions/data/models/transaction_model.dart';

/// Persists a single in-progress "Add Transaction" draft using
/// SharedPreferences, so the form can restore it if the user leaves and
/// comes back. Only ever one draft at a time - saving a new one replaces
/// whatever was there before.
class DraftTransactionService {
  static const String _hasDraftKey = 'draft_transaction_exists';
  static const String _titleKey = 'draft_transaction_title';
  static const String _amountKey = 'draft_transaction_amount';
  static const String _categoryKey = 'draft_transaction_category';
  static const String _paymentMethodKey = 'draft_transaction_payment_method';
  static const String _transactionTypeKey = 'draft_transaction_type';
  static const String _dateKey = 'draft_transaction_date';
  static const String _notesKey = 'draft_transaction_notes';
  static const String _tagsKey = 'draft_transaction_tags';
  static const String _isRecurringKey = 'draft_transaction_is_recurring';
  static const String _receiptImagePathKey =
      'draft_transaction_receipt_image_path';

  Future<void> saveDraft(TransactionModel draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasDraftKey, true);
    await prefs.setString(_titleKey, draft.title);
    await prefs.setDouble(_amountKey, draft.amount);
    await prefs.setString(_categoryKey, draft.category);
    await prefs.setString(_paymentMethodKey, draft.paymentMethod.name);
    await prefs.setString(_transactionTypeKey, draft.transactionType.name);
    await prefs.setString(_dateKey, draft.date.toIso8601String());
    await prefs.setString(_notesKey, draft.notes ?? '');
    await prefs.setStringList(_tagsKey, draft.tags);
    await prefs.setBool(_isRecurringKey, draft.isRecurring);
    await prefs.setString(_receiptImagePathKey, draft.receiptImagePath ?? '');
  }

  Future<TransactionModel?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_hasDraftKey) ?? false)) return null;

    final dateString = prefs.getString(_dateKey);
    final paymentMethodName = prefs.getString(_paymentMethodKey);
    final transactionTypeName = prefs.getString(_transactionTypeKey);

    return TransactionModel(
      id: '',
      title: prefs.getString(_titleKey) ?? '',
      amount: prefs.getDouble(_amountKey) ?? 0,
      date: dateString != null ? DateTime.parse(dateString) : DateTime.now(),
      category: prefs.getString(_categoryKey) ?? '',
      transactionType: TransactionType.values.firstWhere(
        (type) => type.name == transactionTypeName,
        orElse: () => TransactionType.expense,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.name == paymentMethodName,
        orElse: () => PaymentMethod.cash,
      ),
      notes: _emptyToNull(prefs.getString(_notesKey)),
      receiptImagePath: _emptyToNull(prefs.getString(_receiptImagePathKey)),
      tags: prefs.getStringList(_tagsKey) ?? const [],
      isRecurring: prefs.getBool(_isRecurringKey) ?? false,
    );
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasDraftKey);
    await prefs.remove(_titleKey);
    await prefs.remove(_amountKey);
    await prefs.remove(_categoryKey);
    await prefs.remove(_paymentMethodKey);
    await prefs.remove(_transactionTypeKey);
    await prefs.remove(_dateKey);
    await prefs.remove(_notesKey);
    await prefs.remove(_tagsKey);
    await prefs.remove(_isRecurringKey);
    await prefs.remove(_receiptImagePathKey);
  }

  String? _emptyToNull(String? value) {
    return (value == null || value.isEmpty) ? null : value;
  }
}
