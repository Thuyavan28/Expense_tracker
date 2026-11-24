import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/security/settings_service.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/accounts/accounts_screen.dart';
import 'package:pinkledger/features/analytics/analytics_screen.dart';
import 'package:pinkledger/features/authentication/auth_screens.dart';
import 'package:pinkledger/features/budgets/budgets_screen.dart';
import 'package:pinkledger/features/categories/categories_screen.dart';
import 'package:pinkledger/features/dashboard/main_navigation_screen.dart';
// OnboardingScreen is now in auth_screens.dart
import 'package:pinkledger/features/recurring/recurring_screen.dart';
import 'package:pinkledger/features/savings/savings_screen.dart';
import 'package:pinkledger/features/receipts/receipt_scan_screen.dart';
import 'package:pinkledger/features/settings/settings_screen.dart';
import 'package:pinkledger/features/transactions/transactions_screen.dart';
import 'package:pinkledger/shared/animations/splash_animation.dart';

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    AppConstants.splash: (context) => const AnimatedSplashScreen(),
    AppConstants.onboarding: (context) => const OnboardingScreen(),
    AppConstants.login: (context) => const LoginScreen(),
    AppConstants.register: (context) => const RegisterScreen(),
    AppConstants.forgotPassword: (context) => const ForgotPasswordScreen(),
    AppConstants.pinSetup: (context) => const PINSetupScreen(),
    AppConstants.pinVerify: (context) => const PINVerifyScreen(),
    AppConstants.home: (context) => const MainNavigationScreen(),
    AppConstants.transactions: (context) => const TransactionsScreen(),
    AppConstants.analytics: (context) => const AnalyticsScreen(),
    AppConstants.budgets: (context) => const BudgetsScreen(),
    AppConstants.settings: (context) => const SettingsScreen(),
    AppConstants.savings: (context) => const SavingsScreen(),
    AppConstants.accounts: (context) => const AccountsScreen(),
    AppConstants.recurring: (context) => const RecurringScreen(),
    AppConstants.categories: (context) => const CategoriesScreen(),
    AppConstants.receiptScan: (context) => const ReceiptScanScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    if (settings.name == AppConstants.transactionDetail) {
      return MaterialPageRoute(
        builder: (context) => const Center(child: Text('Transaction Detail')),
        settings: settings,
      );
    }
    if (settings.name == AppConstants.addTransaction) {
      return MaterialPageRoute(
        builder: (context) => const Center(child: Text('Add Transaction')),
        settings: settings,
      );
    }
    if (settings.name == AppConstants.reports) {
      return MaterialPageRoute(
        builder: (context) => const Center(child: Text('Reports')),
        settings: settings,
      );
    }
    if (settings.name == AppConstants.insights) {
      return MaterialPageRoute(
        builder: (context) => const Center(child: Text('Insights')),
        settings: settings,
      );
    }
    return null;
  }

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: AppConstants.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppConstants.splash,
        name: 'splash',
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: AppConstants.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.pinSetup,
        name: 'pin-setup',
        builder: (context, state) => const PINSetupScreen(),
      ),
      GoRoute(
        path: AppConstants.pinVerify,
        name: 'pin-verify',
        builder: (context, state) => const PINVerifyScreen(),
      ),
      GoRoute(
        path: AppConstants.home,
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: AppConstants.transactions,
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: AppConstants.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppConstants.budgets,
        name: 'budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppConstants.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.savings,
        name: 'savings',
        builder: (context, state) => const SavingsScreen(),
      ),
      GoRoute(
        path: AppConstants.accounts,
        name: 'accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: AppConstants.recurring,
        name: 'recurring',
        builder: (context, state) => const RecurringScreen(),
      ),
      GoRoute(
        path: AppConstants.categories,
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppConstants.transactionDetail,
        name: 'transaction-detail',
        builder: (context, state) => const Center(child: Text('Transaction Detail')),
      ),
      GoRoute(
        path: AppConstants.addTransaction,
        name: 'add-transaction',
        builder: (context, state) => const Center(child: Text('Add Transaction')),
      ),
      GoRoute(
        path: AppConstants.reports,
        name: 'reports',
        builder: (context, state) => const Center(child: Text('Reports')),
      ),
      GoRoute(
        path: AppConstants.insights,
        name: 'insights',
        builder: (context, state) => const Center(child: Text('Insights')),
      ),
      GoRoute(
        path: AppConstants.receiptScan,
        name: 'receipt-scan',
        builder: (context, state) => const ReceiptScanScreen(),
      ),
    ],
  );
}
