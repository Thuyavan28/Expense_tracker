import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/category_model.dart';

class CategoryRepository {
  Future<List<CategoryModel>> getAllCategories() {
    return Future.value(AppDatabase.categories.values.where((c) => c.isActive).toList());
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) {
    return Future.value(
      AppDatabase.categories.values.where((c) => c.type == type && c.isActive).toList(),
    );
  }

  Future<CategoryModel?> getCategoryById(String id) {
    return Future.value(AppDatabase.categories.get(id));
  }

  Future<void> addCategory(CategoryModel category) async {
    await AppDatabase.categories.put(category.id, category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await AppDatabase.categories.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await AppDatabase.categories.delete(id);
  }
}
