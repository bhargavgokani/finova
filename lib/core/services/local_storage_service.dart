import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for simple key-value storage.
///
/// Temporary stand-in for auth persistence until a full auth feature
/// (with its own repository) is implemented.
class LocalStorageService {
  static const String _isLoggedInKey = 'isLoggedIn';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }
}
