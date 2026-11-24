import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/dashboard/dashboard_screen.dart';
import 'package:pinkledger/features/calendar/calendar_spending_screen.dart';
import 'package:pinkledger/features/transactions/transactions_screen.dart';
import 'package:pinkledger/features/analytics/analytics_screen.dart';
import 'package:pinkledger/features/transactions/add_transaction_popup.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';

/// Modern Light Mode Navigation System (White BG, Black Text, Solid Black Borders)
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabCtrl;
  bool _fabOpen = false;

  final _screens = const [
    DashboardScreen(),
    CalendarSpendingScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    if (i == 2) {
      _toggleFAB();
      return;
    }
    // Slot 0 -> Dashboard (index 0)
    // Slot 1 -> Calendar (index 1)
    // Slot 2 -> Center FAB
    // Slot 3 -> Transactions (index 2)
    // Slot 4 -> Analytics (index 3)
    setState(() => _selectedIndex = i < 2 ? i : i - 1);
  }

  void _toggleFAB() {
    setState(() => _fabOpen = !_fabOpen);
    if (_fabOpen) {
      _fabCtrl.forward();
    } else {
      _fabCtrl.reverse();
    }
  }

  void _showAddTransaction(String type) {
    if (_fabOpen) _toggleFAB();
    AddTransactionPopup.show(
      context,
      initialType: type,
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
        await TransactionRepository().addTransaction(txn);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Transaction successfully recorded',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
    );
  }

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar'),
    _NavItem(icon: Icons.add, label: ''), // Centre FAB
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Records'),
    _NavItem(icon: Icons.analytics_rounded, label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildNavBar(),
        ),

        // FAB menu backdrop overlay
        if (_fabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleFAB,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _fabOpen ? 1 : 0,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          ),

        // Animated FAB action buttons popup
        if (_fabOpen)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fabCtrl,
              builder: (_, __) => Column(
                children: [
                  _FABAction(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Add Expense',
                    color: AppColors.expenseRed,
                    anim: _fabCtrl,
                    delay: 0.2,
                    onTap: () => _showAddTransaction(AppConstants.typeExpense),
                  ),
                  const SizedBox(height: 12),
                  _FABAction(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Add Income',
                    color: AppColors.liteGreen,
                    anim: _fabCtrl,
                    delay: 0.1,
                    onTap: () => _showAddTransaction(AppConstants.typeIncome),
                  ),
                  const SizedBox(height: 12),
                  _FABAction(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer Money',
                    color: AppColors.savingsBlue,
                    anim: _fabCtrl,
                    delay: 0.0,
                    onTap: () => _showAddTransaction(AppConstants.typeTransfer),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final isCenter = i == 2;
              final isSelected = !isCenter && (i < 2 ? i == _selectedIndex : i - 1 == _selectedIndex);

              if (isCenter) {
                return GestureDetector(
                  onTap: () => _onNavTap(2),
                  child: AnimatedBuilder(
                    animation: _fabCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _fabCtrl.value * 0.785, // 45 degree rotation
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.liteGreen,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _fabOpen ? Icons.close_rounded : Icons.add_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: InkWell(
                  onTap: () => _onNavTap(i),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _navItems[i].icon,
                          color: isSelected ? Colors.black : const Color(0xFF64748B),
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _navItems[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? Colors.black : const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 16 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.liteGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 0.5)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _FABAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final AnimationController anim;
  final double delay;
  final VoidCallback onTap;

  const _FABAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.anim,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: anim,
      curve: Interval(delay, (delay + 0.4).clamp(0, 1.0), curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curve),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(curve),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(icon, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
