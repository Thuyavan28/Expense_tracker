import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/budget_model.dart';

class BudgetRepository {
  Future<List<BudgetModel>> getAllBudgets() {
    return Future.value(AppDatabase.budgets.values.where((b) => b.isActive).toList());
  }

  Future<BudgetModel?> getBudgetById(String id) {
    return Future.value(AppDatabase.budgets.get(id));
  }

  Future<void> addBudget(BudgetModel budget) async {
    await AppDatabase.budgets.put(budget.id, budget);
  }

  Future<void> updateBudget(BudgetModel budget) async {
    budget.updatedAt = DateTime.now();
    await AppDatabase.budgets.put(budget.id, budget);
  }

  Future<void> deleteBudget(String id) async {
    await AppDatabase.budgets.delete(id);
  }

  Future<void> deleteAllBudgets() async {
    await AppDatabase.budgets.clear();
  }
}
