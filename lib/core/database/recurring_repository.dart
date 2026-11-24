import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/recurring_transaction_model.dart';

class RecurringRepository {
  Future<List<RecurringTransactionModel>> getAllRecurring() {
    return Future.value(AppDatabase.recurringTransactions.values.where((r) => r.isActive).toList()..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate)));
  }

  Future<List<RecurringTransactionModel>> getUpcomingPayments({int days = 30}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return Future.value(
      AppDatabase.recurringTransactions.values
          .where((r) => r.isActive && !r.isPaused && r.nextPaymentDate.isAfter(now) && r.nextPaymentDate.isBefore(future))
          .toList()
        ..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate)),
    );
  }

  Future<RecurringTransactionModel?> getById(String id) {
    return Future.value(AppDatabase.recurringTransactions.get(id));
  }

  Future<void> addRecurring(RecurringTransactionModel recurring) async {
    await AppDatabase.recurringTransactions.put(recurring.id, recurring);
  }

  Future<void> updateRecurring(RecurringTransactionModel recurring) async {
    recurring.updatedAt = DateTime.now();
    await AppDatabase.recurringTransactions.put(recurring.id, recurring);
  }

  Future<void> deleteRecurring(String id) async {
    await AppDatabase.recurringTransactions.delete(id);
  }

  Future<void> togglePause(String id) async {
    final recurring = AppDatabase.recurringTransactions.get(id);
    if (recurring != null) {
      recurring.isPaused = !recurring.isPaused;
      recurring.updatedAt = DateTime.now();
      await AppDatabase.recurringTransactions.put(recurring.id, recurring);
    }
  }
}
