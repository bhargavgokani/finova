import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analyticsTitle)),
      body: const Center(child: Text(AppStrings.analyticsTitle)),
    );
  }
}
