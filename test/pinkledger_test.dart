import 'package:flutter_test/flutter_test.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/database/category_model.dart';
import 'package:pinkledger/core/database/budget_model.dart';
import 'package:pinkledger/core/database/account_model.dart';
import 'package:pinkledger/core/database/savings_goal_model.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

void main() {
  group('TransactionModel Tests', () {
    test('should create transaction with correct values', () {
      final transaction = TransactionModel(
        type: AppConstants.typeExpense,
        amount: 1500.0,
        category: 'Food and Dining',
        paymentMethod: 'Cash',
        date: DateTime(2026, 11, 24),
        description: 'Lunch',
      );

      expect(transaction.type, AppConstants.typeExpense);
      expect(transaction.amount, 1500.0);
      expect(transaction.category, 'Food and Dining');
      expect(transaction.status, AppConstants.statusCompleted);
      expect(transaction.id, isNotEmpty);
    });

    test('should serialize and deserialize correctly', () {
      final original = TransactionModel(
        type: AppConstants.typeIncome,
        amount: 50000.0,
        category: 'Salary',
        paymentMethod: 'Bank Transfer',
        date: DateTime(2026, 11, 1),
        description: 'Monthly Salary',
        notes: 'November salary',
      );

      final json = original.toJson();
      final deserialized = TransactionModel.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.amount, original.amount);
      expect(deserialized.type, original.type);
      expect(deserialized.notes, original.notes);
    });
  });

  group('CategoryModel Tests', () {
    test('should create expense categories', () {
      final categories = defaultExpenseCategories;
      expect(categories.length, 14);
      expect(categories.any((c) => c.name == 'Food and Dining'), isTrue);
      expect(categories.any((c) => c.type == AppConstants.typeExpense), isTrue);
    });

    test('should create income categories', () {
      final categories = defaultIncomeCategories;
      expect(categories.length, 6);
      expect(categories.any((c) => c.name == 'Salary'), isTrue);
      expect(categories.any((c) => c.type == AppConstants.typeIncome), isTrue);
    });
  });

  group('BudgetModel Tests', () {
    test('should create budget with correct defaults', () {
      final budget = BudgetModel(
        name: 'Monthly Budget',
        amount: 25000.0,
        startDate: DateTime(2026, 11, 1),
      );

      expect(budget.name, 'Monthly Budget');
      expect(budget.amount, 25000.0);
      expect(budget.period, 'monthly');
      expect(budget.isActive, isTrue);
      expect(budget.thresholds, AppConstants.budgetThresholds);
    });
  });

  group('AccountModel Tests', () {
    test('should create default accounts', () {
      final accounts = defaultAccounts;
      expect(accounts.length, 3);
      expect(accounts.any((a) => a.name == 'Cash'), isTrue);
      expect(accounts.any((a) => a.isDefault), isTrue);
      expect(accounts.any((a) => a.type == 'cash'), isTrue);
    });

    test('should serialize and deserialize account', () {
      final original = AccountModel(
        name: 'Savings Account',
        type: 'savings',
        balance: 45000.0,
        openingBalance: 40000.0,
        currency: 'INR',
      );

      final json = original.toJson();
      final deserialized = AccountModel.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.balance, original.balance);
      expect(deserialized.currency, original.currency);
    });
  });

  group('SavingsGoalModel Tests', () {
    test('should calculate progress percentage correctly', () {
      final goal = SavingsGoalModel(
        name: 'Emergency Fund',
        targetAmount: 100000.0,
        currentAmount: 45000.0,
        targetDate: DateTime(2026, 12, 31),
      );

      expect(goal.progressPercentage, 45.0);
      expect(goal.remainingAmount, 55000.0);
      expect(goal.isCompleted, isFalse);
    });

    test('should mark goal as completed when target reached', () {
      final goal = SavingsGoalModel(
        name: 'Laptop Fund',
        targetAmount: 60000.0,
        currentAmount: 60000.0,
        targetDate: DateTime(2026, 12, 31),
      );

      expect(goal.progressPercentage, 100.0);
      expect(goal.remainingAmount, 0.0);
    });
  });

  group('AppConstants Tests', () {
    test('should have correct brand colors defined', () {
      expect(AppConstants.appName, 'PINKLEDGER');
      expect(AppConstants.tagline, 'Every Rupee, Under Control.');
      expect(AppConstants.defaultCurrency, 'INR');
      expect(AppConstants.currencySymbol, '₹');
    });

    test('should have correct budget thresholds', () {
      expect(AppConstants.budgetThresholds, [0.5, 0.75, 0.9, 1.0]);
    });

    test('should have correct reminder days', () {
      expect(AppConstants.reminderDays, [1, 3, 7]);
    });
  });
}
