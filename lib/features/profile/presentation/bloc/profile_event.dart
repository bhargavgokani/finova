import 'package:equatable/equatable.dart';

import '../../../../core/services/settings_service.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends ProfileEvent {
  const LoadSettings();
}

class ToggleTheme extends ProfileEvent {
  const ToggleTheme();
}

class ChangeCurrency extends ProfileEvent {
  final AppCurrency currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ToggleNotifications extends ProfileEvent {
  const ToggleNotifications();
}

class ToggleBiometric extends ProfileEvent {
  const ToggleBiometric();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;
  final String phone;

  const UpdateProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

class Logout extends ProfileEvent {
  const Logout();
}
