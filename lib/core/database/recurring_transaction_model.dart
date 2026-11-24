import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'recurring_transaction_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 6)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // expense, income

  @HiveField(3)
  double amount;

  @HiveField(4)
  String category;

  @HiveField(5)
  String paymentMethod;

  @HiveField(6)
  String schedule; // daily, weekly, monthly, yearly, custom

  @HiveField(7)
  int interval; // custom interval value

  @HiveField(8)
  DateTime startDate;

  @HiveField(9)
  DateTime? endDate;

  @HiveField(10)
  DateTime nextPaymentDate;

  @HiveField(11)
  String? description;

  @HiveField(12)
  bool isPaused;

  @HiveField(13)
  bool isActive;

  @HiveField(14)
  List<int> reminderDays; // [1, 3, 7] days before

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  RecurringTransactionModel({
    String? id,
    required this.name,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.schedule,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    required this.nextPaymentDate,
    this.description,
    this.isPaused = false,
    this.isActive = true,
    List<int>? reminderDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        reminderDays = reminderDays ?? [1, 3, 7],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      paymentMethod: json['paymentMethod'] as String,
      schedule: json['schedule'] as String,
      interval: json['interval'] as int? ?? 1,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      nextPaymentDate: DateTime.parse(json['nextPaymentDate'] as String),
      description: json['description'] as String?,
      isPaused: json['isPaused'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      reminderDays: (json['reminderDays'] as List<dynamic>?)?.cast<int>() ?? [1, 3, 7],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'schedule': schedule,
      'interval': interval,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'description': description,
      'isPaused': isPaused,
      'isActive': isActive,
      'reminderDays': reminderDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
