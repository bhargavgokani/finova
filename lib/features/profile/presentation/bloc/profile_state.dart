import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/settings_service.dart';

class ProfileState extends Equatable {
  final ThemeMode themeMode;
  final AppCurrency selectedCurrency;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final String name;
  final String email;
  final String phone;
  final bool isLoading;

  const ProfileState({
    this.themeMode = ThemeMode.light,
    this.selectedCurrency = AppCurrency.inr,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.isLoading = true,
  });

  ProfileState copyWith({
    ThemeMode? themeMode,
    AppCurrency? selectedCurrency,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    String? name,
    String? email,
    String? phone,
    bool? isLoading,
  }) {
    return ProfileState(
      themeMode: themeMode ?? this.themeMode,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    selectedCurrency,
    notificationsEnabled,
    biometricEnabled,
    name,
    email,
    phone,
    isLoading,
  ];
}
