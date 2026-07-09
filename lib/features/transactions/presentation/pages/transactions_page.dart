import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transactionsTitle)),
      body: const Center(child: Text(AppStrings.transactionsTitle)),
    );
  }
}
