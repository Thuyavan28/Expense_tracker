/// PINKLEDGER App Constants
class AppConstants {
  static const String appName = 'PINKLEDGER';
  static const String tagline = 'Every Rupee, Under Control.';
  static const String version = '1.0.0';

  // Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String pinSetup = '/pin-setup';
  static const String pinVerify = '/pin-verify';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';
  static const String transactionDetail = '/transaction-detail';
  static const String addTransaction = '/add-transaction';
  static const String savings = '/savings';
  static const String accounts = '/accounts';
  static const String recurring = '/recurring';
  static const String categories = '/categories';
  static const String reports = '/reports';
  static const String insights = '/insights';
  static const String receiptScan = '/receipt-scan';

  // Storage keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyIsAuthenticated = 'is_authenticated';
  static const String keyHasPIN = 'has_pin';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'default_currency';
  static const String keyPIN = 'app_pin';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyAutoLockTimeout = 'auto_lock_timeout';
  static const String keyFirstDayOfMonth = 'first_day_of_month';
  static const String keyGuestMode = 'guest_mode';
  static const String keyDefaultAccount = 'default_account';

  // Default currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';

  // Budget thresholds
  static const List<double> budgetThresholds = [0.5, 0.75, 0.9, 1.0];

  // Reminder days
  static const List<int> reminderDays = [1, 3, 7];

  // Date formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatInput = 'yyyy-MM-dd';
  static const String monthFormat = 'MMM yyyy';

  // Transaction statuses
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';

  // Transaction types
  static const String typeExpense = 'expense';
  static const String typeIncome = 'income';
  static const String typeTransfer = 'transfer';

  // Recurrence schedules
  static const String recurrenceDaily = 'daily';
  static const String recurrenceWeekly = 'weekly';
  static const String recurrenceMonthly = 'monthly';
  static const String recurrenceYearly = 'yearly';
  static const String recurrenceCustom = 'custom';

  // Navigation tabs
  static const List<String> navTabs = ['Home', 'Transactions', 'Analytics', 'Budgets', 'Profile'];
}
