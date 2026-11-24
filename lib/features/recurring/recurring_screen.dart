import 'package:flutter/material.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(title: const Text('Recurring'), elevation: 0),
      body: const Center(
        child: Text('Recurring Transactions - Coming Soon', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}