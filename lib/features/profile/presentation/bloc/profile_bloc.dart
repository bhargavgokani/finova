import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../budget/data/models/budget_model.dart';
import '../../../budget/data/repositories/budget_repository.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SettingsService _settingsService;
  final LocalStorageService _localStorageService;
  final ThemeController _themeController;
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  ProfileBloc(
    this._settingsService,
    this._localStorageService,
    this._themeController,
    this._transactionRepository,
    this._budgetRepository,
  ) : super(const ProfileState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ChangeCurrency>(_onChangeCurrency);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleBiometric>(_onToggleBiometric);
    on<UpdateProfile>(_onUpdateProfile);
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
    final biometricEnabled = await _settingsService.getBiometricEnabled();
    final name = await _settingsService.getName();
    final email = await _settingsService.getEmail();
    final phone = await _settingsService.getPhone();

    emit(
      ProfileState(
        themeMode: themeMode,
        selectedCurrency: selectedCurrency,
        notificationsEnabled: notificationsEnabled,
        biometricEnabled: biometricEnabled,
        name: name,
        email: email,
        phone: phone,
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

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<ProfileState> emit,
  ) async {
    final newValue = !state.biometricEnabled;
    await _settingsService.setBiometricEnabled(newValue);
    emit(state.copyWith(biometricEnabled: newValue));
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    await _settingsService.setName(event.name);
    await _settingsService.setEmail(event.email);
    await _settingsService.setPhone(event.phone);

    emit(
      state.copyWith(name: event.name, email: event.email, phone: event.phone),
    );
  }

  Future<void> _onLogout(Logout event, Emitter<ProfileState> emit) async {
    await _localStorageService.setLoggedIn(false);
  }

  /// Builds a pretty-printed JSON string of all transactions, budgets and
  /// settings, for the Export Data screen. Not persisted or uploaded
  /// anywhere - just generated on demand for display.
  String buildExportData() {
    final data = {
      'transactions': _transactionRepository
          .getTransactions()
          .map(_transactionToJson)
          .toList(),
      'budgets': _budgetRepository.getBudgets().map(_budgetToJson).toList(),
      'settings': {
        'themeMode': state.themeMode.name,
        'currency': state.selectedCurrency.name,
        'notificationsEnabled': state.notificationsEnabled,
        'biometricEnabled': state.biometricEnabled,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Map<String, dynamic> _transactionToJson(TransactionModel transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'category': transaction.category,
      'transactionType': transaction.transactionType.name,
      'paymentMethod': transaction.paymentMethod.name,
      'notes': transaction.notes,
      'tags': transaction.tags,
      'isRecurring': transaction.isRecurring,
    };
  }

  Map<String, dynamic> _budgetToJson(BudgetModel budget) {
    return {
      'id': budget.id,
      'category': budget.category,
      'amount': budget.amount,
      'period': budget.period.name,
      'carryForward': budget.carryForward,
    };
  }
}
