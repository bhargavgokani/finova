import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/theme_controller.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SettingsService _settingsService;
  final LocalStorageService _localStorageService;
  final ThemeController _themeController;

  ProfileBloc(
    this._settingsService,
    this._localStorageService,
    this._themeController,
  ) : super(const ProfileState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeCurrency>(_onChangeCurrency);
    on<ToggleNotifications>(_onToggleNotifications);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<ProfileState> emit,
  ) async {
    final themeMode = await _settingsService.getThemeMode();
    final selectedCurrency = await _settingsService.getCurrency();
    final notificationsEnabled = await _settingsService
        .getNotificationsEnabled();

    emit(
      ProfileState(
        themeMode: themeMode,
        selectedCurrency: selectedCurrency,
        notificationsEnabled: notificationsEnabled,
        isLoading: false,
      ),
    );
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ProfileState> emit,
  ) async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    await _settingsService.setThemeMode(newMode);
    _themeController.value = newMode;

    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onChangeCurrency(
    ChangeCurrency event,
    Emitter<ProfileState> emit,
  ) async {
    await _settingsService.setCurrency(event.currency);
    emit(state.copyWith(selectedCurrency: event.currency));
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<ProfileState> emit,
  ) async {
    final newValue = !state.notificationsEnabled;
    await _settingsService.setNotificationsEnabled(newValue);
    emit(state.copyWith(notificationsEnabled: newValue));
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    await _localStorageService.setLoggedIn(false);
  }
}
