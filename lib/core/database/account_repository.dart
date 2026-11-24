import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/account_model.dart';

class AccountRepository {
  Future<List<AccountModel>> getAllAccounts() {
    if (!AppDatabase.isInitialized) return Future.value([]);
    return Future.value(AppDatabase.accounts.values.where((a) => a.isActive).toList());
  }

  Future<AccountModel?> getAccountById(String id) {
    if (!AppDatabase.isInitialized) return Future.value(null);
    return Future.value(AppDatabase.accounts.get(id));
  }

  Future<AccountModel?> getDefaultAccount() {
    if (!AppDatabase.isInitialized) return Future.value(null);
    return Future.value(AppDatabase.accounts.values.firstWhereOrNull((a) => a.isDefault));
  }

  Future<void> addAccount(AccountModel account) async {
    if (!AppDatabase.isInitialized) return;
    // If this is default, unset others
    if (account.isDefault) {
      for (final a in AppDatabase.accounts.values) {
        if (a.isDefault) {
          a.isDefault = false;
          await AppDatabase.accounts.put(a.id, a);
        }
      }
    }
    await AppDatabase.accounts.put(account.id, account);
  }

  Future<void> updateAccount(AccountModel account) async {
    if (!AppDatabase.isInitialized) return;
    account.updatedAt = DateTime.now();
    if (account.isDefault) {
      for (final a in AppDatabase.accounts.values) {
        if (a.id != account.id && a.isDefault) {
          a.isDefault = false;
          await AppDatabase.accounts.put(a.id, a);
        }
      }
    }
    await AppDatabase.accounts.put(account.id, account);
  }

  Future<void> deleteAccount(String id) async {
    if (!AppDatabase.isInitialized) return;
    await AppDatabase.accounts.delete(id);
  }

  Future<void> updateBalance(String id, double newBalance) async {
    if (!AppDatabase.isInitialized) return;
    final account = AppDatabase.accounts.get(id);
    if (account != null) {
      account.balance = newBalance;
      account.updatedAt = DateTime.now();
      await AppDatabase.accounts.put(account.id, account);
    }
  }
}

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
