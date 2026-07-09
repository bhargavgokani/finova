import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LocalStorageService _localStorageService;

  AuthBloc(this._authRepository, this._localStorageService)
    : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthNameChanged>(
      (event, emit) =>
          emit(_withLiveValidation(state.copyWith(name: event.name))),
    );
    on<AuthEmailChanged>(
      (event, emit) =>
          emit(_withLiveValidation(state.copyWith(email: event.email))),
    );
    on<AuthPasswordChanged>(
      (event, emit) =>
          emit(_withLiveValidation(state.copyWith(password: event.password))),
    );
    on<AuthConfirmPasswordChanged>(
      (event, emit) => emit(
        _withLiveValidation(
          state.copyWith(confirmPassword: event.confirmPassword),
        ),
      ),
    );
    on<AuthRememberMeChanged>(
      (event, emit) => emit(state.copyWith(rememberMe: event.rememberMe)),
    );
    on<AuthPasswordVisibilityToggled>(
      (event, emit) =>
          emit(state.copyWith(obscurePassword: !state.obscurePassword)),
    );
    on<AuthConfirmPasswordVisibilityToggled>(
      (event, emit) => emit(
        state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
      ),
    );
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final rememberMe = await _localStorageService.getRememberMe();
    emit(state.copyWith(rememberMe: rememberMe));
  }

  // Once the user has attempted a submit, keep re-validating on every
  // keystroke so errors clear/appear live instead of only on submit.
  AuthState _withLiveValidation(AuthState updated) {
    if (!updated.formSubmitted) return updated;
    return updated.copyWith(
      nameError: _validateName(updated.name),
      emailError: _validateEmail(updated.email),
      passwordError: _validatePassword(updated.password),
      confirmPasswordError: _validateConfirmPassword(
        updated.password,
        updated.confirmPassword,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          formSubmitted: true,
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        formSubmitted: true,
        isSubmitting: true,
        emailError: null,
        passwordError: null,
      ),
    );

    await _authRepository.login(email: state.email, password: state.password);
    await _localStorageService.setLoggedIn(true);
    await _localStorageService.setRememberMe(state.rememberMe);

    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final nameError = _validateName(state.name);
    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError = _validateConfirmPassword(
      state.password,
      state.confirmPassword,
    );

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      emit(
        state.copyWith(
          formSubmitted: true,
          nameError: nameError,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        formSubmitted: true,
        isSubmitting: true,
        nameError: null,
        emailError: null,
        passwordError: null,
        confirmPasswordError: null,
      ),
    );

    await _authRepository.register(
      name: state.name,
      email: state.email,
      password: state.password,
    );

    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (confirmPassword != password) return 'Passwords do not match';
    return null;
  }
}
