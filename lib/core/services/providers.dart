import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/core/database/account_repository.dart';
import 'package:pinkledger/core/database/budget_repository.dart';
import 'package:pinkledger/core/database/category_repository.dart';
import 'package:pinkledger/core/database/recurring_repository.dart';
import 'package:pinkledger/core/database/savings_repository.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/security/biometric_service.dart';
import 'package:pinkledger/core/security/settings_service.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

// Settings service provider
final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

// Biometric service provider
final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

// Repository providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) => TransactionRepository());
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => BudgetRepository());
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) => SavingsRepository());
final accountRepositoryProvider = Provider<AccountRepository>((ref) => AccountRepository());
final recurringRepositoryProvider = Provider<RecurringRepository>((ref) => RecurringRepository());

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Authentication state provider
final authStateProvider = StateProvider<bool>((ref) => false);

// PIN state provider
final pinStateProvider = StateProvider<String?>((ref) => null);

// Onboarding completed provider
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

// Guest mode provider
final guestModeProvider = StateProvider<bool>((ref) => false);

// Selected date range provider
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Default currency provider
final defaultCurrencyProvider = StateProvider<String>((ref) => AppConstants.defaultCurrency);

// Transactions provider
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<dynamic>>((ref) {
  return TransactionsNotifier(ref.read(transactionRepositoryProvider));
});

class TransactionsNotifier extends StateNotifier<List<dynamic>> {
  final TransactionRepository _repository;
  TransactionsNotifier(this._repository) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await _repository.getAllTransactions();
    state = transactions;
  }
}

// Balance provider
final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceData>((ref) {
  return BalanceNotifier(ref.read(transactionRepositoryProvider));
});

class BalanceData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  BalanceData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
  });
}

class BalanceNotifier extends StateNotifier<BalanceData> {
  final TransactionRepository _repository;
  BalanceNotifier(this._repository) : super(BalanceData(totalBalance: 0, totalIncome: 0, totalExpenses: 0, netSavings: 0)) {
    loadBalance();
  }

  Future<void> loadBalance() async {
    final income = await _repository.getTotalByType('income');
    final expenses = await _repository.getTotalByType('expense');
    state = BalanceData(
      totalBalance: income - expenses,
      totalIncome: income,
      totalExpenses: expenses,
      netSavings: income - expenses,
    );
  }
}

// Budget provider
final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<dynamic>>((ref) {
  return BudgetsNotifier(ref.read(budgetRepositoryProvider));
});

class BudgetsNotifier extends StateNotifier<List<dynamic>> {
  final BudgetRepository _repository;
  BudgetsNotifier(this._repository) : super([]) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final budgets = await _repository.getAllBudgets();
    state = budgets;
  }
}

// Savings provider
final savingsProvider = StateNotifierProvider<SavingsNotifier, List<dynamic>>((ref) {
  return SavingsNotifier(ref.read(savingsRepositoryProvider));
});

class SavingsNotifier extends StateNotifier<List<dynamic>> {
  final SavingsRepository _repository;
  SavingsNotifier(this._repository) : super([]) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    final goals = await _repository.getAllGoals();
    state = goals;
  }
}

// Account provider
final accountsProvider = StateNotifierProvider<AccountsNotifier, List<dynamic>>((ref) {
  return AccountsNotifier(ref.read(accountRepositoryProvider));
});

class AccountsNotifier extends StateNotifier<List<dynamic>> {
  final AccountRepository _repository;
  AccountsNotifier(this._repository) : super([]) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final accounts = await _repository.getAllAccounts();
    state = accounts;
  }
}

// Recurring provider
final recurringProvider = StateNotifierProvider<RecurringNotifier, List<dynamic>>((ref) {
  return RecurringNotifier(ref.read(recurringRepositoryProvider));
});

class RecurringNotifier extends StateNotifier<List<dynamic>> {
  final RecurringRepository _repository;
  RecurringNotifier(this._repository) : super([]) {
    loadRecurring();
  }

  Future<void> loadRecurring() async {
    final recurring = await _repository.getAllRecurring();
    state = recurring;
  }
}

// Categories provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<dynamic>>((ref) {
  return CategoriesNotifier(ref.read(categoryRepositoryProvider));
});

class CategoriesNotifier extends StateNotifier<List<dynamic>> {
  final CategoryRepository _repository;
  CategoriesNotifier(this._repository) : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await _repository.getAllCategories();
    state = categories;
  }
}