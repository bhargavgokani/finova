import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/validators.dart';
import '../../data/models/subscription_model.dart';

const List<String> _predefinedCategories = [
  'Entertainment',
  'Shopping',
  'Health & Fitness',
  'Utilities',
  'Software',
  'Other',
];

/// Add/Edit subscription form, shared by AddSubscriptionPage and
/// EditSubscriptionPage. Pass [initialSubscription] to pre-fill it for
/// editing; leave it null to start from a blank form.
///
/// The caller decides what happens with the resulting [SubscriptionModel]
/// (add vs update, and navigating back) via [onSubmit].
class SubscriptionForm extends StatefulWidget {
  final SubscriptionModel? initialSubscription;
  final ValueChanged<SubscriptionModel> onSubmit;
  final String submitLabel;

  const SubscriptionForm({
    super.key,
    this.initialSubscription,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final List<String> _categoryOptions;

  BillingCycle? _billingCycle;
  DateTime? _nextRenewalDate;
  String? _category;

  @override
  void initState() {
    super.initState();
    final subscription = widget.initialSubscription;
    _nameController = TextEditingController(text: subscription?.name ?? '');
    _amountController = TextEditingController(
      text: subscription != null ? _formatAmount(subscription.amount) : '',
    );
    _billingCycle = subscription?.billingCycle;
    _nextRenewalDate = subscription?.nextRenewalDate;
    _category = subscription?.category;
    _categoryOptions = _buildCategoryOptions(subscription?.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // The predefined list covers new entries, but an edited subscription may
  // carry an older/custom category that isn't in it - add it so the
  // dropdown has a matching item instead of crashing.
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

  Future<void> _pickRenewalDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewalDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;

    setState(() => _nextRenewalDate = picked);
    field.didChange(picked);
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final subscription = SubscriptionModel(
      id:
          widget.initialSubscription?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      billingCycle: _billingCycle!,
      nextRenewalDate: _nextRenewalDate!,
      category: _category!,
    );

    widget.onSubmit(subscription);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.subscriptions_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _validateName,
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
          DropdownButtonFormField<BillingCycle>(
            initialValue: _billingCycle,
            decoration: const InputDecoration(
              labelText: 'Billing Cycle',
              border: OutlineInputBorder(),
            ),
            items: BillingCycle.values
                .map(
                  (cycle) =>
                      DropdownMenuItem(value: cycle, child: Text(cycle.label)),
                )
                .toList(),
            onChanged: (value) => setState(() => _billingCycle = value),
            validator: (value) =>
                value == null ? 'Billing cycle is required' : null,
          ),
          const SizedBox(height: 16),
          FormField<DateTime>(
            initialValue: _nextRenewalDate,
            validator: (value) =>
                value == null ? 'Next renewal date is required' : null,
            builder: (field) {
              return InkWell(
                onTap: () => _pickRenewalDate(field),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Next Renewal Date',
                    prefixIcon: const Icon(Icons.event_outlined),
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    _nextRenewalDate == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(_nextRenewalDate!),
                  ),
                ),
              );
            },
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }
}
