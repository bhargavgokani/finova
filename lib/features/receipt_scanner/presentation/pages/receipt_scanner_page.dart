import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class ReceiptScannerPage extends StatelessWidget {
  const ReceiptScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.receiptScannerTitle)),
      body: const Center(child: Text(AppStrings.receiptScannerTitle)),
    );
  }
}
