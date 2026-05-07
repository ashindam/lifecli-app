import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/pomodoro_session_model.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/notification_service.dart';

enum PomodoroPhase { idle, running, paused, completed }

class PomodoroState {
  final PomodoroPhase phase;
  final int typeIndex; // 0=work,1=shortBreak,2=longBreak,3=custom
  final int totalSeconds;
  final int remainingSeconds;
  final String subject;
  final String customLabel;
  final List<PomodoroSessionModel> todaySessions;
  final int completedPomodoros; // count of work sessions today

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.typeIndex = 0,
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.subject = '',
    this.customLabel = '',
    this.todaySessions = const [],
    this.completedPomodoros = 0,
  });

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? typeIndex,
    int? totalSeconds,
    int? remainingSeconds,
    String? subject,
    String? customLabel,
    List<PomodoroSessionModel>? todaySessions,
    int? completedPomodoros,
  }) => PomodoroState(
    phase: phase ?? this.phase,
    typeIndex: typeIndex ?? this.typeIndex,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    subject: subject ?? this.subject,
    customLabel: customLabel ?? this.customLabel,
    todaySessions: todaySessions ?? this.todaySessions,
    completedPomodoros: completedPomodoros ?? this.completedPomodoros,
  );

  double get progress => 1 - (remainingSeconds / totalSeconds);

  String get timeString {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get typeName {
    switch (typeIndex) {
      case 0: return 'Pomodoro';
      case 1: return 'Short Break';
      case 2: return 'Long Break';
      case 3: return customLabel.isNotEmpty ? customLabel : 'Custom';
      default: return 'Pomodoro';
    }
  }

  static int defaultSecondsForType(int type, {int customMinutes = 30}) {
    switch (type) {
      case 0: return 25 * 60;
      case 1: return 5 * 60;
      case 2: return 15 * 60;
      case 3: return customMinutes * 60;
      default: return 25 * 60;
    }
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroNotifier() : super(const PomodoroState()) {
    _loadTodaySessions();
  }

  void _loadTodaySessions() {
    final today = DateTime.now();
    final sessions = HiveService.pomodoroSessions.values
        .whereType<PomodoroSessionModel>()
        .where((s) {
      final d = s.completedAt;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    final workCount = sessions.where((s) => s.type == 0).length;
    state = state.copyWith(todaySessions: sessions, completedPomodoros: workCount);
  }

  void selectType(int typeIndex, {int customMinutes = 30}) {
    if (state.phase == PomodoroPhase.running) return;
    final secs = PomodoroState.defaultSecondsForType(typeIndex, customMinutes: customMinutes);
    state = state.copyWith(
      typeIndex: typeIndex,
      totalSeconds: secs,
      remainingSeconds: secs,
      phase: PomodoroPhase.idle,
    );
  }

  void setSubject(String subject) => state = state.copyWith(subject: subject);

  void start() {
    if (state.phase == PomodoroPhase.running) return;
    state = state.copyWith(phase: PomodoroPhase.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(phase: PomodoroPhase.paused);
  }

  void resume() => start();

  void cancel() {
    _timer?.cancel();
    final secs = PomodoroState.defaultSecondsForType(state.typeIndex);
    state = state.copyWith(
      phase: PomodoroPhase.idle,
      remainingSeconds: secs,
      totalSeconds: secs,
    );
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _complete();
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }

  Future<void> _complete() async {
    _timer?.cancel();
    state = state.copyWith(phase: PomodoroPhase.completed, remainingSeconds: 0);

    // Log session
    final session = PomodoroSessionModel(
      type: state.typeIndex,
      durationMinutes: state.totalSeconds ~/ 60,
      subject: state.subject,
      completedAt: DateTime.now(),
      label: state.customLabel,
    );
    await HiveService.pomodoroSessions.put(session.id, session);

    // Notification
    await NotificationService.schedulePomodoroComplete(
      id: session.hashCode,
      sessionType: state.typeName,
    );

    final updated = [...state.todaySessions, session];
    state = state.copyWith(
      todaySessions: updated,
      completedPomodoros: state.typeIndex == 0
          ? state.completedPomodoros + 1
          : state.completedPomodoros,
    );
  }

  void reset() {
    final secs = PomodoroState.defaultSecondsForType(state.typeIndex);
    state = state.copyWith(
      phase: PomodoroPhase.idle,
      remainingSeconds: secs,
      totalSeconds: secs,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);
