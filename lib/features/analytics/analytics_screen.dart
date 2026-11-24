import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// Modern Light Mode Analytics Screen (White BG, Black Text, High-Contrast Charts)
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionRepository _repo = TransactionRepository();
  late TabController _tabCtrl;
  String _period = 'monthly';
  double _income = 0;
  double _expenses = 0;
  bool _loading = true;
  Map<String, double> _byCategory = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final periods = ['weekly', 'monthly', 'yearly'];
        setState(() => _period = periods[_tabCtrl.index]);
        _loadData();
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    DateTime start, end;
    switch (_period) {
      case 'weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'yearly':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31);
        break;
      default: // monthly
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
    }

    final inc = await _repo.getTotalByType('income', start: start, end: end);
    final exp = await _repo.getTotalByType('expense', start: start, end: end);
    final txns = await _repo.getTransactionsByDateRange(start, end);

    final catMap = <String, double>{};
    for (final t in txns.where((t) => t.type == AppConstants.typeExpense)) {
      catMap[t.category] = (catMap[t.category] ?? 0) + t.amount;
    }

    if (mounted) {
      setState(() {
        _income = inc;
        _expenses = exp;
        _byCategory = catMap;
        _loading = false;
      });
    }
  }

  String _periodTitle() {
    final now = DateTime.now();
    switch (_period) {
      case 'weekly':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}';
      case 'yearly':
        return '${now.year}';
      default:
        return DateFormat('MMMM y').format(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              _periodTitle(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 1.8),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
              ],
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.black,
              backgroundColor: Colors.white,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildSpendingBar(),
                  const SizedBox(height: 24),
                  if (_byCategory.isNotEmpty) ...[
                    _buildSectionTitle('Category Breakdown'),
                    const SizedBox(height: 14),
                    _buildCategoryChart(),
                    const SizedBox(height: 18),
                    _buildCategoryList(),
                  ] else
                    _buildEmptyCategories(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSummaryCards() {
    final savings = _income - _expenses;
    final rate = _income > 0 ? (savings / _income * 100).clamp(0, 100) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AnalyticCard(
                title: 'Total Income',
                value: '${AppConstants.currencySymbol} ${_income.toStringAsFixed(0)}',
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.liteGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticCard(
                title: 'Total Expenses',
                value: '${AppConstants.currencySymbol} ${_expenses.toStringAsFixed(0)}',
                icon: Icons.trending_down_rounded,
                accentColor: AppColors.expenseRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnalyticCard(
                title: 'Net Savings',
                value: '${AppConstants.currencySymbol} ${savings.abs().toStringAsFixed(0)}',
                icon: Icons.savings_rounded,
                accentColor: AppColors.savingsBlue,
                negative: savings < 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnalyticCard(
                title: 'Savings Rate',
                value: '${rate.toStringAsFixed(1)}%',
                icon: Icons.percent_rounded,
                accentColor: AppColors.warningOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpendingBar() {
    if (_income == 0 && _expenses == 0) return const SizedBox.shrink();
    final total = _income + _expenses;
    final expPct = total > 0 ? (_expenses / total).clamp(0.0, 1.0) : 0.0;
    final incPct = total > 0 ? (_income / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Income vs Expenses Ratio',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                '${(incPct * 100).toStringAsFixed(0)}% / ${(expPct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Row(
                children: [
                  Expanded(
                    flex: (incPct * 1000).round().clamp(1, 1000),
                    child: Container(color: AppColors.liteGreen),
                  ),
                  Expanded(
                    flex: (expPct * 1000).round().clamp(1, 1000),
                    child: Container(color: AppColors.expenseRed),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: AppColors.liteGreen, label: 'Income'),
              const SizedBox(width: 20),
              _LegendDot(color: AppColors.expenseRed, label: 'Expenses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    final top = _byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final entries = top.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3.5, 3.5), blurRadius: 0),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 3,
                startDegreeOffset: -90,
                sections: entries.asMap().entries.map((e) {
                  final pct = _expenses > 0 ? (e.value.value / _expenses * 100) : 0.0;
                  final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
                  return PieChartSectionData(
                    value: e.value.value,
                    color: color,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 54,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 2),
                      ],
                    ),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: entries.asMap().entries.map((e) {
              final color = AppColors.chartColors[e.key % AppColors.chartColors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    e.value.key,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final top = _byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: top.asMap().entries.map((e) {
        final pct = _expenses > 0 ? (e.value.value / _expenses) : 0.0;
        final color = AppColors.chartColors[e.key % AppColors.chartColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        e.value.key,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${AppConstants.currencySymbol} ${e.value.value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0, 1),
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCategories() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'No expense data for this period',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool negative;

  const _AnalyticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.negative = false,
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
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: negative ? AppColors.expenseRed : Colors.black,
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      );
}
