import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/draft_transaction_service.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/transaction_model.dart';

const List<String> _predefinedTags = [
  'Food',
  'Business',
  'Personal',
  'Travel',
  'Medical',
  'Shopping',
  'Bills',
  'Work',
];

/// Add/Edit transaction form, shared by AddTransactionPage and
/// EditTransactionPage. Pass [initialTransaction] to pre-fill it for
/// editing; leave it null to start from a blank form.
///
/// [initialDraft] pre-fills the same way but, unlike [initialTransaction],
/// does not make the form treat this as an edit (submitting still
/// generates a new id) - used by AddTransactionPage to restore a saved
/// draft. Draft save/discard actions only show when [initialTransaction]
/// is null, i.e. in "add" mode.
///
/// The caller decides what happens with the resulting [TransactionModel]
/// (add vs update, and navigating back) via [onSubmit].
class TransactionForm extends StatefulWidget {
  final TransactionModel? initialTransaction;
  final TransactionModel? initialDraft;
  final ValueChanged<TransactionModel> onSubmit;
  final String submitLabel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    this.initialDraft,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final List<String> _categoryOptions;
  late final bool _isAddMode;

  String? _category;
  PaymentMethod? _paymentMethod;
  TransactionType? _transactionType;
  DateTime? _selectedDate;
  String? _receiptImagePath;
  List<String> _selectedTags = [];
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    _isAddMode = widget.initialTransaction == null;
    final transaction = widget.initialTransaction ?? widget.initialDraft;
    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
      text: transaction != null ? _formatAmount(transaction.amount) : '',
    );
    _notesController = TextEditingController(text: transaction?.notes ?? '');
    _category = transaction?.category;
    _paymentMethod = transaction?.paymentMethod;
    _receiptImagePath = transaction?.receiptImagePath;
    _selectedTags = List<String>.from(transaction?.tags ?? const []);
    _isRecurring = transaction?.isRecurring ?? false;
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
        predefinedCategories.contains(currentCategory)) {
      return predefinedCategories;
    }
    return [...predefinedCategories, currentCategory];
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

    widget.onSubmit(_buildTransaction());

    if (_isAddMode) {
      locator<DraftTransactionService>().clearDraft();
    }
  }

  TransactionModel _buildTransaction() {
    return TransactionModel(
      id:
          widget.initialTransaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      date: _selectedDate ?? DateTime.now(),
      category: _category ?? '',
      transactionType: _transactionType ?? TransactionType.expense,
      paymentMethod: _paymentMethod ?? PaymentMethod.cash,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      receiptImagePath: _receiptImagePath,
      tags: _selectedTags,
      isRecurring: _isRecurring,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _receiptImagePath = picked.path);
  }

  Future<void> _saveDraft() async {
    await locator<DraftTransactionService>().saveDraft(_buildTransaction());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft saved')));
  }

  Future<void> _discardDraft() async {
    await locator<DraftTransactionService>().clearDraft();
    if (!mounted) return;

    setState(() {
      _titleController.clear();
      _amountController.clear();
      _notesController.clear();
      _category = null;
      _paymentMethod = null;
      _transactionType = null;
      _selectedDate = null;
      _receiptImagePath = null;
      _selectedTags = [];
      _isRecurring = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft discarded')));
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
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
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
            validator: validateRequiredAmount,
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
                    child: Text(method.label),
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
          _buildReceiptSection(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Recurring Transaction'),
            subtitle: const Text('Repeat this transaction automatically'),
            value: _isRecurring,
            onChanged: (value) => setState(() => _isRecurring = value),
          ),
          if (_isAddMode) ...[const SizedBox(height: 24), _buildDraftActions()],
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

  Widget _buildReceiptSection() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Receipt', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        if (_receiptImagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_receiptImagePath!),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _receiptImagePath = null),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags (optional)', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDraftActions() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _saveDraft,
            child: const Text('Save Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _discardDraft,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
            child: const Text('Discard Draft'),
          ),
        ),
      ],
    );
  }
}
