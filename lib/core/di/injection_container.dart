import 'package:get_it/get_it.dart';

import '../services/local_storage_service.dart';

final GetIt locator = GetIt.instance;

/// Registers app-wide dependencies.
///
/// More services, repositories, etc. will be added here as each feature
/// needs them.
Future<void> setupLocator() async {
  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
}
