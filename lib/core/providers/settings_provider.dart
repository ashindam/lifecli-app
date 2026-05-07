import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

class AppSettings {
  final bool isDarkMode;
  final bool themeFollowsSystem;
  final String defaultCity;
  final String university;
  final bool notificationsEnabled;
  final String habitReminderTime; // HH:mm
  final bool weeklyReviewEnabled;
  final String studyGoalHours; // weekly

  const AppSettings({
    this.isDarkMode = false,
    this.themeFollowsSystem = true,
    this.defaultCity = 'Chittagong',
    this.university = 'CUET',
    this.notificationsEnabled = true,
    this.habitReminderTime = '21:00',
    this.weeklyReviewEnabled = true,
    this.studyGoalHours = '20',
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? themeFollowsSystem,
    String? defaultCity,
    String? university,
    bool? notificationsEnabled,
    String? habitReminderTime,
    bool? weeklyReviewEnabled,
    String? studyGoalHours,
  }) => AppSettings(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    themeFollowsSystem: themeFollowsSystem ?? this.themeFollowsSystem,
    defaultCity: defaultCity ?? this.defaultCity,
    university: university ?? this.university,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    habitReminderTime: habitReminderTime ?? this.habitReminderTime,
    weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
    studyGoalHours: studyGoalHours ?? this.studyGoalHours,
  );

  ThemeMode get themeMode {
    if (themeFollowsSystem) return ThemeMode.system;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'themeFollowsSystem': themeFollowsSystem,
    'defaultCity': defaultCity,
    'university': university,
    'notificationsEnabled': notificationsEnabled,
    'habitReminderTime': habitReminderTime,
    'weeklyReviewEnabled': weeklyReviewEnabled,
    'studyGoalHours': studyGoalHours,
  };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] as bool? ?? false,
    themeFollowsSystem: json['themeFollowsSystem'] as bool? ?? true,
    defaultCity: json['defaultCity'] as String? ?? 'Chittagong',
    university: json['university'] as String? ?? 'CUET',
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    habitReminderTime: json['habitReminderTime'] as String? ?? '21:00',
    weeklyReviewEnabled: json['weeklyReviewEnabled'] as bool? ?? true,
    studyGoalHours: json['studyGoalHours'] as String? ?? '20',
  );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  static const _key = 'app_settings';

  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final raw = HiveService.settings.get(_key);
    if (raw != null) {
      state = AppSettings.fromJson(raw as Map);
    }
  }

  Future<void> _save() async {
    await HiveService.settings.put(_key, state.toJson());
  }

  Future<void> setThemeMode({required bool followSystem, required bool isDark}) async {
    state = state.copyWith(themeFollowsSystem: followSystem, isDarkMode: isDark);
    await _save();
  }

  Future<void> setCity(String city) async {
    state = state.copyWith(defaultCity: city);
    await _save();
  }

  Future<void> setUniversity(String uni) async {
    state = state.copyWith(university: uni);
    await _save();
  }

  Future<void> setNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _save();
  }

  Future<void> setHabitReminderTime(String time) async {
    state = state.copyWith(habitReminderTime: time);
    await _save();
  }

  Future<void> setWeeklyReview(bool enabled) async {
    state = state.copyWith(weeklyReviewEnabled: enabled);
    await _save();
  }

  Future<void> setStudyGoal(String hours) async {
    state = state.copyWith(studyGoalHours: hours);
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
