import 'dart:typed_data';

import '../entities/device_app.dart';
import '../repositories/installed_apps_repository.dart';

class GetInstalledAppsUseCase {
  const GetInstalledAppsUseCase(this._repository);
  final InstalledAppsRepository _repository;

  Future<List<DeviceApp>> call({bool withIcon = false}) => _repository.getInstalledApps(
        excludeSystemApps: false,
        excludeNonLaunchableApps: false,
        withIcon: withIcon,
      );
}

class GetAppInfoUseCase {
  const GetAppInfoUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<DeviceApp?> call(String packageName) => _repository.getAppInfo(packageName);
}

class GetAppIconUseCase {
  const GetAppIconUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<Uint8List?> call(String packageName) => _repository.getAppIcon(packageName);
}

class StartAppUseCase {
  const StartAppUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<bool?> call(String packageName) => _repository.startApp(packageName);
}

class OpenAppSettingsUseCase {
  const OpenAppSettingsUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<void> call(String packageName) => _repository.openSettings(packageName);
}

class CheckAppInstalledUseCase {
  const CheckAppInstalledUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<bool?> call(String packageName) => _repository.isAppInstalled(packageName);
}

class CheckSystemAppUseCase {
  const CheckSystemAppUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<bool?> call(String packageName) => _repository.isSystemApp(packageName);
}

class UninstallAppUseCase {
  const UninstallAppUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<bool?> call(String packageName) => _repository.uninstallApp(packageName);
}

class ShowToastUseCase {
  const ShowToastUseCase(this._repository);
  final InstalledAppsRepository _repository;
  Future<void> call(String message, {bool short = true}) => _repository.showToast(message, short: short);
}

class FilterInstalledAppsUseCase {
  const FilterInstalledAppsUseCase(this._repository);
  final InstalledAppsRepository _repository;

  Future<List<DeviceApp>> call({String? packageNamePrefix, String? platformTypeSlug}) {
    return _repository.getInstalledApps(
      excludeSystemApps: false,
      excludeNonLaunchableApps: false,
      withIcon: false,
      packageNamePrefix: packageNamePrefix,
      platformTypeSlug: platformTypeSlug,
    );
  }
}
