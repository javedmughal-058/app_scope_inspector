import 'dart:typed_data';

import 'package:flutter/services.dart';

typedef NativeAppMap = Map<dynamic, dynamic>;

abstract interface class InstalledAppsDataSource {
  Future<List<NativeAppMap>> getInstalledApps({
    bool excludeSystemApps = false,
    bool excludeNonLaunchableApps = false,
    bool withIcon = true,
    String? packageNamePrefix,
  });

  Future<NativeAppMap?> getAppInfo(String packageName);
  Future<Uint8List?> getAppIcon(String packageName);
  Future<bool?> startApp(String packageName);
  Future<void> openSettings(String packageName);
  Future<bool?> isSystemApp(String packageName);
  Future<bool?> uninstallApp(String packageName);
  Future<bool?> isAppInstalled(String packageName);
  Future<void> toast(String message, bool isShortLength);
}

class InstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  static const MethodChannel _nativeChannel = MethodChannel(
    'app_scope_inspector/native_app_info',
  );

  @override
  Future<List<NativeAppMap>> getInstalledApps({
    bool excludeSystemApps = false,
    bool excludeNonLaunchableApps = false,
    bool withIcon = true,
    String? packageNamePrefix,
  }) async {
    final result = await _nativeChannel.invokeListMethod<dynamic>(
      'getInstalledApps',
      <String, Object?>{
        'excludeSystemApps': excludeSystemApps,
        'excludeNonLaunchableApps': excludeNonLaunchableApps,
        'withIcon': withIcon,
        'packageNamePrefix': packageNamePrefix,
      },
    );

    return result
            ?.whereType<Map>()
            .map((item) => Map<dynamic, dynamic>.from(item))
            .toList(growable: false) ??
        const [];
  }

  @override
  Future<NativeAppMap?> getAppInfo(String packageName) {
    return _nativeChannel.invokeMapMethod<dynamic, dynamic>(
      'getAppInfo',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<Uint8List?> getAppIcon(String packageName) {
    return _nativeChannel.invokeMethod<Uint8List>(
      'getAppIcon',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<bool?> startApp(String packageName) {
    return _nativeChannel.invokeMethod<bool>(
      'startApp',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<void> openSettings(String packageName) async {
    await _nativeChannel.invokeMethod<void>(
      'openSettings',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<bool?> isSystemApp(String packageName) {
    return _nativeChannel.invokeMethod<bool>(
      'isSystemApp',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<bool?> uninstallApp(String packageName) {
    return _nativeChannel.invokeMethod<bool>(
      'uninstallApp',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<bool?> isAppInstalled(String packageName) {
    return _nativeChannel.invokeMethod<bool>(
      'isAppInstalled',
      <String, Object?>{
        'packageName': packageName,
      },
    );
  }

  @override
  Future<void> toast(String message, bool isShortLength) async {
    await _nativeChannel.invokeMethod<void>(
      'toast',
      <String, Object?>{
        'message': message,
        'isShortLength': isShortLength,
      },
    );
  }
}
