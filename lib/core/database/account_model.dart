import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

part 'account_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 5)
class AccountModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // cash, savings, current, wallet, credit_card

  @HiveField(3)
  double balance;

  @HiveField(4)
  double openingBalance;

  @HiveField(5)
  String currency;

  @HiveField(6)
  bool isDefault;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  String? color;

  @HiveField(9)
  String? icon;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  AccountModel({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    required this.openingBalance,
    this.currency = AppConstants.defaultCurrency,
    this.isDefault = false,
    this.isActive = true,
    this.color,
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num? ?? 0).toDouble(),
      openingBalance: (json['openingBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? AppConstants.defaultCurrency,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'openingBalance': openingBalance,
      'currency': currency,
      'isDefault': isDefault,
      'isActive': isActive,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Default accounts
List<AccountModel> get defaultAccounts {
  return [
    AccountModel(name: 'Cash', type: 'cash', balance: 0.0, openingBalance: 0.0, isDefault: true, color: '#FF4696', icon: 'money'),
    AccountModel(name: 'Savings Account', type: 'savings', balance: 0.0, openingBalance: 0.0, color: '#1E1033', icon: 'savings'),
    AccountModel(name: 'Wallet', type: 'wallet', balance: 0.0, openingBalance: 0.0, color: '#36CFA3', icon: 'account_balance_wallet'),
  ];
}
