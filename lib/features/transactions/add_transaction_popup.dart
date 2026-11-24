import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/database/account_model.dart';
import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/database/category_model.dart';
import 'package:pinkledger/core/database/category_repository.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// Full-Screen & Centered Transaction Dialog (Modern Light Mode with Black Borders)
class AddTransactionPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final String? initialType;
  final DateTime? initialDate;

  const AddTransactionPopup({
    super.key,
    required this.onSave,
    this.initialType,
    this.initialDate,
  });

  /// Opens the modal in an elegant, centered & responsive dialog
  static Future<void> show(
    BuildContext context, {
    required Function(Map<String, dynamic>) onSave,
    String? initialType,
    DateTime? initialDate,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Transaction',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: AddTransactionPopup(
              onSave: onSave,
              initialType: initialType,
              initialDate: initialDate,
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

  @override
  State<AddTransactionPopup> createState() => _AddTransactionPopupState();
}

class _AddTransactionPopupState extends State<AddTransactionPopup> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();

  late String _type;
  String _category = '';
  String _paymentMethod = 'Cash';
  late DateTime _date;
  final String _status = AppConstants.statusCompleted;
  String? _sourceAccountId;
  String? _destinationAccountId;

  List<CategoryModel> _categories = [];
  List<AccountModel> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? AppConstants.typeExpense;
    _date = widget.initialDate ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await CategoryRepository().getCategoriesByType(_type);
    final accounts = AppDatabase.accounts.values.toList();
    setState(() {
      _categories = categories;
      _accounts = accounts;
      if (categories.isNotEmpty && _category.isEmpty) {
        _category = categories.first.name;
      }
      _sourceAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      _loading = false;
    });
  }

  void _addQuickAmount(double val) {
    final cur = double.tryParse(_amountController.text) ?? 0.0;
    final total = cur + val;
    setState(() {
      _amountController.text = total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;

    return Container(
      width: isCompact ? size.width * 0.94 : 520,
      height: isCompact ? size.height * 0.90 : 680,
      constraints: const BoxConstraints(maxHeight: 720),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Bar
                      _buildHeader(context),

                      // Scrollable Form Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Type Selector (Expense | Income | Transfer)
                              _buildTypeSelector(),

                              const SizedBox(height: 18),

                              // Amount Hero Input Card
                              _buildAmountHero(),

                              const SizedBox(height: 12),

                              // Quick Amount Chips
                              _buildQuickChips(),

                              const SizedBox(height: 18),

                              // Category Picker
                              _buildCategorySelector(),

                              const SizedBox(height: 14),

                              // Date & Payment Method row
                              Row(
                                children: [
                                  Expanded(child: _buildDateTile(context)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildPaymentMethodDropdown()),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Description
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                hint: 'e.g. Grocery, Lunch, Coffee',
                                icon: Icons.edit_note_rounded,
                                isRequired: true,
                              ),

                              const SizedBox(height: 12),

                              // Merchant
                              _buildTextField(
                                controller: _merchantController,
                                label: 'Merchant / Place (Optional)',
                                hint: 'e.g. Starbucks, Amazon, Metro',
                                icon: Icons.storefront_rounded,
                              ),

                              // Transfer Account Selectors
                              if (_type == AppConstants.typeTransfer) ...[
                                const SizedBox(height: 14),
                                _buildTransferAccounts(),
                              ],

                              const SizedBox(height: 12),

                              // Notes
                              _buildTextField(
                                controller: _notesController,
                                label: 'Notes (Optional)',
                                hint: 'Extra details...',
                                icon: Icons.notes_rounded,
                                maxLines: 2,
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Action Buttons
                      _buildBottomActions(context),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'New Transaction',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Track spending or income in your ledger',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.black, size: 22),
            splashRadius: 20,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          _buildTypeTab(
            type: AppConstants.typeExpense,
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            activeColor: AppColors.expenseRed,
          ),
          _buildTypeTab(
            type: AppConstants.typeIncome,
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            activeColor: AppColors.liteGreen,
          ),
          _buildTypeTab(
            type: AppConstants.typeTransfer,
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
            activeColor: AppColors.savingsBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required String type,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            _category = '';
            _loadData();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 1.5,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'TRANSACTION AMOUNT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                AppConstants.currencySymbol,
                style: TextStyle(
                  color: AppColors.liteGreen,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final num = double.tryParse(v);
                      if (num == null || num <= 0) return 'Valid amount';
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    final chips = [100.0, 500.0, 1000.0, 2000.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: chips.map((val) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(
            label: Text('+₹${val.toStringAsFixed(0)}'),
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () => _addQuickAmount(val),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category.isNotEmpty ? _category : null,
              hint: const Text(
                'Select category',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              items: _categories.map((c) {
                return DropdownMenuItem<String>(
                  value: c.name,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: const Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) setState(() => _date = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('d MMM yyyy').format(_date),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _paymentMethod,
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              items: ['Cash', 'UPI / GPay', 'Bank Account', 'Credit Card', 'Wallet']
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          m,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _paymentMethod = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.black, size: 20),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: isRequired
              ? (v) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildTransferAccounts() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _sourceAccountId,
            dropdownColor: Colors.white,
            items: _accounts
                .map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _sourceAccountId = v),
            decoration: const InputDecoration(
              labelText: 'From Account',
              prefixIcon: Icon(Icons.outbox_rounded, color: AppColors.expenseRed, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _destinationAccountId,
            dropdownColor: Colors.white,
            items: _accounts
                .map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _destinationAccountId = v),
            decoration: const InputDecoration(
              labelText: 'To Account',
              prefixIcon: Icon(Icons.inbox_rounded, color: AppColors.liteGreen, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Save Transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.black, width: 1.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'type': _type,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'category': _category.isNotEmpty ? _category : 'General',
      'paymentMethod': _paymentMethod,
      'date': _date,
      'description': _descriptionController.text.trim(),
      'merchantName': _merchantController.text.trim().isEmpty ? null : _merchantController.text.trim(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      'tags': <String>[],
      'status': _status,
      'sourceAccountId': _sourceAccountId,
      'destinationAccountId': _destinationAccountId,
    });
    Navigator.of(context, rootNavigator: true).pop();
  }
}
