import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/section_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppStrings.appName,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AppStrings.appVersion,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Developer',
            child: Text(AppStrings.developerName),
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Description',
            child: Text(AppStrings.aboutDescription),
          ),
        ],
      ),
    );
  }
}
