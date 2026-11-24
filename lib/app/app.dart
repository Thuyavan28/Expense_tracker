import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/app/router.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/services/providers.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/features/dashboard/main_navigation_screen.dart';
import 'package:pinkledger/shared/animations/splash_animation.dart';

class PinkLedgerApp extends ConsumerStatefulWidget {
  const PinkLedgerApp({super.key});

  @override
  ConsumerState<PinkLedgerApp> createState() => _PinkLedgerAppState();
}

class _PinkLedgerAppState extends ConsumerState<PinkLedgerApp> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: PinkLedgerTheme.lightTheme(),
      darkTheme: PinkLedgerTheme.darkTheme(),
      themeMode: ref.watch(themeModeProvider),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _splashCompleted
            ? const MainNavigationScreen(key: ValueKey('main_nav'))
            : AnimatedSplashScreen(
                key: const ValueKey('splash'),
                onComplete: () {
                  if (mounted) setState(() => _splashCompleted = true);
                },
              ),
      ),
      onGenerateRoute: (settings) {
        if (!_splashCompleted) {
          return MaterialPageRoute(
            builder: (_) => AnimatedSplashScreen(
              onComplete: () {
                if (mounted) setState(() => _splashCompleted = true);
              },
            ),
          );
        }
        if (settings.name == AppConstants.splash) {
          return MaterialPageRoute(
            builder: (_) => AnimatedSplashScreen(
              onComplete: () {
                Navigator.of(context).pushReplacementNamed(AppConstants.home);
              },
            ),
          );
        }
        return AppRouter.onGenerateRoute(settings);
      },
    );
  }
}
