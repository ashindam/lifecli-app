import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: ListView(
        children: [
          _GroupHeader('🎨 Appearance'),
          SwitchListTile(
            title: const Text('Follow System Theme'),
            subtitle: const Text('Use your device\'s dark/light setting'),
            value: settings.themeFollowsSystem,
            onChanged: (v) => notifier.setThemeMode(followSystem: v, isDark: settings.isDarkMode),
            activeColor: AppColors.primary,
          ),
          if (!settings.themeFollowsSystem) SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (v) => notifier.setThemeMode(followSystem: false, isDark: v),
            activeColor: AppColors.primary,
          ),
          const Divider(indent: 16, endIndent: 16),
          _GroupHeader('🎓 Academic'),
          ListTile(
            title: const Text('University'),
            subtitle: Text(settings.university),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPickerDialog(
              context, 'University', AppStrings.universities, settings.university,
              (v) => notifier.setUniversity(v),
            ),
          ),
          ListTile(
            title: const Text('Default City (Weather)'),
            subtitle: Text(settings.defaultCity),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTextDialog(context, 'Default City', settings.defaultCity, notifier.setCity),
          ),
          const Divider(indent: 16, endIndent: 16),
          _GroupHeader('🔔 Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settings.notificationsEnabled,
            onChanged: notifier.setNotifications,
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Weekly Review Reminder'),
            subtitle: const Text('Every Sunday evening'),
            value: settings.weeklyReviewEnabled,
            onChanged: notifier.setWeeklyReview,
            activeColor: AppColors.primary,
          ),
          ListTile(
            title: const Text('Habit Reminder Time'),
            subtitle: Text(settings.habitReminderTime),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final parts = settings.habitReminderTime.split(':');
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
              );
              if (picked != null) {
                notifier.setHabitReminderTime('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
              }
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _GroupHeader('📖 Study Goal'),
          ListTile(
            title: const Text('Weekly Study Goal'),
            subtitle: Text('${settings.studyGoalHours} hours/week'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTextDialog(context, 'Weekly Study Goal (hours)', settings.studyGoalHours, notifier.setStudyGoal),
          ),
          const Divider(indent: 16, endIndent: 16),
          _GroupHeader('ℹ️ About'),
          ListTile(title: const Text('App Version'), subtitle: const Text('1.0.0')),
          ListTile(
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showPickerDialog(BuildContext context, String title, List<String> options, String current, ValueChanged<String> onSelect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300, height: 400,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (ctx, i) => ListTile(
              title: Text(options[i]),
              trailing: options[i] == current ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { onSelect(options[i]); Navigator.pop(ctx); },
            ),
          ),
        ),
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String current, ValueChanged<String> onSave) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () { onSave(ctrl.text.trim()); Navigator.pop(context); }, child: const Text('Save')),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String text;
  const _GroupHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
  );
}
