import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pomodoro_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Timer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 16),
          // Type selector tabs
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _TypeTab(label: 'Pomodoro\n25m', index: 0, selected: state.typeIndex,
                  onTap: () => notifier.selectType(0)),
                _TypeTab(label: 'Short\n5m', index: 1, selected: state.typeIndex,
                  onTap: () => notifier.selectType(1)),
                _TypeTab(label: 'Long\n15m', index: 2, selected: state.typeIndex,
                  onTap: () => notifier.selectType(2)),
                _TypeTab(label: 'Custom', index: 3, selected: state.typeIndex,
                  onTap: () => _showCustomDialog(context, ref)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Circular timer
          Center(
            child: _CircularTimer(
              progress: state.progress,
              timeString: state.timeString,
              typeName: state.typeName,
              isRunning: state.phase == PomodoroPhase.running,
            ),
          ),
          const SizedBox(height: 32),
          // Subject field
          TextField(
            onChanged: notifier.setSubject,
            decoration: const InputDecoration(
              labelText: 'What are you studying?',
              hintText: 'e.g. Physics Chapter 5',
              prefixIcon: Icon(Icons.book_outlined),
            ),
          ),
          const SizedBox(height: 28),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.phase == PomodoroPhase.running || state.phase == PomodoroPhase.paused)
                OutlinedButton.icon(
                  onPressed: notifier.cancel,
                  icon: const Icon(Icons.stop, color: AppColors.error),
                  label: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                ),
              const SizedBox(width: 16),
              _MainButton(state: state, notifier: notifier),
            ],
          ),
          const SizedBox(height: 24),
          // Pomodoro dots (4 = 1 set)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Container(
              width: 14, height: 14, margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < (state.completedPomodoros % 4)
                    ? AppColors.primary : AppColors.primaryContainer,
              ),
            )),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${state.completedPomodoros} pomodoro${state.completedPomodoros == 1 ? '' : 's'} today',
              style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          if (state.phase == PomodoroPhase.running) ...[
            const SizedBox(height: 24),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/focus-mode'),
                icon: const Icon(Icons.fullscreen),
                label: const Text('Enter Focus Mode'),
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Today's session log
          if (state.todaySessions.isNotEmpty) ...[
            Text('Today\'s Sessions',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...state.todaySessions.reversed.map((s) => ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: s.type == 0 ? AppColors.primaryContainer : AppColors.successContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(s.type == 0 ? '🍅' : '☕', style: const TextStyle(fontSize: 18))),
              ),
              title: Text(s.typeName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text(s.subject.isNotEmpty ? s.subject : 'No subject'),
              trailing: Text('${s.durationMinutes}m',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.primary)),
              contentPadding: EdgeInsets.zero,
            )),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    int minutes = 30;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Custom Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes minutes', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
              Slider(
                value: minutes.toDouble(), min: 5, max: 90, divisions: 17,
                label: '$minutes min',
                onChanged: (v) => setSt(() => minutes = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ref.read(pomodoroProvider.notifier).selectType(3, customMinutes: minutes);
                Navigator.pop(ctx);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final VoidCallback onTap;

  const _TypeTab({required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label, textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularTimer extends StatelessWidget {
  final double progress;
  final String timeString;
  final String typeName;
  final bool isRunning;

  const _CircularTimer({
    required this.progress, required this.timeString,
    required this.typeName, required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, height: 240,
      child: CustomPaint(
        painter: _TimerPainter(progress: progress, isRunning: isRunning),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(timeString, style: GoogleFonts.inter(
                fontSize: 52, fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              const SizedBox(height: 4),
              Text(typeName, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  const _TimerPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final trackPaint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = isRunning ? AppColors.primary : AppColors.primaryLight
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress,
      false, progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter old) => old.progress != progress || old.isRunning != isRunning;
}

class _MainButton extends ConsumerWidget {
  final PomodoroState state;
  final PomodoroNotifier notifier;
  const _MainButton({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = state.phase == PomodoroPhase.running;
    final isPaused = state.phase == PomodoroPhase.paused;
    final isIdle = state.phase == PomodoroPhase.idle;
    final isDone = state.phase == PomodoroPhase.completed;

    return FilledButton.icon(
      onPressed: () {
        if (isIdle || isDone) { notifier.start(); if (isDone) notifier.reset(); }
        else if (isRunning) notifier.pause();
        else if (isPaused) notifier.resume();
      },
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 24),
      label: Text(
        isRunning ? 'Pause' : isPaused ? 'Resume' : isDone ? 'Done! Start Again' : 'Start',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: isRunning ? AppColors.warning : AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
