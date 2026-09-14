import 'package:flutter/foundation.dart';

import '../../domain/entities/device_app.dart';
import '../../domain/usecases/app_use_cases.dart';

class AppDetailsProvider extends ChangeNotifier {
  AppDetailsProvider({
    required GetAppInfoUseCase getAppInfo,
    required StartAppUseCase startApp,
    required OpenAppSettingsUseCase openSettings,
    required UninstallAppUseCase uninstallApp,
  })  : _getAppInfo = getAppInfo,
        _startApp = startApp,
        _openSettings = openSettings,
        _uninstallApp = uninstallApp;

  final GetAppInfoUseCase _getAppInfo;
  final StartAppUseCase _startApp;
  final OpenAppSettingsUseCase _openSettings;
  final UninstallAppUseCase _uninstallApp;

  DeviceApp? _app;
  bool _loading = false;
  bool _actionLoading = false;
  String? _message;

  DeviceApp? get app => _app;
  bool get loading => _loading;
  bool get actionLoading => _actionLoading;
  String? get message => _message;

  Future<void> load(String packageName) async {
    _loading = true;
    _message = null;
    notifyListeners();
    _app = await _getAppInfo(packageName);
    _loading = false;
    if (_app == null) _message = 'App information is unavailable.';
    notifyListeners();
  }

  Future<bool> launch() async {
    final current = _app;
    if (current == null) return false;
    _actionLoading = true;
    notifyListeners();
    final result = await _startApp(current.packageName) ?? false;
    _actionLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> openSettings() async {
    final current = _app;
    if (current == null) return;
    await _openSettings(current.packageName);
  }

  Future<bool> uninstall() async {
    final current = _app;
    if (current == null) return false;
    _actionLoading = true;
    notifyListeners();
    final result = await _uninstallApp(current.packageName) ?? false;
    _actionLoading = false;
    notifyListeners();
    return result;
  }
}
