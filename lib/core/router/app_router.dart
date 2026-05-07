import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifecli_app/core/services/google_auth_service.dart';
import 'package:lifecli_app/features/shell/presentation/main_shell.dart';
import 'package:lifecli_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:lifecli_app/features/auth/presentation/screens/login_screen.dart';
import 'package:lifecli_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:lifecli_app/features/auth/presentation/screens/photo_selection_screen.dart';
import 'package:lifecli_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:lifecli_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:lifecli_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:lifecli_app/features/more/presentation/screens/more_screen.dart';

// Academic screens
import 'package:lifecli_app/features/academic_planner/presentation/screens/academic_shell_screen.dart';
import 'package:lifecli_app/features/academic_planner/presentation/screens/class_routine_screen.dart';
import 'package:lifecli_app/features/academic_planner/presentation/screens/exam_calendar_screen.dart';
import 'package:lifecli_app/features/academic_planner/presentation/screens/assignments_screen.dart';
import 'package:lifecli_app/features/academic_planner/presentation/screens/attendance_screen.dart';
import 'package:lifecli_app/features/academic_planner/presentation/screens/syllabus_screen.dart';
import 'package:lifecli_app/features/grade_simulator/presentation/screens/grade_simulator_screen.dart';

// Finance screens
import 'package:lifecli_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:lifecli_app/features/allowance/presentation/screens/allowance_screen.dart';
import 'package:lifecli_app/features/finance/presentation/screens/finance_screen.dart';
import 'package:lifecli_app/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:lifecli_app/features/bill_splitter/presentation/screens/bill_splitter_screen.dart';
import 'package:lifecli_app/features/tuition/presentation/screens/tuition_screen.dart';

// Focus hub
import 'package:lifecli_app/features/focus/presentation/screens/focus_hub_screen.dart';

// Focus / productivity screens
import 'package:lifecli_app/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:lifecli_app/features/tasks/presentation/screens/add_task_screen.dart';
import 'package:lifecli_app/features/notes/presentation/screens/notes_screen.dart';
import 'package:lifecli_app/features/habits/presentation/screens/habits_screen.dart';
import 'package:lifecli_app/features/pomodoro/presentation/screens/pomodoro_screen.dart';
import 'package:lifecli_app/features/focus_mode/presentation/screens/focus_mode_screen.dart';
import 'package:lifecli_app/features/study_logger/presentation/screens/study_logger_screen.dart';
import 'package:lifecli_app/features/quick_capture/presentation/screens/quick_capture_screen.dart';
import 'package:lifecli_app/features/weekly_review/presentation/screens/weekly_review_screen.dart';
import 'package:lifecli_app/features/health_log/presentation/screens/health_log_screen.dart';
import 'package:lifecli_app/features/reading_list/presentation/screens/reading_list_screen.dart';
import 'package:lifecli_app/features/calculator/presentation/screens/calculator_screen.dart';

// Utility screens
import 'package:lifecli_app/features/weather/presentation/screens/weather_screen.dart';
import 'package:lifecli_app/features/bus_schedule/presentation/screens/bus_schedule_screen.dart';
import 'package:lifecli_app/features/notice_board/presentation/screens/notice_board_screen.dart';
import 'package:lifecli_app/features/load_shedding/presentation/screens/load_shedding_screen.dart';

// ─── Route name constants ──────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String signupPhoto = 'signup-photo';

  // Shell tabs
  static const String home = 'home';
  static const String academic = 'academic';
  static const String focus = 'focus';
  static const String more = 'more';

  // Academic sub-routes
  static const String classRoutine = 'class-routine';
  static const String examCalendar = 'exam-calendar';
  static const String assignments = 'assignments';
  static const String attendance = 'attendance';
  static const String syllabus = 'syllabus';
  static const String grades = 'grades';

  // Detail routes
  static const String tasks = 'tasks';
  static const String taskAdd = 'task-add';
  static const String taskDetail = 'task-detail';
  static const String notes = 'notes';
  static const String habits = 'habits';
  static const String pomodoro = 'pomodoro';
  static const String focusMode = 'focus-mode';
  static const String studyLogger = 'study-logger';
  static const String quickCapture = 'quick-capture';
  static const String weeklyReview = 'weekly-review';
  static const String healthLog = 'health-log';
  static const String readingList = 'reading-list';
  static const String calculator = 'calculator';
  static const String weather = 'weather';
  static const String expenses = 'expenses';
  static const String allowance = 'allowance';
  static const String finance = 'finance';
  static const String subscriptions = 'subscriptions';
  static const String billSplitter = 'bill-splitter';
  static const String tuition = 'tuition';
  static const String busSchedule = 'bus-schedule';
  static const String noticeBoard = 'notice-board';
  static const String loadShedding = 'load-shedding';
  static const String profile = 'profile';
  static const String settings = 'settings';
}

// ─── Navigator keys ────────────────────────────────────────────────────────

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// ─── Router ────────────────────────────────────────────────────────────────

class AppRouter {
  AppRouter._();

  static GoRouter build() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      debugLogDiagnostics: true,
      redirect: (BuildContext context, GoRouterState state) async {
        final prefs = await SharedPreferences.getInstance();
        final onboardingDone = prefs.getBool('onboarding_done') ?? false;
        final isSignedIn = GoogleAuthService.isSignedIn;

        final isOnboarding = state.matchedLocation == '/onboarding';
        final isLogin = state.matchedLocation == '/login';
        final isSignup = state.matchedLocation.startsWith('/signup');

        final isGuest = prefs.getBool('guest_mode') ?? false;

        if (!onboardingDone && !isOnboarding) return '/onboarding';
        if (onboardingDone && !isSignedIn && !isGuest && !isLogin && !isSignup) return '/login';
        if ((isSignedIn || isGuest) && isLogin) return '/home';
        return null;
      },
      routes: [
        // ── Standalone screens ──────────────────────────────────────────
        GoRoute(
          path: '/onboarding',
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: AppRoutes.signup,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/signup/photo',
          name: AppRoutes.signupPhoto,
          builder: (context, state) => PhotoSelectionScreen(
            data: state.extra as Map<String, dynamic>? ?? {},
          ),
        ),

        // ── Shell (bottom nav) ──────────────────────────────────────────
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            // Home / Dashboard
            GoRoute(
              path: '/home',
              name: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
            ),

            // Academic tab
            GoRoute(
              path: '/academic',
              name: AppRoutes.academic,
              pageBuilder: (context, state) => const NoTransitionPage(child: AcademicShellScreen()),
              routes: [
                GoRoute(path: 'routine', name: AppRoutes.classRoutine, builder: (_, __) => const ClassRoutineScreen()),
                GoRoute(path: 'exams', name: AppRoutes.examCalendar, builder: (_, __) => const ExamCalendarScreen()),
                GoRoute(path: 'assignments', name: AppRoutes.assignments, builder: (_, __) => const AssignmentsScreen()),
                GoRoute(path: 'attendance', name: AppRoutes.attendance, builder: (_, __) => const AttendanceScreen()),
                GoRoute(path: 'syllabus', name: AppRoutes.syllabus, builder: (_, __) => const SyllabusScreen()),
                GoRoute(path: 'grades', name: AppRoutes.grades, builder: (_, __) => const GradeSimulatorScreen()),
              ],
            ),

            // Finance tab
            GoRoute(
              path: '/finance',
              name: AppRoutes.finance,
              pageBuilder: (context, state) => const NoTransitionPage(child: FinanceScreen()),
            ),

            // Focus tab
            GoRoute(
              path: '/focus',
              name: AppRoutes.focus,
              pageBuilder: (context, state) => const NoTransitionPage(child: FocusHubScreen()),
            ),

            // More tab
            GoRoute(
              path: '/more',
              name: AppRoutes.more,
              pageBuilder: (context, state) => const NoTransitionPage(child: MoreScreen()),
            ),
          ],
        ),

        // ── Full-screen detail routes (outside shell) ───────────────────
        GoRoute(path: '/tasks', name: AppRoutes.tasks, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const TasksScreen()),
        GoRoute(path: '/tasks/add', name: AppRoutes.taskAdd, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const AddTaskScreen()),
        GoRoute(
          path: '/tasks/:id',
          name: AppRoutes.taskDetail,
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return _PlaceholderScreen(title: 'Task $id');
          },
        ),
        GoRoute(path: '/notes', name: AppRoutes.notes, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const NotesScreen()),
        GoRoute(path: '/habits', name: AppRoutes.habits, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const HabitsScreen()),
        GoRoute(path: '/pomodoro', name: AppRoutes.pomodoro, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const PomodoroScreen()),
        GoRoute(path: '/focus-mode', name: AppRoutes.focusMode, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const FocusModeScreen()),
        GoRoute(path: '/study-logger', name: AppRoutes.studyLogger, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const StudyLoggerScreen()),
        GoRoute(path: '/quick-capture', name: AppRoutes.quickCapture, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const QuickCaptureScreen()),
        GoRoute(path: '/weekly-review', name: AppRoutes.weeklyReview, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const WeeklyReviewScreen()),
        GoRoute(path: '/health-log', name: AppRoutes.healthLog, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const HealthLogScreen()),
        GoRoute(path: '/reading-list', name: AppRoutes.readingList, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const ReadingListScreen()),
        GoRoute(path: '/calculator', name: AppRoutes.calculator, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const CalculatorScreen()),
        GoRoute(path: '/weather', name: AppRoutes.weather, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const WeatherScreen()),
        GoRoute(path: '/expenses', name: AppRoutes.expenses, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const ExpensesScreen()),
        GoRoute(path: '/allowance', name: AppRoutes.allowance, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const AllowanceScreen()),
        GoRoute(path: '/subscriptions', name: AppRoutes.subscriptions, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const SubscriptionsScreen()),
        GoRoute(path: '/bill-splitter', name: AppRoutes.billSplitter, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const BillSplitterScreen()),
        GoRoute(path: '/tuition', name: AppRoutes.tuition, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const TuitionScreen()),
        GoRoute(path: '/bus-schedule', name: AppRoutes.busSchedule, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const BusScheduleScreen()),
        GoRoute(path: '/notice-board', name: AppRoutes.noticeBoard, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const NoticeBoardScreen()),
        GoRoute(path: '/load-shedding', name: AppRoutes.loadShedding, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const LoadSheddingScreen()),
        // Convenience aliases (used by MoreScreen)
        GoRoute(path: '/grades', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const GradeSimulatorScreen()),
        GoRoute(path: '/study-log', parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const StudyLoggerScreen()),
        GoRoute(path: '/profile', name: AppRoutes.profile, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/settings', name: AppRoutes.settings, parentNavigatorKey: rootNavigatorKey, builder: (_, __) => const SettingsScreen()),
      ],
    );
  }
}

// ─── Placeholder (for any screens not yet implemented) ─────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
  );
}
