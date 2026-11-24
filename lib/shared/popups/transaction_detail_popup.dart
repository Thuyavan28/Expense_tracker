import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/transaction_model.dart';
import 'package:pinkledger/core/database/transaction_repository.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// Reusable Transaction Detail & Action Popup Dialog (Light Mode, Black Borders)
class TransactionDetailPopup extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDeleted;

  const TransactionDetailPopup({
    super.key,
    required this.transaction,
    required this.onDeleted,
  });

  /// Opens the detail & action popup
  static Future<void> show(
    BuildContext context, {
    required TransactionModel transaction,
    required VoidCallback onDeleted,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Transaction Detail',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: TransactionDetailPopup(
              transaction: transaction,
              onDeleted: onDeleted,
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
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
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be reversed.',
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
              Navigator.pop(ctx); // Close confirm
              Navigator.of(context, rootNavigator: true).pop(); // Close detail popup
              await TransactionRepository().deleteTransaction(transaction.id);
              onDeleted();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Transaction deleted successfully', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: Colors.black,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
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
    final isExpense = transaction.type == AppConstants.typeExpense;
    final isIncome = transaction.type == AppConstants.typeIncome;
    final typeColor = isExpense
        ? AppColors.expenseRed
        : (isIncome ? AppColors.liteGreen : AppColors.savingsBlue);

    return Container(
      width: 440,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpense
                          ? Icons.arrow_upward_rounded
                          : (isIncome ? Icons.arrow_downward_rounded : Icons.swap_horiz_rounded),
                      size: 14,
                      color: typeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: typeColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.black, size: 22),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Amount Hero
          Center(
            child: Text(
              '${isExpense ? '-' : (isIncome ? '+' : '')}${AppConstants.currencySymbol} ${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: typeColor,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              transaction.description.isNotEmpty ? transaction.description : transaction.category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),

          // Itemized Details Table
          _buildDetailRow(Icons.category_rounded, 'Category', transaction.category),
          const SizedBox(height: 10),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Date & Time',
            DateFormat('d MMM yyyy • h:mm a').format(transaction.date),
          ),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.account_balance_wallet_rounded, 'Payment Mode', transaction.paymentMethod),

          if (transaction.merchantName != null && transaction.merchantName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(Icons.storefront_rounded, 'Merchant', transaction.merchantName!),
          ],

          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDetailRow(Icons.notes_rounded, 'Notes', transaction.notes!),
          ],

          const SizedBox(height: 24),

          // Action Buttons: Delete and Close
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed, size: 18),
                  label: const Text(
                    'Delete Record',
                    style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.expenseRed, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
