import 'dart:typed_data';

import '../../domain/entities/device_app.dart';
import '../../domain/repositories/installed_apps_repository.dart';
import '../datasources/installed_apps_data_source.dart';

class InstalledAppsRepositoryImpl implements InstalledAppsRepository {
  const InstalledAppsRepositoryImpl(this._dataSource);

  final InstalledAppsDataSource _dataSource;

  @override
  Future<List<DeviceApp>> getInstalledApps({
    bool excludeSystemApps = false,
    bool excludeNonLaunchableApps = false,
    bool withIcon = true,
    String? packageNamePrefix,
    String? platformTypeSlug,
  }) async {
    final result = await _dataSource.getInstalledApps(
      excludeSystemApps: excludeSystemApps,
      excludeNonLaunchableApps: excludeNonLaunchableApps,
      withIcon: withIcon,
      packageNamePrefix: packageNamePrefix,
    );

    final normalizedPlatform = platformTypeSlug?.replaceAll('_', ' ').toLowerCase();
    final apps = result
        .map(_toEntity)
        .where(
          (app) =>
              normalizedPlatform == null ||
              app.platformType.toLowerCase().contains(
                    normalizedPlatform,
                  ),
        )
        .toList(growable: false);

    return apps;
  }

  @override
  Future<DeviceApp?> getAppInfo(String packageName) async {
    final info = await _dataSource.getAppInfo(packageName);
    if (info == null) return null;
    return _toEntity(info);
  }

  @override
  Future<Uint8List?> getAppIcon(String packageName) {
    return _dataSource.getAppIcon(packageName);
  }

  @override
  Future<bool?> startApp(String packageName) => _dataSource.startApp(packageName);

  @override
  Future<void> openSettings(String packageName) {
    return _dataSource.openSettings(packageName);
  }

  @override
  Future<bool?> isSystemApp(String packageName) => _dataSource.isSystemApp(packageName);

  @override
  Future<bool?> uninstallApp(String packageName) => _dataSource.uninstallApp(packageName);

  @override
  Future<bool?> isAppInstalled(String packageName) => _dataSource.isAppInstalled(packageName);

  @override
  Future<void> showToast(String message, {bool short = true}) {
    return _dataSource.toast(message, short);
  }

  DeviceApp _toEntity(NativeAppMap info) {
    return DeviceApp(
      name: _stringValue(info['name']) ?? _stringValue(info['packageName']) ?? 'Unknown',
      packageName: _stringValue(info['packageName']) ?? '',
      versionName: _stringValue(info['versionName']) ?? 'Unknown',
      versionCode: _intValue(info['versionCode']) ?? 0,
      platformType: _stringValue(info['platformType']) ??
          _stringValue(info['detectedFramework']) ??
          'Native Android or unknown',
      installedAt: _dateValue(info['installedTimestamp']) ??
          _dateValue(info['firstInstallTime']),
      isSystemApp: _boolValue(info['isSystemApp']) ?? false,
      isLaunchable: _boolValue(info['isLaunchableApp']) ?? false,
      category: _stringValue(info['category']) ?? 'Undefined',
      nativeInfo: _toNativeAppInfo(info),
      icon: _bytesValue(info['icon']),
    );
  }

  NativeAppInfo? _toNativeAppInfo(NativeAppMap data) {
    final nativeInfo = NativeAppInfo(
      minSdkVersion: _intValue(data['minSdkVersion']),
      targetSdkVersion: _intValue(data['targetSdkVersion']),
      compileSdkVersion: _intValue(data['compileSdkVersion']),
      compileSdkVersionCodename: _stringValue(data['compileSdkVersionCodename']),
      firstInstalledAt: _dateValue(data['firstInstallTime']),
      lastUpdatedAt: _dateValue(data['lastUpdateTime']),
      installerPackageName: _stringValue(data['installerPackageName']),
      sourceDir: _stringValue(data['sourceDir']),
      publicSourceDir: _stringValue(data['publicSourceDir']),
      nativeLibraryDir: _stringValue(data['nativeLibraryDir']),
      dataDir: _stringValue(data['dataDir']),
      processName: _stringValue(data['processName']),
      taskAffinity: _stringValue(data['taskAffinity']),
      uid: _intValue(data['uid']),
      debuggable: _boolValue(data['debuggable']),
      hasNativeCode: _boolValue(data['hasNativeCode']),
      detectedFramework: _stringValue(data['detectedFramework']),
      frameworkVersion: _stringValue(data['frameworkVersion']),
      language: _stringValue(data['language']),
      runtime: _stringValue(data['runtime']),
      sdkVersion: _stringValue(data['sdkVersion']),
      frameworkVersionAvailable:
          _boolValue(data['frameworkVersionAvailable']) ?? false,
      frameworkEvidence: _stringList(data['frameworkEvidence']),
      requestedPermissions: _stringList(data['requestedPermissions']),
      requestedFeatures: _stringList(data['requestedFeatures']),
    );

    return nativeInfo.hasAnyValue ? nativeInfo : null;
  }

  Uint8List? _bytesValue(Object? value) {
    if (value is Uint8List) return value;
    if (value is List) {
      return Uint8List.fromList(
        value
            .whereType<num>()
            .map((item) => item.toInt())
            .toList(growable: false),
      );
    }
    return null;
  }

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  String? _stringValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  DateTime? _dateValue(Object? value) {
    final milliseconds = _intValue(value);
    if (milliseconds == null || milliseconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  List<String> _stringList(Object? value) {
    if (value is! Iterable) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
