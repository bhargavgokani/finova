import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../bloc/transaction_state.dart';

/// Bottom sheet for filtering and sorting the transactions list. Manages
/// its own draft selection and only reports back via [onApplyFilters] /
/// [onChangeSortOption] when "Apply" is pressed.
class TransactionFilterSheet extends StatefulWidget {
  final TransactionFilters filters;
  final TransactionSortOption sortOption;
  final List<String> availableCategories;
  final ValueChanged<TransactionFilters> onApplyFilters;
  final ValueChanged<TransactionSortOption> onChangeSortOption;

  const TransactionFilterSheet({
    super.key,
    required this.filters,
    required this.sortOption,
    required this.availableCategories,
    required this.onApplyFilters,
    required this.onChangeSortOption,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late String? _category;
  late TransactionType? _transactionType;
  late PaymentMethod? _paymentMethod;
  late DateTimeRange? _dateRange;
  late TransactionSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _category = widget.filters.category;
    _transactionType = widget.filters.transactionType;
    _paymentMethod = widget.filters.paymentMethod;
    _dateRange = widget.filters.dateRange;
    _sortOption = widget.sortOption;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _clearAll() {
    setState(() {
      _category = null;
      _transactionType = null;
      _paymentMethod = null;
      _dateRange = null;
    });
  }

  void _apply() {
    widget.onApplyFilters(
      TransactionFilters(
        category: _category,
        transactionType: _transactionType,
        paymentMethod: _paymentMethod,
        dateRange: _dateRange,
      ),
    );
    if (_sortOption != widget.sortOption) {
      widget.onChangeSortOption(_sortOption);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Filters & Sorting',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(child: Text('All Categories')),
                ...widget.availableCategories.map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                ),
              ],
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionType>(
              initialValue: _transactionType,
              decoration: const InputDecoration(
                labelText: 'Transaction Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<TransactionType>(
                  child: Text('All Types'),
                ),
                ...TransactionType.values.map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                ),
              ],
              onChanged: (value) => setState(() => _transactionType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<PaymentMethod>(
                  child: Text('All Methods'),
                ),
                ...PaymentMethod.values.map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Range',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dateRange == null
                      ? 'All Dates'
                      : '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - '
                            '${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionSortOption>(
              initialValue: _sortOption,
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
              ),
              items: TransactionSortOption.values
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _sortOption = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
