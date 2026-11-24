import 'package:flutter/material.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// FAB popup action menu with staggered animations
class FABPopupMenu extends StatefulWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onTransfer;
  final VoidCallback onScanReceipt;
  final VoidCallback onAddRecurring;
  final VoidCallback onCreateBudget;

  const FABPopupMenu({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onTransfer,
    required this.onScanReceipt,
    required this.onAddRecurring,
    required this.onCreateBudget,
  });

  @override
  State<FABPopupMenu> createState() => _FABPopupMenuState();
}

class _FABPopupMenuState extends State<FABPopupMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationNormal,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.785).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildMenuItem(Icons.attach_money, 'Add Expense', AppColors.primaryPink, widget.onAddExpense, 0),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.add_circle, 'Add Income', AppColors.secondaryTeal, widget.onAddIncome, 1),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.swap_horiz, 'Transfer Money', AppColors.infoBlue, widget.onTransfer, 2),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.camera_alt, 'Scan Receipt', AppColors.warningAmber, widget.onScanReceipt, 3),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.repeat, 'Add Recurring', AppColors.mutedText, widget.onAddRecurring, 4),
          const SizedBox(height: 12),
          _buildMenuItem(Icons.account_balance_wallet, 'Create Budget', AppColors.primaryPink, widget.onCreateBudget, 5),
          const SizedBox(height: 12),
        ],
        Transform.rotate(
          angle: _rotationAnimation.value,
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: AppColors.primaryPink,
            child: Icon(_isOpen ? Icons.close : Icons.add, color: AppColors.white),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color, VoidCallback onTap, int index) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + index * 0.05, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          width: 250,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _toggle();
                onTap();
              },
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dim overlay for popup background
class DimOverlay extends StatelessWidget {
  final VoidCallback onTap;
  final bool isVisible;

  const DimOverlay({super.key, required this.onTap, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.durationFast,
          color: Colors.black.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
