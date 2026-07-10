String? validateRequiredAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Amount is required';
  final amount = double.tryParse(value);
  if (amount == null) return 'Enter a valid amount';
  if (amount <= 0) return 'Amount must be greater than zero';
  return null;
}

String? validateRequiredName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required';
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone number is required';
  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length < 10) return 'Enter a valid phone number';
  return null;
}
