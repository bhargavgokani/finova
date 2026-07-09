import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.budgetTitle)),
      body: const Center(child: Text(AppStrings.budgetTitle)),
    );
  }
}
