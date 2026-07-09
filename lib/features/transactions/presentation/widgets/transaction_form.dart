import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';

const List<String> _predefinedCategories = [
  'Salary',
  'Freelancing',
  'Food',
  'Shopping',
  'Bills',
  'Transport',
  'Entertainment',
  'Healthcare',
  'Other',
];

/// Add/Edit transaction form, shared by AddTransactionPage and
/// EditTransactionPage. Pass [initialTransaction] to pre-fill it for
/// editing; leave it null to start from a blank form.
///
/// The caller decides what happens with the resulting [TransactionModel]
/// (add vs update, and navigating back) via [onSubmit].
class TransactionForm extends StatefulWidget {
  final TransactionModel? initialTransaction;
  final ValueChanged<TransactionModel> onSubmit;
  final String submitLabel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final List<String> _categoryOptions;

  String? _category;
  PaymentMethod? _paymentMethod;
  TransactionType? _transactionType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final transaction = widget.initialTransaction;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction != null ? _formatAmount(transaction.amount) : '',
    );
    _notesController = TextEditingController(text: transaction?.notes ?? '');
    _category = transaction?.category;
    _paymentMethod = transaction?.paymentMethod;
    _transactionType = transaction?.transactionType;
    _selectedDate = transaction?.date;
    _categoryOptions = _buildCategoryOptions(transaction?.category);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // The predefined list covers new entries, but an edited transaction may
  // carry an older/custom category (e.g. from the seeded mock data) that
  // isn't in it - add it so the dropdown has a matching item instead of
  // crashing.
  List<String> _buildCategoryOptions(String? currentCategory) {
    if (currentCategory == null ||
        _predefinedCategories.contains(currentCategory)) {
      return _predefinedCategories;
    }
    return [..._predefinedCategories, currentCategory];
  }

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toString();
  }

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;

    setState(() => _selectedDate = picked);
    field.didChange(picked);
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id:
          widget.initialTransaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      category: _category!,
      transactionType: _transactionType!,
      paymentMethod: _paymentMethod!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onSubmit(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateTitle,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransactionType>(
            initialValue: _transactionType,
            decoration: const InputDecoration(
              labelText: 'Transaction Type',
              border: OutlineInputBorder(),
            ),
            items: TransactionType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_transactionTypeLabel(type)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _transactionType = value),
            validator: (value) =>
                value == null ? 'Transaction type is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: _validateAmount,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categoryOptions
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value),
            validator: (value) => value == null ? 'Category is required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: PaymentMethod.values
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(_paymentMethodLabel(method)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _paymentMethod = value),
            validator: (value) =>
                value == null ? 'Payment method is required' : null,
          ),
          const SizedBox(height: 16),
          FormField<DateTime>(
            initialValue: _selectedDate,
            validator: (value) => value == null ? 'Date is required' : null,
            builder: (field) {
              return InkWell(
                onTap: () => _pickDate(field),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = double.tryParse(value);
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than zero';
    return null;
  }

  String _transactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  String _paymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}
