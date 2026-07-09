import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: const Center(child: Text(AppStrings.profileTitle)),
    );
  }
}
