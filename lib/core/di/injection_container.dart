import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
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

  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());

  // Factory: a fresh bloc (and fresh form state) each time a screen asks for one.
  locator.registerFactory<AuthBloc>(
    () => AuthBloc(locator<AuthRepository>(), locator<LocalStorageService>()),
  );

  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );
}
