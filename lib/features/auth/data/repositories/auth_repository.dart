/// Simulates an authentication backend.
///
/// There is no real API yet - both methods just wait out a fixed delay
/// and always succeed. Swap the internals for real network calls later
/// without touching any of the calling code.
class AuthRepository {
  Future<void> login({required String email, required String password}) {
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return Future.delayed(const Duration(seconds: 1));
  }
}
