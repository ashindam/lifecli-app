import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';

/// Root app widget. Wired into [ProviderScope] by main.dart.
class LifeCliApp extends ConsumerWidget {
  const LifeCliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = AppRouter.build();

    return MaterialApp.router(
      title: 'LifeCLI',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,

      // Router
      routerConfig: router,
    );
  }
}
