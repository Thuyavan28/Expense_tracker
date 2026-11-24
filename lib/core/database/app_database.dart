import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinkledger/core/database/account_model.dart';
import 'package:pinkledger/core/database/budget_model.dart';
import 'package:pinkledger/core/database/category_model.dart';
import 'package:pinkledger/core/database/recurring_transaction_model.dart';
import 'package:pinkledger/core/database/savings_goal_model.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:flutter/foundation.dart';

class AppDatabase {
  static bool _isInitialized = false;
  static Box<TransactionModel>? _transactionBox;
  static Box<CategoryModel>? _categoryBox;
  static Box<BudgetModel>? _budgetBox;
  static Box<SavingsGoalModel>? _savingsGoalBox;
  static Box<SavingsContributionModel>? _contributionBox;
  static Box<AccountModel>? _accountBox;
  static Box<RecurringTransactionModel>? _recurringBox;

  static Box<TransactionModel> get transactions => _transactionBox!;
  static Box<CategoryModel> get categories => _categoryBox!;
  static Box<BudgetModel> get budgets => _budgetBox!;
  static Box<SavingsGoalModel> get savingsGoals => _savingsGoalBox!;
  static Box<SavingsContributionModel> get contributions => _contributionBox!;
  static Box<AccountModel> get accounts => _accountBox!;
  static Box<RecurringTransactionModel> get recurringTransactions => _recurringBox!;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
      } else {
        await Hive.initFlutter();
      }

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionModelAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CategoryModelAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BudgetModelAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SavingsGoalModelAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SavingsContributionModelAdapter());
      if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AccountModelAdapter());
      if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(RecurringTransactionModelAdapter());

      // Open boxes
      _transactionBox = await Hive.openBox<TransactionModel>('transactions');
      _categoryBox = await Hive.openBox<CategoryModel>('categories');
      _budgetBox = await Hive.openBox<BudgetModel>('budgets');
      _savingsGoalBox = await Hive.openBox<SavingsGoalModel>('savings_goals');
      _contributionBox = await Hive.openBox<SavingsContributionModel>('contributions');
      _accountBox = await Hive.openBox<AccountModel>('accounts');
      _recurringBox = await Hive.openBox<RecurringTransactionModel>('recurring_transactions');

      _isInitialized = true;
      await _seedDefaultData();
    } catch (e, stack) {
      debugPrint('AppDatabase.init error: $e\n$stack');
      _isInitialized = false;
    }
  }

  static Future<void> _seedDefaultData() async {
    if (!_isInitialized) return;
    // Seed categories if empty
    if (categories.isEmpty) {
      final allCategories = [...defaultExpenseCategories, ...defaultIncomeCategories];
      for (final cat in allCategories) {
        await categories.add(cat);
      }
    }

    // Seed accounts if empty
    if (accounts.isEmpty) {
      for (final acc in defaultAccounts) {
        await accounts.add(acc);
      }
    }
  }

  static Future<void> close() async {
    await _transactionBox?.close();
    await _categoryBox?.close();
    await _budgetBox?.close();
    await _savingsGoalBox?.close();
    await _contributionBox?.close();
    await _accountBox?.close();
    await _recurringBox?.close();
  }
}
