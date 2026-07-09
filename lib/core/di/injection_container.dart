import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
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

  // Factory: a fresh bloc each time the dashboard screen is opened.
  locator.registerFactory<DashboardBloc>(
    () => DashboardBloc(locator<TransactionRepository>()),
  );

  // Factory: a fresh bloc each time the transactions screen is opened.
  locator.registerFactory<TransactionBloc>(
    () => TransactionBloc(locator<TransactionRepository>()),
  );
}
