import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { inr, usd, eur }

extension AppCurrencyLabel on AppCurrency {
  String get symbol {
    switch (this) {
      case AppCurrency.inr:
        return '₹';
      case AppCurrency.usd:
        return '\$';
      case AppCurrency.eur:
        return '€';
    }
  }

  String get label {
    switch (this) {
      case AppCurrency.inr:
        return 'INR (₹)';
      case AppCurrency.usd:
        return 'USD (\$)';
      case AppCurrency.eur:
        return 'EUR (€)';
    }
  }
}

/// Thin wrapper around SharedPreferences for app settings: theme mode,
/// selected currency, notification preference, profile details, and the
/// biometric login preference.
class SettingsService {
  static const String _themeModeKey = 'themeMode';
  static const String _currencyKey = 'selectedCurrency';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _biometricEnabledKey = 'biometricEnabled';
  static const String _nameKey = 'profileName';
  static const String _emailKey = 'profileEmail';
  static const String _phoneKey = 'profilePhone';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<AppCurrency> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_currencyKey);
    return AppCurrency.values.firstWhere(
      (currency) => currency.name == value,
      orElse: () => AppCurrency.inr,
    );
  }

  Future<void> setCurrency(AppCurrency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.name);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, value);
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  Future<void> setName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, value);
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  Future<void> setEmail(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, value);
  }

  Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey) ?? '';
  }

  Future<void> setPhone(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, value);
  }
}
