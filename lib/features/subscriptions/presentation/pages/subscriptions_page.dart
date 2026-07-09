import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subscriptionsTitle)),
      body: const Center(child: Text(AppStrings.subscriptionsTitle)),
    );
  }
}
