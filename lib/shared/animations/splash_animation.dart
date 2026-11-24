import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pinkledger/core/constants/app_constants.dart';
import 'package:pinkledger/core/security/settings_service.dart';
import 'package:pinkledger/core/theme/app_theme.dart';

/// Mind-Blowing Cinematic PS2-3D + Cyber Comic Splash Screen
/// Visual Palette: Vibrant Lite Green (#10B981) + Pure Luminous White (#FFFFFF)
/// Optimized Timing: Fast, snappy, and responsive 1.8s total duration.
/// Shows full sequence from initialization (0%) to complete readiness (100%).
class AnimatedSplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const AnimatedSplashScreen({super.key, this.onComplete});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  // Master Animation Controllers
  late AnimationController _ambientCtrl;
  late AnimationController _rotationCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;

  final List<_StarParticle> _stars = [];
  bool _navigated = false;
  String _nextRoute = AppConstants.home;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initControllers();
    _loadSettingsTarget();
  }

  void _initParticles() {
    final rand = math.Random(42);
    for (int i = 0; i < 50; i++) {
      _stars.add(_StarParticle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        size: rand.nextDouble() * 3.0 + 1.2,
        speed: rand.nextDouble() * 0.5 + 0.2,
        opacity: rand.nextDouble() * 0.7 + 0.3,
        isGreen: rand.nextBool(),
      ));
    }
  }

  void _initControllers() {
    // Continuous 3D rotation
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Ambient lighting & cyber wave loop
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Pulse & Equalizer rhythm
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Fast, responsive progression from 0% to 100% in 1800ms (1.8s)
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressCtrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Hold victory frame for 150ms so user clearly sees 100% completed
        await Future.delayed(const Duration(milliseconds: 150));
        _proceed();
      }
    });

    _progressCtrl.forward();
  }

  Future<void> _loadSettingsTarget() async {
    try {
      final settings = SettingsService();
      final onboarding = await settings.getOnboardingCompleted();
      final hasPIN = await settings.getHasPIN();

      if (!onboarding) {
        _nextRoute = AppConstants.onboarding;
      } else if (hasPIN) {
        _nextRoute = AppConstants.pinVerify;
      } else {
        _nextRoute = AppConstants.home;
      }
    } catch (_) {
      _nextRoute = AppConstants.home;
    }
  }

  void _proceed() {
    if (_navigated || !mounted) return;
    _navigated = true;
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushReplacementNamed(_nextRoute);
    }
  }

  String _getStatusText(int pct) {
    if (pct < 22) return 'INITIALIZING 3D GRAPHICS PIPELINE...';
    if (pct < 48) return 'BOOTING PS2 MONOLITHS & SHIELD...';
    if (pct < 72) return 'CONNECTING DATABASE & HIVE BOXES...';
    if (pct < 96) return 'SYNCHRONIZING FINANCIAL ENGINES...';
    return 'SYSTEM READY • ALL MODULES ONLINE!';
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _rotationCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03140C), // Deep Emerald Space
      body: GestureDetector(
        onTap: _proceed, // Tap anywhere to skip instantly into the app
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _ambientCtrl,
            _rotationCtrl,
            _pulseCtrl,
            _progressCtrl,
          ]),
          builder: (context, _) {
            final t = _ambientCtrl.value;
            final rot = _rotationCtrl.value * 2 * math.pi;
            final pulse = _pulseCtrl.value;
            final progress = _progressCtrl.value;
            final pct = (progress * 100).toInt().clamp(0, 100);

            return Stack(
              children: [
                // 1. High-Contrast Deep Emerald + Neon Green Atmosphere
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.15),
                        radius: 1.1,
                        colors: [
                          Color(0xFF0A331E), // Vibrant Emerald Center Core
                          Color(0xFF04190E), // Deep Obsidian Green
                          Color(0xFF020B06), // Outer Space Black
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Perspective 3D Cyber Grid (Vibrant Lite Green vanishing lines)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CyberGrid3DPainter(
                      offset: t,
                      color: AppColors.liteGreen.withValues(alpha: 0.35),
                      horizonY: 0.65,
                    ),
                  ),
                ),

                // 3. PS2 Monolith 3D Pillars on the horizon
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PS2MonolithsPainter(
                      time: t,
                      color: AppColors.liteGreen,
                    ),
                  ),
                ),

                // 4. Volumetric Light Beams (God Rays)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VolumetricLightPainter(
                      angle: rot * 0.3,
                      color: AppColors.liteGreen.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                // 5. Floating Star Particles (White & Green)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _StarFieldPainter(
                      stars: _stars,
                      time: t,
                    ),
                  ),
                ),

                // 6. Radiant Ambient Neon Glow Aura
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.liteGreen.withValues(alpha: 0.28 * (0.8 + 0.2 * pulse)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 7. Center Stage: 3D Dual-Axis Rotating Emblem & Brand Identity
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Matrix Rotating Emblem
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Rotating Neon Emerald Ring
                          Transform.rotate(
                            angle: -rot * 0.6,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.liteGreen.withValues(alpha: 0.6),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.liteGreen.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Secondary Rotating Hexagon (White)
                          Transform.rotate(
                            angle: rot * 0.8,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // 3D Perspective Gyro Shield (Green + White Facet)
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0025) // 3D depth perspective
                              ..rotateX(math.sin(rot) * 0.35)
                              ..rotateY(math.cos(rot) * 0.48),
                            child: Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981), // Vibrant Lite Green
                                    Color(0xFF047857), // Deep Emerald
                                    Color(0xFF022C1B), // Dark Core
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.liteGreen.withValues(alpha: 0.7),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.shield_rounded,
                                  size: 56,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      // Comic High-Tech Badge (Green + White)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.liteGreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.liteGreen.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'FINANCIAL INTELLIGENCE • PS2 3D',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Brand Name (High-Contrast White with Emerald Rim)
                      const Text(
                        'PINKLEDGER',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: AppColors.liteGreen,
                              blurRadius: 20,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Tagline in Crisp White
                      const Text(
                        'YOUR MONEY. YOUR CONTROL.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track smarter • Spend better • Live better',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 8. PS2 Dynamic Audio Equalizer (Green + White Dancing Bars)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(16, (i) {
                          final wave = math.sin((t * 10) + (i * 0.45)).abs();
                          final barH = 5.0 + (wave * 26.0);
                          final isGreen = i % 2 == 0;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 5,
                            height: barH,
                            decoration: BoxDecoration(
                              color: isGreen ? AppColors.liteGreen : Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: (isGreen ? AppColors.liteGreen : Colors.white)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // 9. High-Tech Loader Bar with Live Percentage (Green + White)
                      Container(
                        width: 280,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF061A10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.liteGreen.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.liteGreen.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: const Color(0xFF031008),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Status Text & Live Percentage
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusText(pct),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.liteGreen,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$pct%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 10. Tap to Skip Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.liteGreen, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.liteGreen.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'TAP TO ENTER',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 11. Cyber Corner Brackets (White & Green)
                Positioned(
                  top: 24,
                  left: 24,
                  child: _buildCornerBracket(isTop: true, isLeft: true),
                ),
                Positioned(
                  top: 24,
                  right: 24,
                  child: _buildCornerBracket(isTop: true, isLeft: false),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: _buildCornerBracket(isTop: false, isLeft: true),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: _buildCornerBracket(isTop: false, isLeft: false),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.liteGreen, width: 2.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.liteGreen, width: 2.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom 3D & Cyber Painters
// ─────────────────────────────────────────────────────────────────────────────

class _StarParticle {
  double x, y, size, speed, opacity;
  bool isGreen;
  _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.isGreen,
  });
}

class _StarFieldPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double time;
  _StarFieldPainter({required this.stars, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final y = (s.y - s.speed * time) % 1.0;
      final x = (s.x + math.sin(time * 2 + s.y * 6) * 0.015) % 1.0;
      final paint = Paint()
        ..color = (s.isGreen ? AppColors.liteGreen : Colors.white)
            .withValues(alpha: s.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(Offset(x * size.width, y * size.height), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) => true;
}

class _CyberGrid3DPainter extends CustomPainter {
  final double offset;
  final Color color;
  final double horizonY;
  _CyberGrid3DPainter({
    required this.offset,
    required this.color,
    required this.horizonY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final hy = size.height * horizonY;
    final cx = size.width * 0.5;

    // Vanishing perspective rays
    for (int i = -12; i <= 12; i++) {
      final start = Offset(cx, hy);
      final endX = cx + (i * size.width * 0.14);
      final end = Offset(endX, size.height);
      canvas.drawLine(start, end, paint);
    }

    // Horizontal moving grid lines
    for (int j = 1; j <= 9; j++) {
      final progress = ((j / 9.0) + (offset * 0.4)) % 1.0;
      final y = hy + (progress * progress * (size.height - hy));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGrid3DPainter old) => true;
}

class _PS2MonolithsPainter extends CustomPainter {
  final double time;
  final Color color;
  _PS2MonolithsPainter({required this.time, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final hy = size.height * 0.65;
    final cx = size.width * 0.5;

    // 7 Monolith towers on the horizon with glowing green edges
    final heights = [140.0, 190.0, 240.0, 280.0, 230.0, 180.0, 130.0];
    final offsetsX = [-180.0, -120.0, -60.0, 0.0, 60.0, 120.0, 180.0];

    for (int i = 0; i < heights.length; i++) {
      final h = heights[i];
      final ox = cx + offsetsX[i];
      final w = 26.0;

      final rect = Rect.fromCenter(
        center: Offset(ox, hy - (h * 0.5)),
        width: w,
        height: h,
      );

      // Shaded translucent tower body
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.25),
            color.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);

      canvas.drawRect(rect, fillPaint);

      // Glowing Neon Green Edge
      final strokePaint = Paint()
        ..color = color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawRect(rect, strokePaint);

      // Luminous White Top Cap
      canvas.drawLine(
        Offset(ox - w * 0.5, hy - h),
        Offset(ox + w * 0.5, hy - h),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PS2MonolithsPainter old) => true;
}

class _VolumetricLightPainter extends CustomPainter {
  final double angle;
  final Color color;
  _VolumetricLightPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.38;

    final rayPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    const int rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final path = Path();
      const a = (2 * math.pi / rayCount);
      final rad = i * a;
      path.moveTo(0, 0);
      path.lineTo(math.cos(rad - 0.12) * 280, math.sin(rad - 0.12) * 280);
      path.lineTo(math.cos(rad + 0.12) * 280, math.sin(rad + 0.12) * 280);
      path.close();
      canvas.drawPath(path, rayPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VolumetricLightPainter old) => true;
}
