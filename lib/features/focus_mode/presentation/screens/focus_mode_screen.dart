import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../pomodoro/presentation/providers/pomodoro_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});
  @override ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> {
  int _quoteIndex = 0;
  final _subjectController = TextEditingController();
  int _customMinutes = 30;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _quoteIndex = DateTime.now().second % AppStrings.focusQuotes.length;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient orbs
            Positioned(top: -60, left: -60,
              child: Container(width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.12)))),
            Positioned(bottom: -80, right: -80,
              child: Container(width: 250, height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withOpacity(0.08)))),
            // Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text('Focus Mode 🎯', style: GoogleFonts.inter(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                          child: const Text('Exit', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Show idle configurator or timer
                if (state.phase == PomodoroPhase.idle)
                  Expanded(child: _IdleConfigurator(
                    state: state,
                    notifier: notifier,
                    subjectController: _subjectController,
                    customMinutes: _customMinutes,
                    onCustomMinutesChanged: (v) => setState(() => _customMinutes = v),
                  ))
                else ...[
                  const Spacer(),
                  // Timer
                  _FocusTimer(progress: state.progress, timeString: state.timeString, typeName: state.typeName),
                  const SizedBox(height: 16),
                  if (state.subject.isNotEmpty)
                    Text(state.subject, style: GoogleFonts.inter(color: Colors.white54, fontSize: 16)),
                  const Spacer(),
                  // Quote
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GestureDetector(
                      onTap: () => setState(() => _quoteIndex = (_quoteIndex + 1) % AppStrings.focusQuotes.length),
                      child: Text(
                        AppStrings.focusQuotes[_quoteIndex],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.phase == PomodoroPhase.running)
                        _FocusButton(
                          icon: Icons.pause,
                          label: 'Pause',
                          onTap: notifier.pause,
                          color: AppColors.warning,
                        )
                      else if (state.phase == PomodoroPhase.paused)
                        _FocusButton(
                          icon: Icons.play_arrow,
                          label: 'Resume',
                          onTap: notifier.resume,
                          color: AppColors.success,
                        )
                      else
                        _FocusButton(
                          icon: Icons.play_arrow,
                          label: 'Start',
                          onTap: notifier.start,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: 20),
                      _FocusButton(
                        icon: Icons.stop,
                        label: 'Cancel',
                        onTap: () { notifier.cancel(); context.pop(); },
                        color: Colors.white24,
                        outline: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Idle Configurator ─────────────────────────────────────────────────────────

class _IdleConfigurator extends StatelessWidget {
  final PomodoroState state;
  final PomodoroNotifier notifier;
  final TextEditingController subjectController;
  final int customMinutes;
  final ValueChanged<int> onCustomMinutesChanged;

  const _IdleConfigurator({
    required this.state,
    required this.notifier,
    required this.subjectController,
    required this.customMinutes,
    required this.onCustomMinutesChanged,
  });

  static const _sessionTypes = [
    _SessionType(index: 0, label: 'Pomodoro', duration: '25 min', icon: Icons.local_fire_department),
    _SessionType(index: 1, label: 'Short Break', duration: '5 min', icon: Icons.coffee_outlined),
    _SessionType(index: 2, label: 'Long Break', duration: '15 min', icon: Icons.self_improvement_outlined),
    _SessionType(index: 3, label: 'Custom', duration: 'Custom', icon: Icons.tune),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completed pomodoros badge
          _CompletedBadge(count: state.completedPomodoros),
          const SizedBox(height: 24),

          // Session type selector
          Text('Session Type', style: GoogleFonts.inter(
            color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5,
          )),
          const SizedBox(height: 12),
          _SessionTypeGrid(
            selectedIndex: state.typeIndex,
            sessionTypes: _sessionTypes,
            onSelect: (i) => notifier.selectType(i, customMinutes: 30),
          ),

          // Custom duration slider
          if (state.typeIndex == 3) ...[
            const SizedBox(height: 16),
            _CustomDurationCard(
              minutes: customMinutes,
              onChanged: (v) {
                onCustomMinutesChanged(v);
                notifier.selectType(3, customMinutes: v);
              },
            ),
          ],

          const SizedBox(height: 24),

          // Subject / task name
          Text('Task Name (optional)', style: GoogleFonts.inter(
            color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5,
          )),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: TextField(
              controller: subjectController,
              onChanged: notifier.setSubject,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'e.g. Study Physics Chapter 5…',
                hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 15),
                prefixIcon: const Icon(Icons.edit_outlined, color: Colors.white30, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Start button
          _StartButton(onTap: notifier.start),

          const SizedBox(height: 24),

          // Quote
          Center(
            child: Text(
              AppStrings.focusQuotes[DateTime.now().second % AppStrings.focusQuotes.length],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  final int count;
  const _CompletedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.15)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.local_fire_department, color: Color(0xFFFF6B35), size: 22),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today\'s Progress', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
          Text('$count pomodoro${count == 1 ? '' : 's'} completed',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const Spacer(),
        Row(children: List.generate(math.min(count, 8), (i) =>
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: i < count ? const Color(0xFFFF6B35) : Colors.white12,
                shape: BoxShape.circle,
              ),
            ),
          ),
        )),
      ]),
    );
  }
}

class _SessionType {
  final int index;
  final String label;
  final String duration;
  final IconData icon;
  const _SessionType({required this.index, required this.label, required this.duration, required this.icon});
}

class _SessionTypeGrid extends StatelessWidget {
  final int selectedIndex;
  final List<_SessionType> sessionTypes;
  final ValueChanged<int> onSelect;

  const _SessionTypeGrid({required this.selectedIndex, required this.sessionTypes, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: sessionTypes.map((t) {
        final selected = selectedIndex == t.index;
        return GestureDetector(
          onTap: () => onSelect(t.index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? LinearGradient(
                colors: [AppColors.primary.withOpacity(0.4), AppColors.primary.withOpacity(0.2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ) : null,
              color: selected ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary.withOpacity(0.7) : Colors.white.withOpacity(0.1),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected ? [
                BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, spreadRadius: 0),
              ] : null,
            ),
            child: Row(children: [
              Icon(t.icon, color: selected ? Colors.white : Colors.white38, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.label, style: GoogleFonts.inter(
                    color: selected ? Colors.white : Colors.white60,
                    fontSize: 13, fontWeight: FontWeight.w600,
                  )),
                  Text(t.duration, style: GoogleFonts.inter(
                    color: selected ? Colors.white60 : Colors.white30, fontSize: 11,
                  )),
                ],
              )),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _CustomDurationCard extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;
  const _CustomDurationCard({required this.minutes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Duration', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$minutes min', style: GoogleFonts.inter(
              color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.w700,
            )),
          ),
        ]),
        Slider(
          value: minutes.toDouble(),
          min: 5, max: 120, divisions: 23,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white10,
          label: '$minutes min',
          onChanged: (v) => onChanged(v.round()),
        ),
      ]),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Text('Start Focus Session', style: GoogleFonts.inter(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3,
          )),
        ]),
      ),
    );
  }
}

// ─── Timer widget ───────────────────────────────────────────────────────────────

class _FocusTimer extends StatelessWidget {
  final double progress;
  final String timeString;
  final String typeName;

  const _FocusTimer({required this.progress, required this.timeString, required this.typeName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260, height: 260,
      child: CustomPaint(
        painter: _FocusPainter(progress: progress),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(timeString, style: GoogleFonts.inter(
              fontSize: 60, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            Text(typeName, style: GoogleFonts.inter(fontSize: 16, color: Colors.white54)),
          ]),
        ),
      ),
    );
  }
}

class _FocusPainter extends CustomPainter {
  final double progress;
  const _FocusPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 12;
    canvas.drawCircle(c, r, Paint()..color = Colors.white12..strokeWidth = 8..style = PaintingStyle.stroke);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = AppColors.primaryLight..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
  }

  @override bool shouldRepaint(covariant _FocusPainter old) => old.progress != progress;
}

class _FocusButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outline;

  const _FocusButton({required this.icon, required this.label, required this.onTap, required this.color, this.outline = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: outline ? Colors.white30 : Colors.transparent, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: outline ? Colors.white54 : Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: outline ? Colors.white54 : Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      ]),
    ),
  );
}
