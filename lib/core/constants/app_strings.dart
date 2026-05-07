class AppStrings {
  AppStrings._();

  static const String appName = 'LifeCLI';
  static const String tagline = 'Your academic life, organized';

  // Currency
  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';

  // Universities
  static const List<String> universities = [
    'CUET',
    'BUET',
    'DU',
    'NSU',
    'BRAC University',
    'RUET',
    'KUET',
    'SUST',
    'JU',
    'Other',
  ];

  // Default city
  static const String defaultCity = 'Chittagong';

  // BD Mobile operators
  static const List<String> mobileOperators = [
    'Grameenphone',
    'Robi',
    'Banglalink',
    'Teletalk',
    'Airtel',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Meals',
    'Transport',
    'Mobile Recharge',
    'Books & Stationery',
    'Rent',
    'Utilities',
    'Entertainment',
    'Medical',
    'Tuition Materials',
    'Miscellaneous',
  ];

  // Expense category icons
  static const Map<String, String> expenseCategoryIcons = {
    'Meals': '🍽️',
    'Transport': '🚌',
    'Mobile Recharge': '📱',
    'Books & Stationery': '📚',
    'Rent': '🏠',
    'Utilities': '💡',
    'Entertainment': '🎬',
    'Medical': '💊',
    'Tuition Materials': '📝',
    'Miscellaneous': '📦',
  };

  // Onboarding
  static const List<String> onboardingTitles = [
    'Your academic life,\norganized',
    'Never miss a deadline\nor class',
    'Know where your\n৳ goes',
  ];
  static const List<String> onboardingSubtitles = [
    'Tasks, notes, habits and more — all in one place built for Bangladeshi university students.',
    'Class routines, exam countdowns, assignment tracker and attendance — stay ahead always.',
    'Track expenses in BDT, manage your allowance, split bills with friends.',
  ];

  // Days of week
  static const List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> weekDaysFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Motivational quotes for Focus Mode
  static const List<String> focusQuotes = [
    '"The secret of getting ahead is getting started." — Mark Twain',
    '"Don\'t watch the clock; do what it does. Keep going." — Sam Levenson',
    '"Success is the sum of small efforts, repeated day in and day out." — R. Collier',
    '"Focused, hard work is the real key to success." — John C. Maxwell',
    '"Concentrate all your thoughts upon the work in hand." — Alexander Graham Bell',
    '"Excellence is not a destination but a continuous journey." — Brian Tracy',
    '"The only way to do great work is to love what you do." — Steve Jobs',
    '"Work hard in silence, let your success be your noise." — Frank Ocean',
    '"Push yourself, because no one else is going to do it for you."',
    '"Great things never come from comfort zones."',
  ];
}
