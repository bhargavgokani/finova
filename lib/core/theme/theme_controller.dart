import 'package:flutter/material.dart';

/// App-wide observable theme mode. Seeded from SettingsService at
/// startup; ProfileBloc updates it when the user toggles the theme
/// switch, so the root MaterialApp rebuilds immediately.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(super.initialThemeMode);
}
