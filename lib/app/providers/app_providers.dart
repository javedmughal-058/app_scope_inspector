import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/apps/data/datasources/installed_apps_data_source.dart';
import '../../features/apps/data/repositories/installed_apps_repository_impl.dart';
import '../../features/apps/domain/repositories/installed_apps_repository.dart';
import '../../features/apps/domain/usecases/app_use_cases.dart';
import '../../features/apps/presentation/providers/app_filter_provider.dart';
import '../../features/apps/presentation/providers/installed_apps_provider.dart';
import '../../features/settings/presentation/providers/theme_provider.dart';
import '../../features/tools/presentation/providers/tools_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.preferences,
    required this.child,
  });

  final SharedPreferences preferences;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dataSource = InstalledAppsDataSourceImpl();
    final repository = InstalledAppsRepositoryImpl(dataSource);

    final getInstalledApps = GetInstalledAppsUseCase(repository);
    final getAppInfo = GetAppInfoUseCase(repository);
    final getAppIcon = GetAppIconUseCase(repository);
    final startApp = StartAppUseCase(repository);
    final openSettings = OpenAppSettingsUseCase(repository);
    final checkInstalled = CheckAppInstalledUseCase(repository);
    final checkSystem = CheckSystemAppUseCase(repository);
    final uninstallApp = UninstallAppUseCase(repository);
    final showToast = ShowToastUseCase(repository);
    final filterApps = FilterInstalledAppsUseCase(repository);

    return MultiProvider(
      providers: [
        Provider<InstalledAppsRepository>.value(value: repository),
        Provider<GetInstalledAppsUseCase>.value(value: getInstalledApps),
        Provider<GetAppInfoUseCase>.value(value: getAppInfo),
        Provider<GetAppIconUseCase>.value(value: getAppIcon),
        Provider<StartAppUseCase>.value(value: startApp),
        Provider<OpenAppSettingsUseCase>.value(value: openSettings),
        Provider<CheckAppInstalledUseCase>.value(value: checkInstalled),
        Provider<CheckSystemAppUseCase>.value(value: checkSystem),
        Provider<UninstallAppUseCase>.value(value: uninstallApp),
        Provider<ShowToastUseCase>.value(value: showToast),
        Provider<FilterInstalledAppsUseCase>.value(value: filterApps),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(preferences: preferences),
        ),
        ChangeNotifierProvider(create: (_) => AppFilterProvider()),
        ChangeNotifierProvider(
          create: (_) => InstalledAppsProvider(
            getInstalledApps: getInstalledApps,
            getAppIcon: getAppIcon,
          )..loadApps(),
        ),
        ChangeNotifierProvider(
          create: (_) => ToolsProvider(
            checkInstalled: checkInstalled,
            checkSystem: checkSystem,
            startApp: startApp,
            openSettings: openSettings,
            showToast: showToast,
            filterApps: filterApps,
          ),
        ),
      ],
      child: child,
    );
  }
}
