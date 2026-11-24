import 'package:flutter/material.dart';

/// PINKLEDGER Modern Neo-Light Design System
/// Background: Crisp White (#FFFFFF)
/// Text: Pure Black (#000000)
/// Borders: Solid Black (#000000)
class AppColors {
  // ── Core Brand ─────────────────────────────────
  static const Color liteGreen      = Color(0xFF10B981);   // vibrant emerald
  static const Color mintGreen      = Color(0xFF34D399);   // soft mint
  static const Color emeraldGreen   = Color(0xFF059669);   // deep emerald
  static const Color primaryPink    = Color(0xFF10B981);   // aliased to green for theme compatibility
  static const Color deepPurple     = Color(0xFFFFFFFF);   // light mode scaffold

  // ── Backgrounds (Pure White & Light Slates) ─────
  static const Color bgPrimary      = Color(0xFFFFFFFF);   // pure white
  static const Color bgSecondary    = Color(0xFFF8FAFC);   // light slate surface
  static const Color cardBg         = Color(0xFFFFFFFF);   // white card surface
  static const Color cardElevated   = Color(0xFFF1F5F9);   // subtle elevated surface

  // ── Text (Pure Black & Dark Slate) ─────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);
  static const Color textPrimary    = Color(0xFF000000);   // pure black text
  static const Color textSecondary  = Color(0xFF475569);   // slate gray
  static const Color mutedText      = Color(0xFF64748B);   // muted slate

  // ── Borders (Crisp Black Borders) ──────────────
  static const Color borderBlack    = Color(0xFF000000);   // crisp black border
  static const Color borderLight    = Color(0xFFE2E8F0);   // subtle divider border

  // ── Status / Accents ───────────────────────────
  static const Color accentPink     = Color(0xFF10B981);
  static const Color successGreen   = Color(0xFF10B981);
  static const Color expenseRed     = Color(0xFFEF4444);   // vivid coral red
  static const Color savingsBlue    = Color(0xFF2563EB);   // royal blue
  static const Color warningOrange  = Color(0xFFF59E0B);   // amber

  // ── High-Contrast Chart Palette (Light Mode) ────
  static const List<Color> chartColors = [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Vivid Violet
    Color(0xFFF97316), // Bright Orange
    Color(0xFFEF4444), // Coral Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFFEC4899), // Hot Rose
  ];

  // ── Legacy Aliases ─────────────────────────────
  static const Color successLime       = successGreen;
  static const Color errorRed          = expenseRed;
  static const Color secondaryTeal     = successGreen;
  static const Color infoBlue          = savingsBlue;
  static const Color warningAmber      = warningOrange;
  static const Color softBackground    = bgPrimary;
  static const Color darkSurface       = cardBg;
  static const Color darkSurfaceVariant= cardElevated;
  static const Color darkCard          = cardBg;
  static const Color lightCard         = cardBg;
  static const Color lightSurface      = bgSecondary;
  static const Color lightSurfaceVariant = cardElevated;

  // ── Gradients ──────────────────────────────────
  static const LinearGradient greenGlow = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient pinkGlow = greenGlow;
  static const LinearGradient balanceCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient darkSurface2 = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

/// Design Tokens
class AppTokens {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 24.0;
  static const double radiusXxl  = 32.0;
  static const double radiusFull = 999.0;

  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  static const Duration durationFast   = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow   = Duration(milliseconds: 600);
  static const Duration durationXSlow  = Duration(milliseconds: 1000);
}

/// Typography Scale
class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w900,
    color: AppColors.textPrimary, letterSpacing: -1,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 26, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.normal,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle moneyLarge = TextStyle(
    fontSize: 38, fontWeight: FontWeight.w900,
    color: AppColors.textPrimary, letterSpacing: -1.5,
  );
  static const TextStyle moneyMedium = TextStyle(
    fontSize: 24, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, letterSpacing: -0.8,
  );
}

/// Modern Light Theme (White BG, Black Text, Black Borders)
class PinkLedgerTheme {
  static ThemeData lightTheme() => _buildTheme();
  static ThemeData darkTheme()  => _buildTheme(); // Force consistent clean light design

  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:      AppColors.black,
        onPrimary:    AppColors.white,
        secondary:    AppColors.liteGreen,
        onSecondary:  AppColors.white,
        surface:      AppColors.cardBg,
        onSurface:    AppColors.textPrimary,
        error:        AppColors.expenseRed,
        onError:      AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.borderBlack, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusLg)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderBlack, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderBlack, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
          side: const BorderSide(color: AppColors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.borderBlack, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0), thickness: 1, space: 1,
      ),
      textTheme: const TextTheme(
        displayLarge:  AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium:AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        bodyLarge:     AppTypography.bodyLarge,
        bodyMedium:    AppTypography.bodyMedium,
        bodySmall:     AppTypography.bodySmall,
        labelLarge:    AppTypography.labelLarge,
        labelMedium:   AppTypography.labelMedium,
        labelSmall:    AppTypography.labelSmall,
      ),
    );
  }
}
