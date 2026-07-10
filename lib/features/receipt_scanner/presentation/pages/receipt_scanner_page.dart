import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';

/// A mock parsed receipt result - there is no real OCR here, just a small
/// pool of plausible values used to simulate one.
class _MockOcrResult {
  final String merchant;
  final double amount;
  final String category;

  const _MockOcrResult({
    required this.merchant,
    required this.amount,
    required this.category,
  });
}

const List<_MockOcrResult> _mockOcrResults = [
  _MockOcrResult(merchant: 'Starbucks Coffee', amount: 245, category: 'Food'),
  _MockOcrResult(
    merchant: 'Walmart Supercenter',
    amount: 1850,
    category: 'Shopping',
  ),
  _MockOcrResult(
    merchant: 'Shell Gas Station',
    amount: 2200,
    category: 'Transport',
  ),
  _MockOcrResult(
    merchant: 'Apollo Pharmacy',
    amount: 560,
    category: 'Healthcare',
  ),
];

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage> {
  final _imagePicker = ImagePicker();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();

  String? _imagePath;
  bool _isScanning = false;
  bool _hasScanResult = false;
  DateTime? _receiptDate;
  String? _category;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _imagePath = picked.path;
      _hasScanResult = false;
    });
  }

  // Simulated OCR: waits briefly (as if scanning), then fills the result
  // fields from a mock parsed receipt. Nothing here reads the actual image.
  Future<void> _simulateOcrScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final mock =
        _mockOcrResults[DateTime.now().millisecond % _mockOcrResults.length];

    setState(() {
      _isScanning = false;
      _hasScanResult = true;
      _merchantController.text = mock.merchant;
      _amountController.text = mock.amount.toStringAsFixed(0);
      _category = mock.category;
      _receiptDate = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiptDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _receiptDate = picked);
  }

  void _resetImage() {
    setState(() {
      _imagePath = null;
      _hasScanResult = false;
    });
  }

  void _createTransaction() {
    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _merchantController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      date: _receiptDate ?? DateTime.now(),
      category: _category ?? 'Other',
      transactionType: TransactionType.expense,
      paymentMethod: PaymentMethod.card,
      notes: 'Scanned receipt - ${_merchantController.text.trim()}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              locator<TransactionBloc>()..add(const LoadTransactions()),
          child: AddTransactionPage(prefill: transaction),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.receiptScannerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_imagePath == null)
            _PickImageButtons(onPick: _pickImage)
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            if (!_hasScanResult)
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _simulateOcrScan,
                icon: _isScanning
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.document_scanner_outlined),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else ...[
              _OcrResultSection(
                merchantController: _merchantController,
                amountController: _amountController,
                category: _category,
                receiptDate: _receiptDate,
                onPickDate: _pickDate,
                onCategoryChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create Transaction'),
              ),
            ],
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resetImage,
                child: const Text('Choose a different image'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickImageButtons extends StatelessWidget {
  final ValueChanged<ImageSource> onPick;

  const _PickImageButtons({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onPick(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Camera'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onPick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
          ),
        ),
      ],
    );
  }
}

class _OcrResultSection extends StatelessWidget {
  final TextEditingController merchantController;
  final TextEditingController amountController;
  final String? category;
  final DateTime? receiptDate;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onCategoryChanged;

  const _OcrResultSection({
    required this.merchantController,
    required this.amountController,
    required this.category,
    required this.receiptDate,
    required this.onPickDate,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Sample OCR Result',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Simulated - edit any field before creating the transaction.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: merchantController,
            decoration: const InputDecoration(
              labelText: 'Merchant',
              prefixIcon: Icon(Icons.storefront_outlined),
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(),
                filled: true,
              ),
              child: Text(
                receiptDate == null
                    ? 'Select date'
                    : DateFormat('dd MMM yyyy').format(receiptDate!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              filled: true,
            ),
            items: predefinedCategories
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }
}
