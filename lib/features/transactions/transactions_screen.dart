import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/transactions/add_transaction_popup.dart';
import 'package:pinkledger/shared/popups/transaction_detail_popup.dart';

/// Transactions Screen (Light Mode with Black Borders & Delete Action)
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionRepository _repo = TransactionRepository();
  final _searchCtrl = TextEditingController();
  String _filter = 'all';
  String _search = '';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final filters = ['all', 'expense', 'income', 'transfer'];
        setState(() => _filter = filters[_tabCtrl.index]);
      }
    });
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<TransactionModel>> _filtered() async {
    final all = await _repo.getAllTransactions();
    return all.where((t) {
      if (_filter != 'all' && t.type != _filter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return t.description.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            (t.merchantName ?? '').toLowerCase().contains(q);
      }
      return true;
    }).toList();
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
          'Transactions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.black),
            tooltip: 'Add Transaction',
            onPressed: _showAdd,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Expenses'),
                Tab(text: 'Income'),
                Tab(text: 'Transfer'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAdd,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: Column(
        children: [
          // Search input with black border
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search descriptions, categories, merchants...',
                hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.black, size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.black, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          // List of Transactions
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _filtered(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  );
                }
                final txns = snap.data ?? [];
                if (txns.isEmpty) return _buildEmpty();
                return _buildList(txns);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.black),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _search.isNotEmpty ? 'Try another keyword' : 'Start adding records to track your money',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (_search.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _showAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionModel> txns) {
    // Group by date
    final Map<String, List<TransactionModel>> groups = {};
    for (final t in txns) {
      final key = DateFormat('dd MMM yyyy').format(t.date);
      groups.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      itemCount: groups.length,
      itemBuilder: (ctx, i) {
        final date = groups.keys.elementAt(i);
        final dayTxns = groups[date]!;
        final dayTotal = dayTxns.fold<double>(
          0,
          (s, t) => s + (t.type == AppConstants.typeExpense ? -t.amount : t.amount),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${dayTotal >= 0 ? '+' : ''}${AppConstants.currencySymbol} ${dayTotal.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: dayTotal >= 0 ? AppColors.liteGreen : AppColors.expenseRed,
                    ),
                  ),
                ],
              ),
            ),
            ...dayTxns.map((t) => _TxnCard(
                  txn: t,
                  onDeleted: () => setState(() {}),
                )),
          ],
        );
      },
    );
  }

  void _showAdd() {
    AddTransactionPopup.show(
      context,
      onSave: _save,
    );
  }

  Future<void> _save(Map<String, dynamic> data) async {
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
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Transaction saved', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}

class _TxnCard extends StatelessWidget {
  final TransactionModel txn;
  final VoidCallback onDeleted;

  const _TxnCard({required this.txn, required this.onDeleted});

  static const _catIcons = {
    'Food and Dining': Icons.restaurant_rounded,
    'Transportation': Icons.directions_car_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Entertainment': Icons.movie_rounded,
    'Utilities': Icons.bolt_rounded,
    'Health': Icons.local_hospital_rounded,
    'Education': Icons.school_rounded,
    'Salary': Icons.payments_rounded,
    'Business': Icons.business_center_rounded,
    'Investment': Icons.trending_up_rounded,
  };

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text('Delete Transaction?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
        content: Text('Remove "${txn.description.isNotEmpty ? txn.description : txn.category}" for ₹${txn.amount.toStringAsFixed(0)}?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await TransactionRepository().deleteTransaction(txn.id);
              onDeleted();
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
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExp = txn.type == AppConstants.typeExpense;
    final isInc = txn.type == AppConstants.typeIncome;
    final color = isExp
        ? AppColors.expenseRed
        : (isInc ? AppColors.liteGreen : AppColors.savingsBlue);
    final icon = _catIcons[txn.category] ??
        (isExp
            ? Icons.arrow_upward_rounded
            : (isInc ? Icons.arrow_downward_rounded : Icons.swap_horiz_rounded));

    return InkWell(
      onTap: () => TransactionDetailPopup.show(
        context,
        transaction: txn,
        onDeleted: onDeleted,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1.2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description.isNotEmpty ? txn.description : txn.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 0.8),
                        ),
                        child: Text(
                          txn.paymentMethod,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${isExp ? '-' : '+'}${AppConstants.currencySymbol} ${txn.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed, size: 20),
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }
}
