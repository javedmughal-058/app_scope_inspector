import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../domain/entities/device_app.dart';
import '../../domain/usecases/app_use_cases.dart';

enum LoadStatus { initial, loading, success, empty, failure }

class InstalledAppsProvider extends ChangeNotifier {
  InstalledAppsProvider({
    required GetInstalledAppsUseCase getInstalledApps,
    required GetAppIconUseCase getAppIcon,
  })  : _getInstalledApps = getInstalledApps,
        _getAppIcon = getAppIcon;

  final GetInstalledAppsUseCase _getInstalledApps;
  final GetAppIconUseCase _getAppIcon;
  final Set<String> _loadingIconPackages = {};

  LoadStatus _status = LoadStatus.initial;
  List<DeviceApp> _apps = const [];
  String? _errorMessage;

  LoadStatus get status => _status;
  List<DeviceApp> get apps => List.unmodifiable(_apps);
  String? get errorMessage => _errorMessage;

  int get totalApps => _apps.length;
  int get userApps => _apps.where((e) => !e.isSystemApp).length;
  int get systemApps => _apps.where((e) => e.isSystemApp).length;
  int get launchableApps => _apps.where((e) => e.isLaunchable).length;
  int get nonLaunchableApps => _apps.where((e) => !e.isLaunchable).length;

  Future<void> loadApps({bool force = false}) async {
    if (_status == LoadStatus.loading) return;
    if (!force && (_status == LoadStatus.success || _status == LoadStatus.empty)) {
      return;
    }

    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getInstalledApps();
      _apps = result;
      _status = result.isEmpty ? LoadStatus.empty : LoadStatus.success;
    } catch (_) {
      _status = LoadStatus.failure;
      _errorMessage = 'Unable to load installed applications.';
    }

    notifyListeners();
  }

  Future<void> loadIconsForPackages(Iterable<DeviceApp> targetApps) async {
    if (_apps.isEmpty) return;

    final pending = targetApps
        .where((app) => app.icon == null || app.icon!.isEmpty)
        .map((app) => app.packageName)
        .where((packageName) => packageName.isNotEmpty)
        .where((packageName) => !_loadingIconPackages.contains(packageName))
        .take(24)
        .toList(growable: false);

    if (pending.isEmpty) return;

    _loadingIconPackages.addAll(pending);

    final loadedIcons = <String, Uint8List>{};
    await Future.wait(
      pending.map((packageName) async {
        try {
          final icon = await _getAppIcon(packageName);
          if (icon != null && icon.isNotEmpty) {
            loadedIcons[packageName] = icon;
          }
        } catch (_) {
          // Icon loading is best-effort; keep the placeholder on failure.
        } finally {
          _loadingIconPackages.remove(packageName);
        }
      }),
    );

    if (loadedIcons.isEmpty) return;

    _apps = _apps
        .map(
          (app) => loadedIcons.containsKey(app.packageName)
              ? app.copyWith(icon: loadedIcons[app.packageName])
              : app,
        )
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> refresh() async {
    _loadingIconPackages.clear();
    await loadApps(force: true);
  }
}
