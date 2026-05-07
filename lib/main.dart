import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core services
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';

// Hive TypeAdapters
import 'features/tasks/data/task_model.dart';
import 'features/notes/data/note_model.dart';
import 'features/habits/data/habit_model.dart';
import 'features/expenses/data/expense_model.dart';
import 'features/allowance/data/allowance_model.dart';
import 'features/finance/data/finance_model.dart';
import 'features/bill_splitter/data/bill_split_model.dart';
import 'features/tuition/data/tuition_model.dart';
import 'features/academic_planner/data/academic_models.dart';
import 'features/academic_planner/data/syllabus_models.dart';
import 'features/grade_simulator/data/grade_models.dart';
import 'features/study_logger/data/study_session_model.dart';
import 'features/pomodoro/data/pomodoro_session_model.dart';
import 'features/weather/data/weather_model.dart';
import 'features/subscriptions/data/subscription_model.dart';
import 'features/bus_schedule/data/bus_route_model.dart';
import 'features/notice_board/data/notice_model.dart';
import 'features/load_shedding/data/load_shedding_model.dart';
import 'features/quick_capture/data/inbox_item_model.dart';
import 'features/health_log/data/health_log_model.dart';
import 'features/reading_list/data/reading_item_model.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  _registerAdapters();
  await HiveService.init();

  // Initialize notifications (timezone + channels)
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: LifeCliApp(),
    ),
  );
}

void _registerAdapters() {
  // Register all Hive TypeAdapters (skip if already registered)
  _register(TaskModelAdapter());
  _register(NoteModelAdapter());
  _register(HabitModelAdapter());
  _register(HabitLogModelAdapter());
  _register(ExpenseModelAdapter());
  _register(BudgetModelAdapter());
  _register(AllowanceModelAdapter());
  _register(FinanceModelAdapter());
  _register(BillSplitModelAdapter());
  _register(TuitionStudentModelAdapter());
  _register(TuitionSessionModelAdapter());
  _register(TuitionPaymentModelAdapter());
  _register(ClassEntryModelAdapter());
  _register(ExamModelAdapter());
  _register(AssignmentModelAdapter());
  _register(AttendanceRecordAdapter());
  _register(SyllabusTopicModelAdapter());
  _register(SyllabusCourseModelAdapter());
  _register(GradeComponentAdapter());
  _register(GradeCourseModelAdapter());
  _register(SemesterModelAdapter());
  _register(StudySessionModelAdapter());
  _register(PomodoroSessionModelAdapter());
  _register(WeatherModelAdapter());
  _register(SubscriptionModelAdapter());
  _register(BusRouteModelAdapter());
  _register(NoticeModelAdapter());
  _register(LoadSheddingSlotAdapter());
  _register(InboxItemModelAdapter());
  _register(HealthLogModelAdapter());
  _register(ReadingItemModelAdapter());
}

void _register<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) {
    Hive.registerAdapter(adapter);
  }
}
