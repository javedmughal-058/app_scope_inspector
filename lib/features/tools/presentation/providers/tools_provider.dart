import 'package:flutter/foundation.dart';

import '../../../apps/domain/usecases/app_use_cases.dart';

class ToolsProvider extends ChangeNotifier {
  ToolsProvider({
    required CheckAppInstalledUseCase checkInstalled,
    required CheckSystemAppUseCase checkSystem,
    required StartAppUseCase startApp,
    required OpenAppSettingsUseCase openSettings,
    required ShowToastUseCase showToast,
    required FilterInstalledAppsUseCase filterApps,
  })  : _checkInstalled = checkInstalled,
        _checkSystem = checkSystem,
        _startApp = startApp,
        _openSettings = openSettings,
        _showToast = showToast,
        _filterApps = filterApps;

  final CheckAppInstalledUseCase _checkInstalled;
  final CheckSystemAppUseCase _checkSystem;
  final StartAppUseCase _startApp;
  final OpenAppSettingsUseCase _openSettings;
  final ShowToastUseCase _showToast;
  final FilterInstalledAppsUseCase _filterApps;

  bool _busy = false;
  String? _result;
  bool get busy => _busy;
  String? get result => _result;

  Future<void> checkInstalled(String packageName) => _run(() async {
        final value = await _checkInstalled(packageName);
        return value == true ? 'App is installed.' : value == false ? 'App is not installed.' : 'Unable to determine installation status.';
      });

  Future<void> checkSystem(String packageName) => _run(() async {
        final value = await _checkSystem(packageName);
        return value == true ? 'This is a system app.' : value == false ? 'This is a user app.' : 'Unable to determine app type.';
      });

  Future<void> launch(String packageName) => _run(() async {
        final value = await _startApp(packageName);
        return value == true ? 'Launch request sent.' : 'Unable to launch this app.';
      });

  Future<void> openSettings(String packageName) => _run(() async {
        await _openSettings(packageName);
        return 'Opening app settings.';
      });

  Future<void> toast(String message) => _run(() async {
        await _showToast(message, short: true);
        return 'Toast sent.';
      });

  Future<void> filterByPrefix(String prefix) => _run(() async {
        final apps = await _filterApps(packageNamePrefix: prefix.trim().isEmpty ? null : prefix.trim());
        return '${apps.length} apps matched the package prefix.';
      });

  Future<void> filterByPlatform(String? slug) => _run(() async {
        final apps = await _filterApps(platformTypeSlug: slug);
        return '${apps.length} apps matched the selected platform.';
      });

  Future<void> _run(Future<String> Function() action) async {
    if (_busy) return;
    _busy = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } catch (_) {
      _result = 'Something went wrong.';
    }
    _busy = false;
    notifyListeners();
  }
}
