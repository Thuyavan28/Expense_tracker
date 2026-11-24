import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/security/settings_service.dart';
import 'package:pinkledger/core/services/providers.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _budgetAlerts = true;
  bool _billReminders = true;
  bool _dailySummary = false;
  bool _hasPIN = false;
  bool _biometric = false;
  final String _currency = '₹ INR';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final srv = SettingsService();
    final pin = await srv.getHasPIN();
    final bio = await srv.getBiometricEnabled();
    final ba = await srv.getBudgetAlerts();
    final br = await srv.getBillReminders();
    final ds = await srv.getDailySummary();
    if (mounted) {
      setState(() {
        _hasPIN = pin;
        _biometric = bio;
        _budgetAlerts = ba;
        _billReminders = br;
        _dailySummary = ds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Profile card
          _buildProfileCard(),

          // Appearance
          _section('APPEARANCE'),
          _switchTile(
            icon: Icons.light_mode_rounded,
            title: 'Light Mode',
            subtitle: 'Neo-Fintech High-Contrast Theme (Active)',
            value: true,
            onChanged: (_) {},
            readOnly: true,
          ),

          // Financial
          _section('FINANCIAL PREFERENCES'),
          _tile(
            icon: Icons.currency_rupee_rounded,
            title: 'Default Currency',
            trailing: Text(
              _currency,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          _tile(
            icon: Icons.account_balance_rounded,
            title: 'Default Account',
            trailing: const Text(
              'Main Account',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          _tile(
            icon: Icons.calendar_today_rounded,
            title: 'Start of Month',
            trailing: const Text(
              '1st',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),

          // Notifications
          _section('NOTIFICATIONS'),
          _switchTile(
            icon: Icons.notifications_active_rounded,
            title: 'Budget Alerts',
            subtitle: 'Notify when approaching spending limits',
            value: _budgetAlerts,
            onChanged: (v) async {
              setState(() => _budgetAlerts = v);
              await SettingsService().setBudgetAlerts(v);
            },
          ),
          _switchTile(
            icon: Icons.alarm_rounded,
            title: 'Bill Reminders',
            subtitle: 'Remind before recurring payments',
            value: _billReminders,
            onChanged: (v) async {
              setState(() => _billReminders = v);
              await SettingsService().setBillReminders(v);
            },
          ),
          _switchTile(
            icon: Icons.bar_chart_rounded,
            title: 'Daily Summary',
            subtitle: 'Send end-of-day summary',
            value: _dailySummary,
            onChanged: (v) async {
              setState(() => _dailySummary = v);
              await SettingsService().setDailySummary(v);
            },
          ),

          // Security
          _section('SECURITY & PRIVACY'),
          _switchTile(
            icon: Icons.lock_rounded,
            title: 'App PIN Lock',
            subtitle: 'Require PIN to open PinkLedger',
            value: _hasPIN,
            onChanged: (v) async {
              if (v) {
                Navigator.of(context).pushNamed(AppConstants.pinSetup);
              } else {
                await SettingsService().setHasPIN(false);
                await SettingsService().deletePIN();
                setState(() => _hasPIN = false);
              }
            },
          ),
          _switchTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Auth',
            subtitle: 'Use fingerprint or Face ID',
            value: _biometric,
            onChanged: (v) async {
              setState(() => _biometric = v);
              await SettingsService().setBiometricEnabled(v);
            },
          ),

          // Data Management
          _section('DATA MANAGEMENT'),
          _tile(
            icon: Icons.backup_rounded,
            title: 'Backup Data',
            subtitle: 'Export backup of your financial data',
          ),
          _tile(
            icon: Icons.restore_rounded,
            title: 'Restore Data',
            subtitle: 'Restore financial records from file',
          ),
          _tile(
            icon: Icons.download_rounded,
            title: 'Export CSV',
            subtitle: 'Download spreadsheet of all transactions',
          ),
          const SizedBox(height: 12),
          _dangerTile(),

          // About
          _section('ABOUT'),
          _tile(
            icon: Icons.info_outline_rounded,
            title: 'PinkLedger',
            subtitle: 'v2.0.0 — Modern Personal Finance',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.liteGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: const Text(
                'Latest',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final isGuest = ref.watch(guestModeProvider);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.liteGreen.withValues(alpha: 0.2),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(
              isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
              color: Colors.black,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? 'Local Guest Account' : 'PinkLedger User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isGuest ? 'Offline Local Storage Active' : 'Personal Finance Manager',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool readOnly = false,
  }) {
    return _buildTileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: readOnly ? null : onChanged,
        activeColor: Colors.black,
        activeTrackColor: AppColors.liteGreen,
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return _buildTileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 20),
    );
  }

  Widget _buildTileShell({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _dangerTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.expenseRed, size: 20),
        label: const Text(
          'Delete All Data',
          style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold),
        ),
        onPressed: _showDeleteConfirm,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.expenseRed, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: AppColors.expenseRed, size: 28),
            SizedBox(width: 10),
            Text(
              'Delete All Data?',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'This will permanently wipe all transactions, budgets, and settings. This action cannot be reversed.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              await SettingsService().clearAllData();
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Wipe', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
