import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'savings_goal_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 3)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  String? description;

  @HiveField(6)
  String color;

  @HiveField(7)
  String icon;

  @HiveField(8)
  bool isPaused;

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  SavingsGoalModel({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.description,
    this.color = '#FF4696',
    this.icon = 'savings',
    this.isPaused = false,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount) * 100;
  }

  double get remainingAmount {
    return targetAmount - currentAmount;
  }

  DateTime? get estimatedCompletionDate {
    // Simple estimate based on current contribution rate
    // This would need contribution history to calculate properly
    return null;
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#FF4696',
      icon: json['icon'] as String? ?? 'savings',
      isPaused: json['isPaused'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'description': description,
      'color': color,
      'icon': icon,
      'isPaused': isPaused,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Contribution history for a savings goal
@HiveType(typeId: 4)
class SavingsContributionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String goalId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? notes;

  SavingsContributionModel({
    String? id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.notes,
  }) : id = id ?? _uuid.v4();

  factory SavingsContributionModel.fromJson(Map<String, dynamic> json) {
    return SavingsContributionModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}
