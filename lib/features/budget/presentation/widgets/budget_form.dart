import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../data/models/budget_model.dart';

const List<String> _predefinedCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Entertainment',
  'Healthcare',
  'Other',
];

/// Add/Edit budget form, shared by AddBudgetPage and EditBudgetPage.
/// Pass [initialBudget] to pre-fill it for editing; leave it null to
/// start from a blank form.
///
/// The caller decides what happens with the resulting [BudgetModel]
/// (add vs update, and navigating back) via [onSubmit].
class BudgetForm extends StatefulWidget {
  final BudgetModel? initialBudget;
  final ValueChanged<BudgetModel> onSubmit;
  final String submitLabel;

  const BudgetForm({
    super.key,
    this.initialBudget,
    required this.onSubmit,
    this.submitLabel = 'Save',
  });

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final List<String> _categoryOptions;

  String? _category;
  BudgetPeriod? _period;

  @override
  void initState() {
    super.initState();
    final budget = widget.initialBudget;
    _amountController = TextEditingController(
      text: budget != null ? _formatAmount(budget.amount) : '',
    );
    _category = budget?.category;
    _period = budget?.period;
    _categoryOptions = _buildCategoryOptions(budget?.category);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // The predefined list covers new entries, but an edited budget may carry
  // an older/custom category that isn't in it - add it so the dropdown has
  // a matching item instead of crashing.
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final budget = BudgetModel(
      id:
          widget.initialBudget?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      category: _category!,
      amount: double.parse(_amountController.text),
      period: _period!,
    );

    widget.onSubmit(budget);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          DropdownButtonFormField<BudgetPeriod>(
            initialValue: _period,
            decoration: const InputDecoration(
              labelText: 'Period',
              border: OutlineInputBorder(),
            ),
            items: BudgetPeriod.values
                .map(
                  (period) => DropdownMenuItem(
                    value: period,
                    child: Text(period.label),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _period = value),
            validator: (value) => value == null ? 'Period is required' : null,
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
}
