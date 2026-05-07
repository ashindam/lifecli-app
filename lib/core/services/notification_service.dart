import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String _taskChannel = 'tasks';
  static const String _habitChannel = 'habits';
  static const String _classChannel = 'classes';
  static const String _examChannel = 'exams';
  static const String _financeChannel = 'finance';
  static const String _pomodoroChannel = 'pomodoro';
  static const String _loadSheddingChannel = 'load_shedding';
  static const String _weeklyChannel = 'weekly_review';
  static const String _busChannel = 'bus';

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    final channels = [
      const AndroidNotificationChannel(_taskChannel, 'Task Reminders',
          description: 'Reminders for tasks and deadlines',
          importance: Importance.high),
      const AndroidNotificationChannel(_habitChannel, 'Habit Check-ins',
          description: 'Daily habit reminder notifications',
          importance: Importance.defaultImportance),
      const AndroidNotificationChannel(_classChannel, 'Class Alerts',
          description: 'Upcoming class notifications',
          importance: Importance.high),
      const AndroidNotificationChannel(_examChannel, 'Exam Reminders',
          description: 'Exam countdown and day-of reminders',
          importance: Importance.max),
      const AndroidNotificationChannel(_financeChannel, 'Finance Reminders',
          description: 'Loan due dates and bill reminders',
          importance: Importance.defaultImportance),
      const AndroidNotificationChannel(_pomodoroChannel, 'Pomodoro Timer',
          description: 'Pomodoro session completion alerts',
          importance: Importance.high),
      const AndroidNotificationChannel(_loadSheddingChannel, 'Load Shedding',
          description: 'Upcoming load shedding alerts',
          importance: Importance.high),
      const AndroidNotificationChannel(_weeklyChannel, 'Weekly Review',
          description: 'Sunday weekly review reminder',
          importance: Importance.defaultImportance),
      const AndroidNotificationChannel(_busChannel, 'Bus Schedule',
          description: 'University bus departure reminders',
          importance: Importance.high),
    ];

    for (final ch in channels) {
      await android.createNotificationChannel(ch);
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Router navigation will be handled via a global navigator key
  }

  // --- Public scheduling methods ---

  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime when,
  }) => _scheduleNotification(
        id: id,
        channelId: _taskChannel,
        title: '📋 Task Reminder',
        body: title,
        scheduledDate: when,
        payload: 'task:$id',
      );

  static Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required DateTime dailyTime,
  }) => _scheduleDailyNotification(
        id: id,
        channelId: _habitChannel,
        title: '💪 Habit Check-in',
        body: "Don't forget: $habitName",
        payload: 'habit:$id',
      );

  static Future<void> scheduleClassReminder({
    required int id,
    required String courseName,
    required String room,
    required DateTime classTime,
  }) => _scheduleNotification(
        id: id,
        channelId: _classChannel,
        title: '📚 Class in 15 minutes',
        body: '$courseName — Room $room',
        scheduledDate: classTime.subtract(const Duration(minutes: 15)),
        payload: 'class:$id',
      );

  static Future<void> scheduleExamReminder({
    required int id,
    required String courseName,
    required DateTime examDate,
    required int daysBeforeAlert,
  }) => _scheduleNotification(
        id: id * 10 + daysBeforeAlert,
        channelId: _examChannel,
        title: daysBeforeAlert == 0 ? '🚨 Exam Today!' : '📝 Exam in $daysBeforeAlert day${daysBeforeAlert == 1 ? '' : 's'}',
        body: '$courseName exam',
        scheduledDate: daysBeforeAlert == 0
            ? DateTime(examDate.year, examDate.month, examDate.day, 7, 0)
            : examDate.subtract(Duration(days: daysBeforeAlert)),
        payload: 'exam:$id',
      );

  static Future<void> scheduleFinanceReminder({
    required int id,
    required String name,
    required int amountPaisa,
    required DateTime dueDate,
  }) => _scheduleNotification(
        id: id,
        channelId: _financeChannel,
        title: '💸 Payment Due Today',
        body: 'Pay ৳${amountPaisa ~/ 100} to/for $name',
        scheduledDate: DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0),
        payload: 'finance:$id',
      );

  static Future<void> schedulePomodoroComplete({
    required int id,
    required String sessionType,
  }) => _showImmediateNotification(
        id: id,
        channelId: _pomodoroChannel,
        title: '⏰ $sessionType Complete!',
        body: sessionType == 'Pomodoro' ? 'Great work! Time for a break.' : 'Break over. Back to focus!',
        payload: 'pomodoro',
      );

  static Future<void> scheduleLoadSheddingAlert({
    required int id,
    required String area,
    required DateTime startTime,
  }) => _scheduleNotification(
        id: id,
        channelId: _loadSheddingChannel,
        title: '💡 Load Shedding in 10 minutes',
        body: 'Save your work! Power cut at ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
        scheduledDate: startTime.subtract(const Duration(minutes: 10)),
        payload: 'loadshedding:$id',
      );

  static Future<void> scheduleWeeklyReview() async {
    final now = DateTime.now();
    // Next Sunday at 8 PM
    final daysUntilSunday = (7 - now.weekday) % 7;
    var nextSunday = DateTime(now.year, now.month, now.day + daysUntilSunday, 20, 0);
    if (nextSunday.isBefore(now)) nextSunday = nextSunday.add(const Duration(days: 7));

    await _scheduleNotification(
      id: 9999,
      channelId: _weeklyChannel,
      title: '📊 Weekly Review Time!',
      body: 'How was your week? Check your progress.',
      scheduledDate: nextSunday,
      payload: 'weekly_review',
    );
  }

  static Future<void> scheduleBusReminder({
    required int id,
    required String routeName,
    required DateTime departure,
    required int minutesBefore,
  }) => _scheduleNotification(
        id: id,
        channelId: _busChannel,
        title: '🚌 Bus leaves in $minutesBefore minutes',
        body: routeName,
        scheduledDate: departure.subtract(Duration(minutes: minutesBefore)),
        payload: 'bus:$id',
      );

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // --- Internal helpers ---

  static Future<void> _scheduleNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId, channelId,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      await _plugin.periodicallyShowWithDuration(
        id, title, body,
        const Duration(days: 1),
        NotificationDetails(
          android: AndroidNotificationDetails(channelId, channelId),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('Daily notification error: $e');
    }
  }

  static Future<void> _showImmediateNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    await _plugin.show(
      id, title, body,
      NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelId,
            importance: Importance.high, priority: Priority.high),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
