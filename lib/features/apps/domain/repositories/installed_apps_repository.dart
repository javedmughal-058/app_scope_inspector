import 'dart:typed_data';

import '../entities/device_app.dart';

abstract interface class InstalledAppsRepository {
  Future<List<DeviceApp>> getInstalledApps({
    bool excludeSystemApps = false,
    bool excludeNonLaunchableApps = false,
    bool withIcon = true,
    String? packageNamePrefix,
    String? platformTypeSlug,
  });

  Future<DeviceApp?> getAppInfo(String packageName);
  Future<Uint8List?> getAppIcon(String packageName);
  Future<bool?> startApp(String packageName);
  Future<void> openSettings(String packageName);
  Future<bool?> isSystemApp(String packageName);
  Future<bool?> uninstallApp(String packageName);
  Future<bool?> isAppInstalled(String packageName);
  Future<void> showToast(String message, {bool short = true});
}
