import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifecli_app/core/constants/app_colors.dart';
import 'package:lifecli_app/core/services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;

  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Orb pulse animations
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;

  late Animation<double> _orb1Scale;
  late Animation<double> _orb1Opacity;
  late Animation<double> _orb2Scale;
  late Animation<double> _orb2Opacity;
  late Animation<double> _orb3Scale;
  late Animation<double> _orb3Opacity;

  @override
  void initState() {
    super.initState();

    // Entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeInOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Orb 1 — purple, top-left
    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _orb1Scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut),
    );
    _orb1Opacity = Tween<double>(begin: 0.22, end: 0.38).animate(
      CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut),
    );

    // Orb 2 — teal, top-right
    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _orb2Scale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut),
    );
    _orb2Opacity = Tween<double>(begin: 0.14, end: 0.28).animate(
      CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut),
    );

    // Orb 3 — blue, bottom-center
    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _orb3Scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut),
    );
    _orb3Opacity = Tween<double>(begin: 0.10, end: 0.22).animate(
      CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await GoogleAuthService.signIn();
      if (user != null) {
        if (mounted) context.go('/home');
      } else {
        setState(() {
          _errorMessage = 'Sign-in was cancelled. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Animated orb: top-left purple ──────────────────────────────
          Positioned(
            top: -60,
            left: -60,
            child: AnimatedBuilder(
              animation: _orb1Controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _orb1Opacity.value,
                  child: Transform.scale(
                    scale: _orb1Scale.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6366F1),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Animated orb: top-right teal ────────────────────────────────
          Positioned(
            top: -40,
            right: -60,
            child: AnimatedBuilder(
              animation: _orb2Controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _orb2Opacity.value,
                  child: Transform.scale(
                    scale: _orb2Scale.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF14B8A6),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Animated orb: bottom-center blue ────────────────────────────
          Positioned(
            bottom: -80,
            left: size.width / 2 - 125,
            child: AnimatedBuilder(
              animation: _orb3Controller,
              builder: (context, _) {
                return Opacity(
                  opacity: _orb3Opacity.value,
                  child: Transform.scale(
                    scale: _orb3Scale.value,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3B82F6),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Main content ────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: _GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          _LogoMark(),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'LifeCLI',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            'Your academic life, organized',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white60,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Feature pills row
                          _FeaturePillsRow(),
                          const SizedBox(height: 28),

                          // Error message
                          if (_errorMessage != null) ...[
                            _ErrorBanner(message: _errorMessage!),
                            const SizedBox(height: 16),
                          ],

                          // Google Sign-In button
                          _GlassGoogleButton(
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _signInWithGoogle,
                          ),
                          const SizedBox(height: 14),

                          // Guest mode
                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('guest_mode', true);
                              if (mounted) context.go('/home');
                            },
                            child: Text(
                              'Continue without signing in →',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Offline note
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded,
                                  size: 13, color: Colors.white30),
                              const SizedBox(width: 5),
                              Text(
                                'Works fully offline — sync when connected',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glassmorphism card ────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Logo mark (LC with gradient) ─────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'LC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Feature pills row ─────────────────────────────────────────────────────

class _FeaturePillsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const pills = [
      ('📋', 'Tasks'),
      ('📚', 'Academic'),
      ('💰', 'Finance'),
      ('🎯', 'Focus'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: pills.map((p) => _FeaturePill(emoji: p.$1, label: p.$2)).toList(),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error banner ──────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Glassmorphism Google Sign-In button ───────────────────────────────────

class _GlassGoogleButton extends StatelessWidget {
  const _GlassGoogleButton({
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CustomPaint(painter: _GoogleLogoPainter()),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Google logo painter ───────────────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final strokeW = r * 0.28;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
      -0.3,
      1.0,
      false,
      arcPaint,
    );

    arcPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
      0.7,
      0.85,
      false,
      arcPaint,
    );

    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
      1.55,
      0.85,
      false,
      arcPaint,
    );

    arcPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.65),
      2.4,
      1.0,
      false,
      arcPaint,
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(cx, cy - strokeW / 2),
      Offset(cx + r * 0.65, cy - strokeW / 2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
