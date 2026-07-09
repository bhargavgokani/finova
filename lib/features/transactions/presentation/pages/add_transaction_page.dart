import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

const List<String> _categories = [
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

/// Adds a transaction using the TransactionBloc shared with TransactionsPage,
/// so the list refreshes automatically once this screen is popped.
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _category;
  PaymentMethod? _paymentMethod;
  TransactionType? _transactionType;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _category!,
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      category: _category!,
      transactionType: _transactionType!,
      paymentMethod: _paymentMethod!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    context.read<TransactionBloc>().add(AddTransaction(transaction));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Category is required' : null,
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
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
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
