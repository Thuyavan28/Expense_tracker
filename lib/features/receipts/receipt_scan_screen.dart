import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  File? _image;
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  bool _reviewing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _reviewing = true;
      });
    }
  }

  void _confirmTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction created: ${_merchantController.text} - ${AppConstants.currencySymbol} ${_amountController.text}'),
        backgroundColor: AppColors.successLime,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(title: const Text('Receipt Scanner'), elevation: 0),
      body: _image == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 80, color: AppColors.mutedText.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),
                  Text('No receipt captured', style: AppTypography.headlineMedium.copyWith(color: AppColors.mutedText)),
                  const SizedBox(height: AppTokens.md),
                  Text('Capture or select a receipt to extract transaction details', style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedText), textAlign: TextAlign.center),
                  const SizedBox(height: AppTokens.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: AppColors.white),
                        label: const Text('Camera', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, color: AppColors.primaryPink),
                        label: const Text('Gallery', style: TextStyle(color: AppColors.primaryPink)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTokens.md),
                    child: Column(
                      children: [
                        Image.file(_image!, height: 200, fit: BoxFit.cover),
                        const SizedBox(height: AppTokens.lg),
                        Card(
                          color: AppColors.lightCard,
                          child: Padding(
                            padding: const EdgeInsets.all(AppTokens.md),
                            child: Column(
                              children: [
                                Text('Review Receipt Details', style: AppTypography.headlineMedium.copyWith(color: AppColors.white)),
                                const SizedBox(height: AppTokens.md),
                                _buildReviewField('Merchant Name', _merchantController),
                                const SizedBox(height: AppTokens.md),
                                _buildReviewField('Amount (₹)', _amountController),
                                const SizedBox(height: AppTokens.md),
                                _buildReviewField('Date', _dateController),
                                const SizedBox(height: AppTokens.lg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => setState(() {
                                          _image = null;
                                          _reviewing = false;
                                        }),
                                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.mutedText, side: const BorderSide(color: AppColors.mutedText)),
                                        child: const Text('Rescan'),
                                      ),
                                    ),
                                    const SizedBox(width: AppTokens.md),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _confirmTransaction,
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, foregroundColor: AppColors.white),
                                        child: const Text('Create Transaction'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.md),
                        Text('Review and confirm extracted details before saving', style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReviewField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd), borderSide: BorderSide.none),
            filled: true,
            fillColor: AppColors.darkSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
