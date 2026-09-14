import 'dart:typed_data';

class DeviceApp {
  const DeviceApp({
    required this.name,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.platformType,
    required this.installedAt,
    required this.isSystemApp,
    required this.isLaunchable,
    required this.category,
    this.nativeInfo,
    this.icon,
  });

  final String name;
  final String packageName;
  final String versionName;
  final int versionCode;
  final String platformType;
  final DateTime? installedAt;
  final bool isSystemApp;
  final bool isLaunchable;
  final String category;
  final NativeAppInfo? nativeInfo;
  final Uint8List? icon;

  DeviceApp copyWith({
    String? name,
    String? packageName,
    String? versionName,
    int? versionCode,
    String? platformType,
    DateTime? installedAt,
    bool? isSystemApp,
    bool? isLaunchable,
    String? category,
    NativeAppInfo? nativeInfo,
    Uint8List? icon,
  }) {
    return DeviceApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      platformType: platformType ?? this.platformType,
      installedAt: installedAt ?? this.installedAt,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isLaunchable: isLaunchable ?? this.isLaunchable,
      category: category ?? this.category,
      nativeInfo: nativeInfo ?? this.nativeInfo,
      icon: icon ?? this.icon,
    );
  }
}

class NativeAppInfo {
  const NativeAppInfo({
    this.minSdkVersion,
    this.targetSdkVersion,
    this.compileSdkVersion,
    this.compileSdkVersionCodename,
    this.firstInstalledAt,
    this.lastUpdatedAt,
    this.installerPackageName,
    this.sourceDir,
    this.publicSourceDir,
    this.nativeLibraryDir,
    this.dataDir,
    this.processName,
    this.taskAffinity,
    this.uid,
    this.debuggable,
    this.hasNativeCode,
    this.detectedFramework,
    this.frameworkVersion,
    this.language,
    this.runtime,
    this.sdkVersion,
    this.frameworkVersionAvailable = false,
    this.frameworkEvidence = const [],
    this.requestedPermissions = const [],
    this.requestedFeatures = const [],
  });

  final int? minSdkVersion;
  final int? targetSdkVersion;
  final int? compileSdkVersion;
  final String? compileSdkVersionCodename;
  final DateTime? firstInstalledAt;
  final DateTime? lastUpdatedAt;
  final String? installerPackageName;
  final String? sourceDir;
  final String? publicSourceDir;
  final String? nativeLibraryDir;
  final String? dataDir;
  final String? processName;
  final String? taskAffinity;
  final int? uid;
  final bool? debuggable;
  final bool? hasNativeCode;
  final String? detectedFramework;
  final String? frameworkVersion;
  final String? language;
  final String? runtime;
  final String? sdkVersion;
  final bool frameworkVersionAvailable;
  final List<String> frameworkEvidence;
  final List<String> requestedPermissions;
  final List<String> requestedFeatures;

  bool get hasAnyValue =>
      minSdkVersion != null ||
      targetSdkVersion != null ||
      compileSdkVersion != null ||
      (compileSdkVersionCodename != null &&
          compileSdkVersionCodename!.trim().isNotEmpty) ||
      (detectedFramework != null && detectedFramework!.trim().isNotEmpty) ||
      frameworkEvidence.isNotEmpty ||
      requestedPermissions.isNotEmpty ||
      requestedFeatures.isNotEmpty;
}
