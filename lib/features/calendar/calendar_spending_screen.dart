import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/transactions/add_transaction_popup.dart';
import 'package:pinkledger/shared/popups/transaction_detail_popup.dart';

/// Interactive Calendar-based Spending UI (Modern Light Mode with Black Borders)
class CalendarSpendingScreen extends StatefulWidget {
  const CalendarSpendingScreen({super.key});

  @override
  State<CalendarSpendingScreen> createState() => _CalendarSpendingScreenState();
}

class _CalendarSpendingScreenState extends State<CalendarSpendingScreen> {
  final TransactionRepository _repo = TransactionRepository();

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<DateTime, List<TransactionModel>> _txnsByDate = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final txns = await _repo.getAllTransactions();

    final map = <DateTime, List<TransactionModel>>{};
    for (final t in txns) {
      final dateKey = DateTime(t.date.year, t.date.month, t.date.day);
      if (!map.containsKey(dateKey)) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(t);
    }

    if (mounted) {
      setState(() {
        _txnsByDate = map;
        _loading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }

  void _openAddForSelectedDay() {
    AddTransactionPopup.show(
      context,
      initialDate: _selectedDate,
      initialType: AppConstants.typeExpense,
      onSave: (data) async {
        final txn = TransactionModel(
          type: data['type'],
          amount: data['amount'],
          category: data['category'],
          paymentMethod: data['paymentMethod'],
          date: data['date'],
          description: data['description'],
          merchantName: data['merchantName'],
          notes: data['notes'],
          tags: data['tags'],
          status: data['status'],
          sourceAccountId: data['sourceAccountId'],
          destinationAccountId: data['destinationAccountId'],
        );
        await _repo.addTransaction(txn);
        _loadData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final dayTxns = _txnsByDate[selectedKey] ?? [];

    double daySpent = 0;
    double dayIncome = 0;
    for (final t in dayTxns) {
      if (t.type == AppConstants.typeExpense) {
        daySpent += t.amount;
      } else if (t.type == AppConstants.typeIncome) {
        dayIncome += t.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Calendar Spending',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Touch any day to inspect spending & delete records',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.black),
            tooltip: 'Add Transaction',
            onPressed: _openAddForSelectedDay,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  // 1. Month Navigation Header
                  _buildMonthHeader(),

                  const SizedBox(height: 14),

                  // 2. Interactive Calendar Matrix Card (Light Mode, Black Border)
                  _buildCalendarMatrix(),

                  const SizedBox(height: 18),

                  // 3. Selected Day Summary Card (Amount Spent & Details)
                  _buildDaySpendingHero(daySpent, dayIncome, dayTxns.length),

                  const SizedBox(height: 18),

                  // 4. Itemized Sent / Spent Transactions Breakdown with Popup Actions
                  _buildDayTransactionsList(dayTxns),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthHeader() {
    final title = DateFormat('MMMM yyyy').format(_focusedMonth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2.5, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
                onPressed: _prevMonth,
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.black),
                onPressed: _nextMonth,
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMatrix() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final totalCells = ((firstWeekday - 1) + daysInMonth <= 35) ? 35 : 42;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) {
              final isWeekend = w == 'Sat' || w == 'Sun';
              return Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      color: isWeekend ? AppColors.expenseRed : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 10),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink(); // Empty cell outside this month
              }

              final day = dayOffset + 1;
              final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isSelected = cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              final today = DateTime.now();
              final isToday = cellDate.year == today.year &&
                  cellDate.month == today.month &&
                  cellDate.day == today.day;

              // Check if day has transactions
              final cellKey = DateTime(cellDate.year, cellDate.month, cellDate.day);
              final dayTxnList = _txnsByDate[cellKey] ?? [];

              double dayTotalExpense = 0;
              for (final t in dayTxnList) {
                if (t.type == AppConstants.typeExpense) {
                  dayTotalExpense += t.amount;
                }
              }

              return InkWell(
                onTap: () => _onDaySelected(cellDate),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black
                        : (isToday ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : (isToday ? Colors.black : const Color(0xFFCBD5E1)),
                      width: isSelected || isToday ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(1.5, 1.5),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday ? const Color(0xFF0369A1) : Colors.black),
                          fontSize: 13,
                          fontWeight: (isSelected || isToday)
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Spending indicator dot
                      if (dayTxnList.isNotEmpty)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (dayTotalExpense > 0 ? AppColors.expenseRed : AppColors.liteGreen)
                                : (dayTotalExpense > 0 ? AppColors.expenseRed : AppColors.liteGreen),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.black,
                              width: 1,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaySpendingHero(double daySpent, double dayIncome, int count) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
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
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  '$count Records',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Spent Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${AppConstants.currencySymbol} ${daySpent.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'total spent',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (dayIncome > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.liteGreen),
                const SizedBox(width: 4),
                Text(
                  'Received: ${AppConstants.currencySymbol} ${dayIncome.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.liteGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayTransactionsList(List<TransactionModel> txns) {
    if (txns.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 36,
                color: AppColors.liteGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Records on this Date',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No money spent or recorded on this day. Clean sheet!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAddForSelectedDay,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'Add Record for this Day',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Records (Tap for actions)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextButton.icon(
              onPressed: _openAddForSelectedDay,
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text(
                'Add Record',
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...txns.map((t) => _buildTransactionCard(t)),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final isExpense = t.type == AppConstants.typeExpense;
    final isIncome = t.type == AppConstants.typeIncome;
    final color = isExpense
        ? AppColors.expenseRed
        : (isIncome ? AppColors.liteGreen : AppColors.savingsBlue);

    return InkWell(
      onTap: () => TransactionDetailPopup.show(
        context,
        transaction: t,
        onDeleted: _loadData,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1.2),
              ),
              child: Icon(
                isExpense
                    ? Icons.arrow_upward_rounded
                    : (isIncome ? Icons.arrow_downward_rounded : Icons.swap_horiz_rounded),
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.description.isNotEmpty ? t.description : t.category,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        t.category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (t.merchantName != null && t.merchantName!.isNotEmpty) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        Flexible(
                          child: Text(
                            t.merchantName!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      Text(
                        t.paymentMethod,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${isExpense ? '-' : (isIncome ? '+' : '')}${AppConstants.currencySymbol} ${t.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed, size: 20),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete',
              onPressed: () => _confirmDirectDelete(t),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDirectDelete(TransactionModel t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text('Delete Transaction?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text('Delete "${t.description.isNotEmpty ? t.description : t.category}" for ₹${t.amount.toStringAsFixed(0)}?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.deleteTransaction(t.id);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Transaction deleted'),
                backgroundColor: Colors.black,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
