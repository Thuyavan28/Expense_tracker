import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

part 'category_model.g.dart';

final _uuid = Uuid();

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // expense, income

  @HiveField(3)
  String icon; // icon name

  @HiveField(4)
  int color; // color as int

  @HiveField(5)
  bool isCustom;

  @HiveField(6)
  bool isActive;

  CategoryModel({
    String? id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isCustom = false,
    this.isActive = true,
  }) : id = id ?? _uuid.v4();

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      isCustom: json['isCustom'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isCustom': isCustom,
      'isActive': isActive,
    };
  }
}

/// Predefined expense categories
List<CategoryModel> get defaultExpenseCategories {
  return [
    CategoryModel(name: 'Food and Dining', type: AppConstants.typeExpense, icon: 'restaurant', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Groceries', type: AppConstants.typeExpense, icon: 'shopping_cart', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Transportation', type: AppConstants.typeExpense, icon: 'directions_car', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Shopping', type: AppConstants.typeExpense, icon: 'shopping_bag', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Entertainment', type: AppConstants.typeExpense, icon: 'movie', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Education', type: AppConstants.typeExpense, icon: 'school', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Healthcare', type: AppConstants.typeExpense, icon: 'local_hospital', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Rent', type: AppConstants.typeExpense, icon: 'apartment', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Utilities', type: AppConstants.typeExpense, icon: 'bolt', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Travel', type: AppConstants.typeExpense, icon: 'flight', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Subscriptions', type: AppConstants.typeExpense, icon: 'subscription', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Personal Care', type: AppConstants.typeExpense, icon: 'spa', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Insurance', type: AppConstants.typeExpense, icon: 'insights', color: 0xFFFF4696, isCustom: false),
    CategoryModel(name: 'Others', type: AppConstants.typeExpense, icon: 'more_horiz', color: 0xFFFF4696, isCustom: false),
  ];
}

/// Predefined income categories
List<CategoryModel> get defaultIncomeCategories {
  return [
    CategoryModel(name: 'Salary', type: AppConstants.typeIncome, icon: 'work', color: 0xFF36CFA3, isCustom: false),
    CategoryModel(name: 'Freelance', type: AppConstants.typeIncome, icon: 'computer', color: 0xFF36CFA3, isCustom: false),
    CategoryModel(name: 'Business', type: AppConstants.typeIncome, icon: 'store', color: 0xFF36CFA3, isCustom: false),
    CategoryModel(name: 'Investment Returns', type: AppConstants.typeIncome, icon: 'trending_up', color: 0xFF36CFA3, isCustom: false),
    CategoryModel(name: 'Gifts', type: AppConstants.typeIncome, icon: 'card_giftcard', color: 0xFF36CFA3, isCustom: false),
    CategoryModel(name: 'Other Income', type: AppConstants.typeIncome, icon: 'add_circle', color: 0xFF36CFA3, isCustom: false),
  ];
}
