import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool rememberMe;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final bool isSuccess;
  // True once the user has attempted a submit at least once. While false,
  // field-change events only update values; once true, they also
  // re-validate live so errors update as the user types.
  final bool formSubmitted;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  const AuthState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.rememberMe = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.formSubmitted = false,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  // Note: the four error fields are always replaced with whatever is
  // passed in (no fallback to the previous value). Callers that revalidate
  // must pass all of them together, which is exactly what AuthBloc does.
  AuthState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? rememberMe,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? isSubmitting,
    bool? isSuccess,
    bool? formSubmitted,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return AuthState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      formSubmitted: formSubmitted ?? this.formSubmitted,
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    rememberMe,
    obscurePassword,
    obscureConfirmPassword,
    isSubmitting,
    isSuccess,
    formSubmitted,
    nameError,
    emailError,
    passwordError,
    confirmPasswordError,
  ];
}
