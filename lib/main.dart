import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/app/app.dart';
import 'package:pinkledger/core/database/app_database.dart';
import 'package:pinkledger/core/security/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.init();
  await SettingsService().init();

  runApp(
    const ProviderScope(
      child: PinkLedgerApp(),
    ),
  );
}
