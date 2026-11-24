import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

part 'budget_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId; // empty if overall budget

  @HiveField(4)
  String categoryName;

  @HiveField(5)
  String period; // monthly, weekly, custom

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  List<double> thresholds; // [0.5, 0.75, 0.9, 1.0]

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  BudgetModel({
    String? id,
    required this.name,
    required this.amount,
    this.categoryId = '',
    this.categoryName = '',
    this.period = 'monthly',
    required this.startDate,
    this.endDate,
    List<double>? thresholds,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        thresholds = thresholds ?? AppConstants.budgetThresholds,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get consumedPercentage {
    // This will be calculated by the provider based on actual spending
    return 0.0;
  }

  double get spentAmount => 0.0;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      period: json['period'] as String? ?? 'monthly',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      thresholds: (json['thresholds'] as List<dynamic>?)?.cast<double>() ?? AppConstants.budgetThresholds,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'thresholds': thresholds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
