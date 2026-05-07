import 'package:hive_flutter/hive_flutter.dart';

// Hive type IDs (0-49 reserved for core app models)
class HiveTypeIds {
  static const int task = 0;
  static const int note = 1;
  static const int habit = 2;
  static const int habitLog = 3;
  static const int expense = 4;
  static const int budget = 5;
  static const int allowance = 6;
  static const int financeRecord = 7;
  static const int billSplit = 8;
  static const int tuitionStudent = 9;
  static const int tuitionSession = 10;
  static const int tuitionPayment = 11;
  static const int classEntry = 12;
  static const int examEntry = 13;
  static const int assignment = 14;
  static const int attendanceRecord = 15;
  static const int syllabusTopicItem = 16;
  static const int syllabusCourse = 17;
  static const int gradeComponent = 18;
  static const int gradeCourse = 19;
  static const int semesterRecord = 20;
  static const int studySession = 21;
  static const int pomodoroSession = 22;
  static const int weatherCache = 23;
  static const int subscription = 24;
  static const int busRoute = 25;
  static const int noticeItem = 26;
  static const int loadSheddingSlot = 27;
  static const int inboxItem = 28;
  static const int weeklyReview = 29;
  static const int healthLog = 30;
  static const int readingItem = 31;
  static const int appSettings = 40;
  static const int userProfile = 41;
}

class HiveService {
  static const String _settingsBox = 'settings';
  static const String _profileBox = 'profile';
  static const String _tasksBox = 'tasks';
  static const String _notesBox = 'notes';
  static const String _habitsBox = 'habits';
  static const String _habitLogsBox = 'habit_logs';
  static const String _expensesBox = 'expenses';
  static const String _budgetsBox = 'budgets';
  static const String _allowanceBox = 'allowance';
  static const String _financeBox = 'finance';
  static const String _billSplitsBox = 'bill_splits';
  static const String _tuitionStudentsBox = 'tuition_students';
  static const String _tuitionSessionsBox = 'tuition_sessions';
  static const String _tuitionPaymentsBox = 'tuition_payments';
  static const String _classRoutineBox = 'class_routine';
  static const String _examsBox = 'exams';
  static const String _assignmentsBox = 'assignments';
  static const String _attendanceBox = 'attendance';
  static const String _syllabusCoursesBox = 'syllabus_courses';
  static const String _gradeCoursesBox = 'grade_courses';
  static const String _semestersBox = 'semesters';
  static const String _studySessionsBox = 'study_sessions';
  static const String _pomodoroSessionsBox = 'pomodoro_sessions';
  static const String _weatherBox = 'weather';
  static const String _subscriptionsBox = 'subscriptions';
  static const String _busRoutesBox = 'bus_routes';
  static const String _noticesBox = 'notices';
  static const String _loadSheddingBox = 'load_shedding';
  static const String _inboxBox = 'inbox';
  static const String _weeklyReviewBox = 'weekly_reviews';
  static const String _healthLogsBox = 'health_logs';
  static const String _readingBox = 'reading';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapters registered in main.dart after codegen
    await _openAllBoxes();
  }

  static Future<void> _openAllBoxes() async {
    await Future.wait([
      Hive.openBox(_settingsBox),
      Hive.openBox(_profileBox),
      Hive.openBox(_tasksBox),
      Hive.openBox(_notesBox),
      Hive.openBox(_habitsBox),
      Hive.openBox(_habitLogsBox),
      Hive.openBox(_expensesBox),
      Hive.openBox(_budgetsBox),
      Hive.openBox(_allowanceBox),
      Hive.openBox(_financeBox),
      Hive.openBox(_billSplitsBox),
      Hive.openBox(_tuitionStudentsBox),
      Hive.openBox(_tuitionSessionsBox),
      Hive.openBox(_tuitionPaymentsBox),
      Hive.openBox(_classRoutineBox),
      Hive.openBox(_examsBox),
      Hive.openBox(_assignmentsBox),
      Hive.openBox(_attendanceBox),
      Hive.openBox(_syllabusCoursesBox),
      Hive.openBox(_gradeCoursesBox),
      Hive.openBox(_semestersBox),
      Hive.openBox(_studySessionsBox),
      Hive.openBox(_pomodoroSessionsBox),
      Hive.openBox(_weatherBox),
      Hive.openBox(_subscriptionsBox),
      Hive.openBox(_busRoutesBox),
      Hive.openBox(_noticesBox),
      Hive.openBox(_loadSheddingBox),
      Hive.openBox(_inboxBox),
      Hive.openBox(_weeklyReviewBox),
      Hive.openBox(_healthLogsBox),
      Hive.openBox(_readingBox),
    ]);
  }

  static Box get settings => Hive.box(_settingsBox);
  static Box get profile => Hive.box(_profileBox);
  static Box get tasks => Hive.box(_tasksBox);
  static Box get notes => Hive.box(_notesBox);
  static Box get habits => Hive.box(_habitsBox);
  static Box get habitLogs => Hive.box(_habitLogsBox);
  static Box get expenses => Hive.box(_expensesBox);
  static Box get budgets => Hive.box(_budgetsBox);
  static Box get allowance => Hive.box(_allowanceBox);
  static Box get finance => Hive.box(_financeBox);
  static Box get billSplits => Hive.box(_billSplitsBox);
  static Box get tuitionStudents => Hive.box(_tuitionStudentsBox);
  static Box get tuitionSessions => Hive.box(_tuitionSessionsBox);
  static Box get tuitionPayments => Hive.box(_tuitionPaymentsBox);
  static Box get classRoutine => Hive.box(_classRoutineBox);
  static Box get exams => Hive.box(_examsBox);
  static Box get assignments => Hive.box(_assignmentsBox);
  static Box get attendance => Hive.box(_attendanceBox);
  static Box get syllabusCourses => Hive.box(_syllabusCoursesBox);
  static Box get gradeCourses => Hive.box(_gradeCoursesBox);
  static Box get semesters => Hive.box(_semestersBox);
  static Box get studySessions => Hive.box(_studySessionsBox);
  static Box get pomodoroSessions => Hive.box(_pomodoroSessionsBox);
  static Box get weather => Hive.box(_weatherBox);
  static Box get subscriptions => Hive.box(_subscriptionsBox);
  static Box get busRoutes => Hive.box(_busRoutesBox);
  static Box get notices => Hive.box(_noticesBox);
  static Box get loadShedding => Hive.box(_loadSheddingBox);
  static Box get inbox => Hive.box(_inboxBox);
  static Box get weeklyReviews => Hive.box(_weeklyReviewBox);
  static Box get healthLogs => Hive.box(_healthLogsBox);
  static Box get reading => Hive.box(_readingBox);

  static Future<void> clearAll() async {
    await Future.wait([
      settings.clear(),
      profile.clear(),
      tasks.clear(),
      notes.clear(),
      habits.clear(),
      habitLogs.clear(),
      expenses.clear(),
      budgets.clear(),
      allowance.clear(),
      finance.clear(),
      billSplits.clear(),
      tuitionStudents.clear(),
      tuitionSessions.clear(),
      tuitionPayments.clear(),
      classRoutine.clear(),
      exams.clear(),
      assignments.clear(),
      attendance.clear(),
      syllabusCourses.clear(),
      gradeCourses.clear(),
      semesters.clear(),
      studySessions.clear(),
      pomodoroSessions.clear(),
      weather.clear(),
      subscriptions.clear(),
      busRoutes.clear(),
      notices.clear(),
      loadShedding.clear(),
      inbox.clear(),
      weeklyReviews.clear(),
      healthLogs.clear(),
      reading.clear(),
    ]);
  }
}
