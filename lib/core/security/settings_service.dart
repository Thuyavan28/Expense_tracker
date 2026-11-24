import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinkledger/core/constants/app_constants.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // SharedPreferences may not be available on all platforms (e.g., web without proper setup)
      _prefs = null;
    }
  }

  bool get _isInitialized => _prefs != null;

  Future<bool> getOnboardingCompleted() async =>
      _isInitialized ? (_prefs!.getBool(AppConstants.keyOnboardingCompleted) ?? false) : false;
  Future<void> setOnboardingCompleted(bool value) async {
    if (_isInitialized) await _prefs!.setBool(AppConstants.keyOnboardingCompleted, value);
  }

  Future<bool> getIsAuthenticated() async =>
      _isInitialized ? (_prefs!.getBool(AppConstants.keyIsAuthenticated) ?? false) : false;
  Future<void> setIsAuthenticated(bool value) async {
    if (_isInitialized) await _prefs!.setBool(AppConstants.keyIsAuthenticated, value);
  }

  Future<bool> getHasPIN() async => _isInitialized ? (_prefs!.getBool(AppConstants.keyHasPIN) ?? false) : false;
  Future<void> setHasPIN(bool value) async {
    if (_isInitialized) await _prefs!.setBool(AppConstants.keyHasPIN, value);
  }

  Future<ThemeMode> getThemeMode() async {
    if (!_isInitialized) return ThemeMode.system;
    final index = _prefs!.getInt(AppConstants.keyThemeMode) ?? 0;
    return ThemeMode.values[index.clamp(0, ThemeMode.values.length - 1)];
  }
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_isInitialized) await _prefs!.setInt(AppConstants.keyThemeMode, mode.index);
  }

  Future<String> getDefaultCurrency() async =>
      _isInitialized ? (_prefs!.getString(AppConstants.keyCurrency) ?? AppConstants.defaultCurrency) : AppConstants.defaultCurrency;
  Future<void> setDefaultCurrency(String value) async {
    if (_isInitialized) await _prefs!.setString(AppConstants.keyCurrency, value);
  }

  Future<int> getFirstDayOfMonth() async => _isInitialized ? (_prefs!.getInt(AppConstants.keyFirstDayOfMonth) ?? 1) : 1;
  Future<void> setFirstDayOfMonth(int value) async {
    if (_isInitialized) await _prefs!.setInt(AppConstants.keyFirstDayOfMonth, value);
  }

  Future<bool> getGuestMode() async => _isInitialized ? (_prefs!.getBool(AppConstants.keyGuestMode) ?? false) : false;
  Future<void> setGuestMode(bool value) async {
    if (_isInitialized) await _prefs!.setBool(AppConstants.keyGuestMode, value);
  }

  Future<String?> getDefaultAccountId() async =>
      _isInitialized ? _prefs!.getString(AppConstants.keyDefaultAccount) : null;
  Future<void> setDefaultAccountId(String? id) async {
    if (_isInitialized) {
      if (id == null) await _prefs!.remove(AppConstants.keyDefaultAccount);
      else await _prefs!.setString(AppConstants.keyDefaultAccount, id);
    }
  }

  Future<bool> getBudgetAlerts() async => _isInitialized ? (_prefs!.getBool('budget_alerts') ?? true) : true;
  Future<void> setBudgetAlerts(bool value) async {
    if (_isInitialized) await _prefs!.setBool('budget_alerts', value);
  }

  Future<bool> getBillReminders() async => _isInitialized ? (_prefs!.getBool('bill_reminders') ?? true) : true;
  Future<void> setBillReminders(bool value) async {
    if (_isInitialized) await _prefs!.setBool('bill_reminders', value);
  }

  Future<bool> getDailySummary() async => _isInitialized ? (_prefs!.getBool('daily_summary') ?? false) : false;
  Future<void> setDailySummary(bool value) async {
    if (_isInitialized) await _prefs!.setBool('daily_summary', value);
  }

  Future<int> getAutoLockTimeout() async => _isInitialized ? (_prefs!.getInt('auto_lock_timeout') ?? 5) : 5;
  Future<void> setAutoLockTimeout(int value) async {
    if (_isInitialized) await _prefs!.setInt('auto_lock_timeout', value);
  }

  Future<void> savePIN(String pin) => _secureStorage.write(key: AppConstants.keyPIN, value: pin);
  Future<String?> getPIN() => _secureStorage.read(key: AppConstants.keyPIN);
  Future<void> deletePIN() => _secureStorage.delete(key: AppConstants.keyPIN);

  Future<bool> getBiometricEnabled() async => _isInitialized ? (_prefs!.getBool(AppConstants.keyBiometricEnabled) ?? false) : false;
  Future<void> setBiometricEnabled(bool value) async {
    if (_isInitialized) await _prefs!.setBool(AppConstants.keyBiometricEnabled, value);
  }

  Future<void> clearAllData() async {
    if (_isInitialized) await _prefs!.clear();
    await _secureStorage.deleteAll();
  }
}
