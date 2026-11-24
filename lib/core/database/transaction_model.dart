import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

part 'transaction_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // expense, income, transfer

  @HiveField(2)
  double amount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? subCategory;

  @HiveField(6)
  String paymentMethod;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  String description;

  @HiveField(9)
  String? merchantName;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  List<String> tags;

  @HiveField(12)
  String? receiptImagePath;

  @HiveField(13)
  String status; // completed, pending, failed, cancelled

  @HiveField(14)
  String? sourceAccountId;

  @HiveField(15)
  String? destinationAccountId;

  @HiveField(16)
  bool isDuplicate;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime updatedAt;

  TransactionModel({
    String? id,
    required this.type,
    required this.amount,
    this.currency = AppConstants.defaultCurrency,
    required this.category,
    this.subCategory,
    required this.paymentMethod,
    required this.date,
    required this.description,
    this.merchantName,
    this.notes,
    List<String>? tags,
    this.receiptImagePath,
    this.status = AppConstants.statusCompleted,
    this.sourceAccountId,
    this.destinationAccountId,
    this.isDuplicate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? AppConstants.defaultCurrency,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      merchantName: json['merchantName'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      receiptImagePath: json['receiptImagePath'] as String?,
      status: json['status'] as String? ?? AppConstants.statusCompleted,
      sourceAccountId: json['sourceAccountId'] as String?,
      destinationAccountId: json['destinationAccountId'] as String?,
      isDuplicate: json['isDuplicate'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'category': category,
      'subCategory': subCategory,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'description': description,
      'merchantName': merchantName,
      'notes': notes,
      'tags': tags,
      'receiptImagePath': receiptImagePath,
      'status': status,
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'isDuplicate': isDuplicate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
