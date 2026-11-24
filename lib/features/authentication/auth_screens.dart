import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/security/settings_service.dart';
import 'package:pinkledger/core/services/providers.dart';
import 'package:pinkledger/core/theme/app_theme.dart';
import 'package:pinkledger/shared/animations/splash_animation.dart';

// ── Splash ───────────────────────────────────────────────────────────────────

class SplashRouteWidget extends StatelessWidget {
  const SplashRouteWidget({super.key});

  @override
  Widget build(BuildContext context) => const AnimatedSplashScreen();
}

// ── Onboarding ───────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  int _page = 0;
  late PageController _pageCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _OnboardPage(
      icon: Icons.insights_rounded,
      title: 'Understand\nYour Money',
      desc: 'Track every rupee. Get a crystal-clear picture of your financial health in real time.',
      color: AppColors.primaryPink,
    ),
    _OnboardPage(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Control\nYour Spending',
      desc: 'Set smart budgets, categorise expenses, and stay on top of every bill.',
      color: AppColors.savingsBlue,
    ),
    _OnboardPage(
      icon: Icons.savings_rounded,
      title: 'Reach Your\nFinancial Goals',
      desc: 'Create savings goals, plan for the future, and watch your wealth grow.',
      color: AppColors.successGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl  = PageController();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(_fadeCtrl);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SettingsService().setOnboardingCompleted(true);
    if (mounted) Navigator.of(context).pushReplacementNamed(AppConstants.home);
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Skip
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) {
                    setState(() => _page = i);
                    _fadeCtrl.forward(from: 0);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? p.color : AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_page < _pages.length - 1) {
                            _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finish();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          ),
                        ),
                        child: Text(
                          _page < _pages.length - 1 ? 'Continue' : "Let's Go!",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.color.withValues(alpha: 0.1),
              border: Border.all(color: p.color.withValues(alpha: 0.3), width: 2),
              boxShadow: [BoxShadow(
                color: p.color.withValues(alpha: 0.3),
                blurRadius: 40, spreadRadius: 5,
              )],
            ),
            child: Icon(p.icon, size: 56, color: p.color),
          ),
          const SizedBox(height: 48),
          Text(p.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, height: 1.1, letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(p.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16, color: AppColors.textSecondary, height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _OnboardPage({required this.icon, required this.title, required this.desc, required this.color});
}

// ── Login ─────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true, _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ref.read(authStateProvider.notifier).state = true;
      await SettingsService().setIsAuthenticated(true);
      Navigator.of(context).pushReplacementNamed(AppConstants.home);
    }
  }

  Future<void> _guestMode() async {
    ref.read(guestModeProvider.notifier).state = true;
    Navigator.of(context).pushReplacementNamed(AppConstants.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A0A1E), Color(0xFF1A0514)],
                    ),
                    boxShadow: [BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.4),
                      blurRadius: 24, spreadRadius: 2,
                    )],
                    border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.6), width: 2),
                  ),
                  child: const Icon(Icons.account_balance_wallet, size: 40, color: AppColors.primaryPink),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Welcome\nBack', style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary, height: 1.1,
              )),
              const SizedBox(height: 8),
              const Text('Sign in to your financial universe', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 15,
              )),
              const SizedBox(height: 40),

              // Email
              _PremiumField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              // Password
              _PremiumField(
                controller: _passCtrl, label: 'Password', icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppConstants.forgotPassword),
                  child: const Text('Forgot password?', style: TextStyle(color: AppColors.primaryPink)),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              _GradientButton(
                label: _loading ? 'Signing in...' : 'Sign In',
                loading: _loading,
                onTap: _loading ? null : _login,
              ),
              const SizedBox(height: 16),

              // Guest mode
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline, size: 20),
                  label: const Text('Continue as Guest'),
                  onPressed: _guestMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFF2A2A36)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppConstants.register),
                    child: const Text('Sign Up', style: TextStyle(
                      color: AppColors.primaryPink, fontWeight: FontWeight.bold,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Register ──────────────────────────────────────────────────────────────────

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ref.read(authStateProvider.notifier).state = true;
      await SettingsService().setIsAuthenticated(true);
      Navigator.of(context).pushReplacementNamed(AppConstants.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create\nAccount', style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, height: 1.1,
            )),
            const SizedBox(height: 8),
            const Text('Join your financial universe', style: TextStyle(
              color: AppColors.textSecondary, fontSize: 15,
            )),
            const SizedBox(height: 40),
            _PremiumField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _PremiumField(controller: _passCtrl, label: 'Password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 16),
            _PremiumField(controller: _confirmCtrl, label: 'Confirm Password', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 32),
            _GradientButton(
              label: _loading ? 'Creating Account...' : 'Create Account',
              loading: _loading,
              onTap: _loading ? null : _register,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Forgot Password ───────────────────────────────────────────────────────────

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reset\nPassword', style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w900,
              color: AppColors.textPrimary, height: 1.1,
            )),
            const SizedBox(height: 8),
            const Text('Enter your email to receive a reset link', style: TextStyle(
              color: AppColors.textSecondary, fontSize: 15,
            )),
            const SizedBox(height: 40),
            if (!_sent) ...[
              _PremiumField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              _GradientButton(
                label: 'Send Reset Link',
                onTap: () => setState(() => _sent = true),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.successGreen),
                    SizedBox(width: 12),
                    Expanded(child: Text('Reset link sent! Check your email.',
                      style: TextStyle(color: AppColors.successGreen))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GradientButton(label: 'Back to Login', onTap: () => Navigator.pop(context)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── PIN Setup ─────────────────────────────────────────────────────────────────

class PINSetupScreen extends ConsumerStatefulWidget {
  const PINSetupScreen({super.key});

  @override
  ConsumerState<PINSetupScreen> createState() => _PINSetupScreenState();
}

class _PINSetupScreenState extends ConsumerState<PINSetupScreen> {
  String _pin = '', _confirmPin = '';
  bool _confirming = false;

  void _onDigit(String d) {
    setState(() {
      if (!_confirming) {
        if (_pin.length < 4) _pin += d;
        if (_pin.length == 4) { _confirming = true; }
      } else {
        if (_confirmPin.length < 4) _confirmPin += d;
        if (_confirmPin.length == 4) _savePIN();
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_confirming) {
        if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _savePIN() async {
    if (_pin == _confirmPin) {
      await SettingsService().savePIN(_pin);
      await SettingsService().setHasPIN(true);
      if (mounted) Navigator.of(context).pushReplacementNamed(AppConstants.home);
    } else {
      setState(() { _pin = ''; _confirmPin = ''; _confirming = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match'), backgroundColor: AppColors.expenseRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirmPin : _pin;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              _confirming ? 'Confirm Your PIN' : 'Set Up PIN Lock',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _confirming ? 'Re-enter your 4-digit PIN' : 'Create a 4-digit PIN for security',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current.length ? AppColors.primaryPink : AppColors.cardElevated,
                  border: Border.all(
                    color: i < current.length ? AppColors.primaryPink : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 48),
            // Keypad
            Expanded(child: _buildKeypad()),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((d) {
                  if (d.isEmpty) return const SizedBox(width: 72, height: 72);
                  return GestureDetector(
                    onTap: () => d == '⌫' ? _onDelete() : _onDigit(d),
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBg,
                        border: Border.all(color: AppColors.cardElevated),
                      ),
                      child: Center(
                        child: Text(d, style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                        )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── PIN Verify ────────────────────────────────────────────────────────────────

class PINVerifyScreen extends ConsumerStatefulWidget {
  const PINVerifyScreen({super.key});

  @override
  ConsumerState<PINVerifyScreen> createState() => _PINVerifyScreenState();
}

class _PINVerifyScreenState extends ConsumerState<PINVerifyScreen> {
  String _pin = '';
  bool _error = false;

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() { _pin += d; _error = false; });
    if (_pin.length == 4) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() { _pin = _pin.substring(0, _pin.length - 1); _error = false; });
  }

  Future<void> _verify() async {
    final saved = await SettingsService().getPIN();
    if (_pin == saved) {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppConstants.home);
    } else {
      setState(() { _pin = ''; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPink.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.4), width: 2),
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.primaryPink, size: 36),
            ),
            const SizedBox(height: 24),
            const Text('Enter Your PIN', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            if (_error)
              const Text('Incorrect PIN. Try again.', style: TextStyle(color: AppColors.expenseRed))
            else
              const Text('Enter your 4-digit PIN to continue',
                  style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length
                      ? (_error ? AppColors.expenseRed : AppColors.primaryPink)
                      : AppColors.cardElevated,
                ),
              )),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: row.map((d) {
                            if (d.isEmpty) return const SizedBox(width: 72, height: 72);
                            return GestureDetector(
                              onTap: () => d == '⌫' ? _onDelete() : _onDigit(d),
                              child: Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cardBg,
                                  border: Border.all(color: AppColors.cardElevated),
                                ),
                                child: Center(child: Text(d, style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                                ))),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _PremiumField({
    required this.controller, required this.label, required this.icon,
    this.obscure = false, this.keyboardType, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _GradientButton({required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          gradient: const LinearGradient(
            colors: [AppColors.primaryPink, Color(0xFFAA2070)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.4),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Center(
          child: loading
            ? const SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
