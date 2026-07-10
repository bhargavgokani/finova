import 'package:get_it/get_it.dart';

import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/budget/data/repositories/budget_repository.dart';
import '../../features/budget/presentation/bloc/budget_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/subscriptions/data/repositories/subscription_repository.dart';
import '../../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../services/draft_transaction_service.dart';
import '../services/local_storage_service.dart';
import '../services/settings_service.dart';
import '../theme/theme_controller.dart';

final GetIt locator = GetIt.instance;

/// Registers app-wide dependencies.
///
/// More services, repositories, etc. will be added here as each feature
/// needs them.
Future<void> setupLocator() async {
  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );

  locator.registerLazySingleton<SettingsService>(() => SettingsService());

  locator.registerLazySingleton<DraftTransactionService>(
    () => DraftTransactionService(),
  );

  // Eagerly created (not lazy) so it can be seeded with the persisted
  // theme mode before the root MaterialApp first builds.
  final initialThemeMode = await locator<SettingsService>().getThemeMode();
  locator.registerSingleton<ThemeController>(ThemeController(initialThemeMode));

  locator.registerLazySingleton<AuthRepository>(() => AuthRepository());

  // Factory: a fresh bloc (and fresh form state) each time a screen asks for one.
  locator.registerFactory<AuthBloc>(
    () => AuthBloc(locator<AuthRepository>(), locator<LocalStorageService>()),
  );

  locator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );

  locator.registerLazySingleton<BudgetRepository>(() => BudgetRepository());

  locator.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepository(),
  );

  // Factory: a fresh bloc each time the dashboard screen is opened.
  locator.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      locator<TransactionRepository>(),
      locator<BudgetRepository>(),
      locator<SubscriptionRepository>(),
    ),
  );

  // Factory: a fresh bloc each time the transactions screen is opened.
  locator.registerFactory<TransactionBloc>(
    () => TransactionBloc(locator<TransactionRepository>()),
  );

  // Factory: a fresh bloc each time the budget screen is opened.
  locator.registerFactory<BudgetBloc>(
    () => BudgetBloc(
      locator<BudgetRepository>(),
      locator<TransactionRepository>(),
    ),
  );

  // Factory: a fresh bloc each time the analytics screen is opened.
  locator.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(locator<TransactionRepository>()),
  );

  // Factory: a fresh bloc each time the subscriptions screen is opened.
  locator.registerFactory<SubscriptionBloc>(
    () => SubscriptionBloc(locator<SubscriptionRepository>()),
  );

  // Factory: a fresh bloc each time the profile screen is opened.
  locator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      locator<SettingsService>(),
      locator<LocalStorageService>(),
      locator<ThemeController>(),
      locator<TransactionRepository>(),
      locator<BudgetRepository>(),
    ),
  );
}
