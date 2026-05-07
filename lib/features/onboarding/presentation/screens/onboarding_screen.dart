import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lifecli_app/core/constants/app_colors.dart';
import 'package:lifecli_app/core/constants/app_strings.dart';

// ─── Slide data ────────────────────────────────────────────────────────────

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final String emoji;
}

const List<_OnboardingSlide> _slides = [
  _OnboardingSlide(
    title: 'Your academic life,\norganized',
    subtitle:
        'Tasks, notes, habits and more — all in one place built for Bangladeshi university students.',
    gradientColors: [Color(0xFF3730A3), Color(0xFF6366F1), Color(0xFF818CF8)],
    icon: Icons.auto_awesome_rounded,
    emoji: '🎓',
  ),
  _OnboardingSlide(
    title: 'Never miss a deadline\nor class',
    subtitle:
        'Class routines, exam countdowns, assignment tracker and attendance — stay ahead always.',
    gradientColors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    icon: Icons.calendar_month_rounded,
    emoji: '📅',
  ),
  _OnboardingSlide(
    title: 'Know where your\n৳ goes',
    subtitle:
        'Track expenses in BDT, manage your allowance, split bills with friends.',
    gradientColors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    icon: Icons.account_balance_wallet_rounded,
    emoji: '💰',
  ),
];

// ─── Screen ────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/login');
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _skip() => _complete();

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _OnboardingPage(slide: _slides[index]);
            },
          ),

          // Skip button
          if (!isLastPage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.85),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _slides.length,
              isLastPage: isLastPage,
              onNext: _next,
              slideColors: _slides[_currentPage].gradientColors,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Onboarding page ───────────────────────────────────────────────────────

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.slide});
  final _OnboardingSlide slide;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.slide.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Illustration area
            Expanded(
              flex: 5,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: _IllustrationPlaceholder(
                    slide: widget.slide,
                    size: size.width * 0.65,
                  ),
                ),
              ),
            ),

            // Text area
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.slide.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.slide.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.82),
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spacer for bottom controls
            SizedBox(height: size.height * 0.18),
          ],
        ),
      ),
    );
  }
}

// ─── Illustration placeholder ──────────────────────────────────────────────

class _IllustrationPlaceholder extends StatefulWidget {
  const _IllustrationPlaceholder({
    required this.slide,
    required this.size,
  });
  final _OnboardingSlide slide;
  final double size;

  @override
  State<_IllustrationPlaceholder> createState() =>
      _IllustrationPlaceholderState();
}

class _IllustrationPlaceholderState extends State<_IllustrationPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulse.value,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.slide.emoji,
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 12),
            Icon(
              widget.slide.icon,
              size: 48,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom controls ───────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.onNext,
    required this.slideColors,
  });

  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback onNext;
  final List<Color> slideColors;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(32, 20, 32, bottomPad + 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            slideColors.last.withOpacity(0.85),
            slideColors.last,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Next / Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: slideColors.first,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                isLastPage ? 'Get Started 🚀' : 'Next →',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
