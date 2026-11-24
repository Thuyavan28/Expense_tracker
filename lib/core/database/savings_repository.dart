import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/savings_goal_model.dart';

class SavingsRepository {
  Future<List<SavingsGoalModel>> getAllGoals() {
    return Future.value(AppDatabase.savingsGoals.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<SavingsGoalModel?> getGoalById(String id) {
    return Future.value(AppDatabase.savingsGoals.get(id));
  }

  Future<List<SavingsContributionModel>> getContributions(String goalId) {
    return Future.value(
      AppDatabase.contributions.values.where((c) => c.goalId == goalId).toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    await AppDatabase.savingsGoals.put(goal.id, goal);
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    goal.updatedAt = DateTime.now();
    await AppDatabase.savingsGoals.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await AppDatabase.savingsGoals.delete(id);
    // Delete contributions
    final contributions = AppDatabase.contributions.values.where((c) => c.goalId == id).toList();
    for (final c in contributions) {
      await AppDatabase.contributions.delete(c.id);
    }
  }

  Future<void> addContribution(SavingsContributionModel contribution) async {
    await AppDatabase.contributions.put(contribution.id, contribution);
    // Update goal current amount
    final goal = AppDatabase.savingsGoals.get(contribution.goalId);
    if (goal != null) {
      goal.currentAmount += contribution.amount;
      if (goal.currentAmount >= goal.targetAmount) {
        goal.isCompleted = true;
        goal.completedAt = DateTime.now();
      }
      goal.updatedAt = DateTime.now();
      await AppDatabase.savingsGoals.put(goal.id, goal);
    }
  }
}
