import 'package:flutter/material.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// Success popup with check icon and lime color
class SuccessPopup extends StatelessWidget {
  final String title;
  final String message;
  final String? updatedBalance;
  final VoidCallback onDone;
  final VoidCallback? onViewTransaction;

  const SuccessPopup({
    super.key,
    required this.title,
    required this.message,
    this.updatedBalance,
    required this.onDone,
    this.onViewTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.successLime.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 40, color: AppColors.successLime),
            ),
            const SizedBox(height: AppTokens.md),
            Text(title, style: AppTypography.headlineMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: AppTokens.sm),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText), textAlign: TextAlign.center),
            if (updatedBalance != null) ...[
              const SizedBox(height: AppTokens.md),
              Container(
                padding: const EdgeInsets.all(AppTokens.md),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet, color: AppColors.successLime, size: 20),
                    const SizedBox(width: AppTokens.sm),
                    Text(
                      'Updated Balance: ${AppConstants.currencySymbol} $updatedBalance',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.successLime),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppTokens.lg),
            Row(
              children: [
                if (onViewTransaction != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewTransaction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryPink,
                        side: const BorderSide(color: AppColors.primaryPink),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                      ),
                      child: const Text('View Transaction'),
                    ),
                  ),
                if (onViewTransaction != null) const SizedBox(width: AppTokens.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successLime,
                      foregroundColor: AppColors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Error popup with red color
class ErrorPopup extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const ErrorPopup({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error, size: 40, color: AppColors.errorRed),
            ),
            const SizedBox(height: AppTokens.md),
            Text(title, style: AppTypography.headlineMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: AppTokens.sm),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText), textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mutedText,
                      side: const BorderSide(color: AppColors.mutedText),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTokens.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation popup for delete actions
class ConfirmationPopup extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationPopup({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning, size: 40, color: AppColors.warningAmber),
            ),
            const SizedBox(height: AppTokens.md),
            Text(title, style: AppTypography.headlineMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: AppTokens.sm),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText), textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.sm),
            Container(
              padding: const EdgeInsets.all(AppTokens.md),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 20),
                  const SizedBox(width: AppTokens.sm),
                  Expanded(
                    child: Text(
                      itemName,
                      style: AppTypography.labelLarge.copyWith(color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mutedText,
                      side: const BorderSide(color: AppColors.mutedText),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTokens.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                    ),
                    child: const Text('Confirm Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
