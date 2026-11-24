import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/transactions/add_transaction_popup.dart';
import 'package:pinkledger/shared/popups/transaction_detail_popup.dart';

/// Modern Light Mode Dashboard Screen (White BG, Black Text, Solid Black Borders)
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  final TransactionRepository _repo = TransactionRepository();
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _netSavings = 0;
  bool _balanceHidden = false;
  bool _loading = true;
  List<TransactionModel> _recentTxns = [];

  late AnimationController _entranceCtrl;
  late Animation<double> _cardFade;
  late Animation<double> _cardSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _cardSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    final income = await _repo.getTotalByType('income', start: start, end: end);
    final expenses = await _repo.getTotalByType('expense', start: start, end: end);
    final all = await _repo.getAllTransactions();

    if (mounted) {
      setState(() {
        _totalIncome = income;
        _totalExpenses = expenses;
        _netSavings = income - expenses;
        _recentTxns = all.take(6).toList();
        _loading = false;
      });
      _entranceCtrl.forward(from: 0);
    }
  }

  String _fmt(double v) => '${AppConstants.currencySymbol} ${v.abs().toStringAsFixed(0)}';

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _confirmDeleteTxn(TransactionModel txn) {
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
            Icon(Icons.warning_amber_rounded, color: AppColors.expenseRed, size: 26),
            SizedBox(width: 10),
            Text(
              'Delete Record?',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Delete "${txn.description}" (${txn.type == AppConstants.typeExpense ? '-' : '+'}${AppConstants.currencySymbol} ${txn.amount.toStringAsFixed(0)})?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              Navigator.pop(ctx);
              await _repo.deleteTransaction(txn.id);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('Transaction deleted', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: AnimatedBuilder(
            animation: _entranceCtrl,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Transform.translate(
                  offset: Offset(0, _cardSlide.value),
                  child: Opacity(opacity: _cardFade.value, child: _buildBalanceCard()),
                ),
                const SizedBox(height: 20),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildSectionHeader('Spending Overview', null),
                const SizedBox(height: 12),
                _buildSpendingChart(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Recent Transactions',
                  () => Navigator.pushNamed(context, AppConstants.transactions),
                ),
                const SizedBox(height: 12),
                _buildRecentTransactionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM y').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _SquareBtn(
              icon: Icons.movie_filter_rounded,
              onTap: () => Navigator.pushNamed(context, AppConstants.splash),
            ),
            const SizedBox(width: 8),
            _SquareBtn(
              icon: _balanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              onTap: () => setState(() => _balanceHidden = !_balanceHidden),
            ),
            const SizedBox(width: 8),
            _SquareBtn(
              icon: Icons.refresh_rounded,
              onTap: _loadData,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.liteGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  DateFormat('MMMM y').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppConstants.currencySymbol,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _balanceHidden ? '••••••' : _netSavings.abs().toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1.5,
                ),
              ),
              if (!_balanceHidden && _netSavings < 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEFICIT',
                    style: TextStyle(
                      color: AppColors.expenseRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.black, thickness: 1.5, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Income',
                  _totalIncome,
                  AppColors.liteGreen,
                  Icons.arrow_downward_rounded,
                ),
              ),
              Container(width: 1.5, height: 38, color: Colors.black),
              Expanded(
                child: _buildMiniStat(
                  'Expenses',
                  _totalExpenses,
                  AppColors.expenseRed,
                  Icons.arrow_upward_rounded,
                ),
              ),
              Container(width: 1.5, height: 38, color: Colors.black),
              Expanded(
                child: _buildMiniStat(
                  'Savings',
                  _netSavings.clamp(0.0, double.infinity).toDouble(),
                  AppColors.savingsBlue,
                  Icons.savings_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _balanceHidden ? '••••' : _fmt(value),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final savings = _netSavings.clamp(0.0, double.infinity).toDouble();
    final budgetUsedPct = _totalIncome > 0
        ? ((_totalExpenses / _totalIncome) * 100).clamp(0, 100).toStringAsFixed(0)
        : '0';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Income This Month',
                value: _fmt(_totalIncome),
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.liteGreen,
                hidden: _balanceHidden,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Expenses This Month',
                value: _fmt(_totalExpenses),
                icon: Icons.trending_down_rounded,
                accentColor: AppColors.expenseRed,
                hidden: _balanceHidden,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Net Savings',
                value: _fmt(savings),
                icon: Icons.savings_rounded,
                accentColor: AppColors.savingsBlue,
                hidden: _balanceHidden,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Budget Used',
                value: '$budgetUsedPct%',
                icon: Icons.pie_chart_rounded,
                accentColor: AppColors.warningOrange,
                hidden: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: const [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSpendingChart() {
    if (_totalIncome == 0 && _totalExpenses == 0) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: AppColors.textSecondary, size: 36),
              SizedBox(height: 8),
              Text(
                'No transactions recorded this month',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final total = _totalIncome + _totalExpenses;
    final expPct = total > 0 ? (_totalExpenses / total * 100).round() : 0;
    final incPct = total > 0 ? (_totalIncome / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3.5, 3.5), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 36,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: _totalExpenses.clamp(0.001, double.infinity),
                    color: AppColors.chartColors[4], // Vivid Coral Red
                    radius: 28,
                    showTitle: false,
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  PieChartSectionData(
                    value: _totalIncome.clamp(0.001, double.infinity),
                    color: AppColors.chartColors[1], // Vivid Emerald Green
                    radius: 28,
                    showTitle: false,
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChartLegendRow(
                  color: AppColors.chartColors[1],
                  label: 'Income',
                  percentage: '$incPct%',
                  amount: _fmt(_totalIncome),
                ),
                const SizedBox(height: 14),
                _ChartLegendRow(
                  color: AppColors.chartColors[4],
                  label: 'Expenses',
                  percentage: '$expPct%',
                  amount: _fmt(_totalExpenses),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    if (_recentTxns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            const Text(
              'No recent transactions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the + button below to log your first record',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                AddTransactionPopup.show(context, onSave: (_) => _loadData());
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentTxns.map((txn) {
        return _DashboardTxnCard(
          txn: txn,
          onTap: () {
            TransactionDetailPopup.show(
              context,
              transaction: txn,
              onDeleted: _loadData,
            );
          },
          onDelete: () => _confirmDeleteTxn(txn),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components (Modern Light Mode with Black Outlines)
// ─────────────────────────────────────────────────────────────────────────────

class _SquareBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SquareBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool hidden;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.hidden,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Icon(icon, color: Colors.black, size: 18),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hidden ? '••••' : value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;
  final String amount;

  const _ChartLegendRow({
    required this.color,
    required this.label,
    required this.percentage,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardTxnCard extends StatelessWidget {
  final TransactionModel txn;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DashboardTxnCard({
    required this.txn,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food and dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills & utilities':
      case 'bills and utilities':
        return Icons.receipt_rounded;
      case 'salary':
      case 'income':
        return Icons.work_rounded;
      case 'health & medical':
      case 'healthcare':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = txn.type == AppConstants.typeExpense;
    final isIncome = txn.type == AppConstants.typeIncome;
    final color = isExpense
        ? AppColors.expenseRed
        : (isIncome ? AppColors.liteGreen : AppColors.savingsBlue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.4),
                  ),
                  child: Icon(
                    _getIconForCategory(txn.category),
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Date/Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            txn.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            DateFormat('d MMM').format(txn.date),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Text(
                  '${isExpense ? '-' : '+'}${AppConstants.currencySymbol} ${txn.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54, size: 20),
                  onPressed: onDelete,
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
