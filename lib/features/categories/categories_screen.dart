import 'package:flutter/material.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedType = 'expense';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = 'expense'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == 'expense' ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: _selectedType == 'expense' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = 'income'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == 'income' ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: _selectedType == 'income' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selectedType == 'expense' ? 14 : 6,
              itemBuilder: (context, index) {
                final name = _selectedType == 'expense'
                    ? [
                        'Food and Dining',
                        'Groceries',
                        'Transportation',
                        'Shopping',
                        'Entertainment',
                        'Education',
                        'Healthcare',
                        'Rent',
                        'Utilities',
                        'Travel',
                        'Subscriptions',
                        'Personal Care',
                        'Insurance',
                        'Others'
                      ][index]
                    : ['Salary', 'Freelance', 'Business', 'Investment Returns', 'Gifts', 'Other Income'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.liteGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: const Icon(Icons.category_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.black54),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
