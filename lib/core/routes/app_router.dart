import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import 'app_routes.dart';

/// App-wide go_router configuration.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetPage(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (context, state) => const SubscriptionsPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.receiptScanner,
        builder: (context, state) => const ReceiptScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
  );
}
