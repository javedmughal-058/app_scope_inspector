import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/scaling.dart';
import '../features/settings/presentation/providers/theme_provider.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import 'navigation/app_shell.dart';

class AppScopeApp extends StatefulWidget {
  const AppScopeApp({super.key});

  @override
  State<AppScopeApp> createState() => _AppScopeAppState();
}

class _AppScopeAppState extends State<AppScopeApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: _showSplash
          ? SplashPage(onComplete: () {
              if (!mounted) return;
              setState(() => _showSplash = false);
            })
          : const AppShell(),
    );
  }
}
