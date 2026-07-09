import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.splashTitle)),
      body: const Center(child: Text(AppStrings.splashTitle)),
    );
  }
}
