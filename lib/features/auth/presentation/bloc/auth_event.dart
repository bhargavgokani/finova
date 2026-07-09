import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when a screen first opens, so the bloc can restore
/// previously persisted preferences (e.g. Remember Me).
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthNameChanged extends AuthEvent {
  final String name;

  const AuthNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class AuthEmailChanged extends AuthEvent {
  final String email;

  const AuthEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthPasswordChanged extends AuthEvent {
  final String password;

  const AuthPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthConfirmPasswordChanged extends AuthEvent {
  final String confirmPassword;

  const AuthConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class AuthRememberMeChanged extends AuthEvent {
  final bool rememberMe;

  const AuthRememberMeChanged(this.rememberMe);

  @override
  List<Object?> get props => [rememberMe];
}

class AuthPasswordVisibilityToggled extends AuthEvent {
  const AuthPasswordVisibilityToggled();
}

class AuthConfirmPasswordVisibilityToggled extends AuthEvent {
  const AuthConfirmPasswordVisibilityToggled();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted();
}

class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted();
}
