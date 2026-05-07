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
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await GoogleAuthService.signIn();
      if (account != null) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF0F0FF),
                    Colors.white,
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  height: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // App logo
                      _AppLogo(),

                      const SizedBox(height: 20),

                      // Tagline
                      Text(
                        'Your academic life, organized',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Sub-tagline
                      Text(
                        'For Bangladeshi university students',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 2),

                      // Illustration area
                      _LoginIllustration(),

                      const Spacer(flex: 2),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Google Sign-In button
                      _GoogleSignInButton(
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _signInWithGoogle,
                      ),

                      const SizedBox(height: 12),

                      // Guest mode button
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('guest_mode', true);
                          if (mounted) context.go('/home');
                        },
                        child: Text(
                          'Continue without signing in →',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Offline note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Works fully offline — sync when connected',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── App logo ─────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon mark
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3730A3), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'LC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Wordmark with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF3730A3), Color(0xFF6366F1)],
          ).createShader(bounds),
          child: Text(
            'LifeCLI',
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Login illustration ────────────────────────────────────────────────────

class _LoginIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer,
            AppColors.primaryContainer.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FeatureChip(icon: Icons.check_circle_outline, label: 'Tasks'),
          _FeatureChip(icon: Icons.school_outlined, label: 'Academic'),
          _FeatureChip(icon: Icons.account_balance_wallet_outlined, label: '৳ Finance'),
          _FeatureChip(icon: Icons.timer_outlined, label: 'Focus'),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Google Sign-In button ─────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFDDE1E7), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.08),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" logo
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CustomPaint(
                      painter: _GoogleLogoPainter(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign in with Google',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
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

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);

    // Simplified G logo using arcs
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    final strokeW = r * 0.28;

    // Blue arc (right side)
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

    // Horizontal bar for "G"
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
