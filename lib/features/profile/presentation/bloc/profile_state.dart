import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/settings_service.dart';

class ProfileState extends Equatable {
  final ThemeMode themeMode;
  final AppCurrency selectedCurrency;
  final bool notificationsEnabled;
  final bool isLoading;

  const ProfileState({
    this.themeMode = ThemeMode.light,
    this.selectedCurrency = AppCurrency.inr,
    this.notificationsEnabled = true,
    this.isLoading = true,
  });

  ProfileState copyWith({
    ThemeMode? themeMode,
    AppCurrency? selectedCurrency,
    bool? notificationsEnabled,
    bool? isLoading,
  }) {
    return ProfileState(
      themeMode: themeMode ?? this.themeMode,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    selectedCurrency,
    notificationsEnabled,
    isLoading,
  ];
}
