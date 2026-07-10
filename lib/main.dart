import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const FinovaApp());
}

class FinovaApp extends StatelessWidget {
  const FinovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: locator<ThemeController>(),
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
