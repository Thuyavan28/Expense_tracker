import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getAllTransactions() {
    return Future.value(AppDatabase.transactions.values.toList()..sort((a, b) => b.date.compareTo(a.date)));
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) {
    return Future.value(
      AppDatabase.transactions.values.where((t) => t.type == type).toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) {
    return Future.value(
      AppDatabase.transactions.values
          .where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && t.date.isBefore(end.add(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<List<TransactionModel>> getTransactionsByCategory(String category) {
    return Future.value(
      AppDatabase.transactions.values.where((t) => t.category == category).toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<List<TransactionModel>> getTransactionsByMonth(int year, int month) {
    return Future.value(
      AppDatabase.transactions.values
          .where((t) => t.date.year == year && t.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<TransactionModel?> getTransactionById(String id) {
    return Future.value(AppDatabase.transactions.get(id));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await AppDatabase.transactions.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    transaction.updatedAt = DateTime.now();
    await AppDatabase.transactions.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await AppDatabase.transactions.delete(id);
  }

  Future<void> deleteAllTransactions() async {
    await AppDatabase.transactions.clear();
  }

  Future<double> getTotalByType(String type, {DateTime? start, DateTime? end}) {
    var query = AppDatabase.transactions.values.where((t) => t.type == type && t.status == AppConstants.statusCompleted);
    if (start != null) query = query.where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))));
    if (end != null) query = query.where((t) => t.date.isBefore(end.add(const Duration(days: 1))));
    return Future.value(query.fold<double>(0, (sum, t) => sum + t.amount));
  }

  Future<double> getNetSavings({DateTime? start, DateTime? end}) async {
    final income = await getTotalByType(AppConstants.typeIncome, start: start, end: end);
    final expenses = await getTotalByType(AppConstants.typeExpense, start: start, end: end);
    return income - expenses;
  }

  Future<List<TransactionModel>> searchTransactions(String query) {
    final q = query.toLowerCase();
    return Future.value(
      AppDatabase.transactions.values
          .where((t) => t.description.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              (t.merchantName ?? '').toLowerCase().contains(q))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<bool> checkDuplicate(double amount, String category, DateTime date, {int minutes = 5}) {
    final windowStart = date.subtract(Duration(minutes: minutes));
    final windowEnd = date.add(Duration(minutes: minutes));
    final exists = AppDatabase.transactions.values.any((t) =>
        t.type == AppConstants.typeExpense &&
        t.amount == amount &&
        t.category == category &&
        t.date.isAfter(windowStart) &&
        t.date.isBefore(windowEnd) &&
        t.status == AppConstants.statusCompleted);
    return Future.value(exists);
  }
}
