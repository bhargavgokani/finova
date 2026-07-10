import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.privacyPolicyContent, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
