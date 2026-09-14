import 'package:flutter/foundation.dart';

import '../../domain/entities/device_app.dart';

enum AppTypeFilter { all, user, system }
enum AppSort { nameAsc, nameDesc, installNewest, installOldest }

class AppFilterProvider extends ChangeNotifier {
  String _query = '';
  AppTypeFilter _type = AppTypeFilter.all;
  AppSort _sort = AppSort.nameAsc;
  bool _launchableOnly = false;
  String? _category;
  String? _platformType;

  String get query => _query;
  AppTypeFilter get type => _type;
  AppSort get sort => _sort;
  bool get launchableOnly => _launchableOnly;
  String? get category => _category;
  String? get platformType => _platformType;
  bool get hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _type != AppTypeFilter.all ||
      _sort != AppSort.nameAsc ||
      _launchableOnly ||
      _category != null ||
      _platformType != null;

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setType(AppTypeFilter value) {
    if (_type == value) return;
    _type = value;
    notifyListeners();
  }

  void setSort(AppSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  void setLaunchableOnly(bool value) {
    if (_launchableOnly == value) return;
    _launchableOnly = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  void setPlatformType(String? value) {
    _platformType = value;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _type = AppTypeFilter.all;
    _sort = AppSort.nameAsc;
    _launchableOnly = false;
    _category = null;
    _platformType = null;
    notifyListeners();
  }

  List<DeviceApp> apply(List<DeviceApp> source) {
    final normalized = _query.trim().toLowerCase();
    final result = source.where((app) {
      final matchesQuery = normalized.isEmpty ||
          app.name.toLowerCase().contains(normalized) ||
          app.packageName.toLowerCase().contains(normalized);
      final matchesType = switch (_type) {
        AppTypeFilter.all => true,
        AppTypeFilter.user => !app.isSystemApp,
        AppTypeFilter.system => app.isSystemApp,
      };
      final matchesLaunchable = !_launchableOnly || app.isLaunchable;
      final matchesCategory = _category == null || app.category == _category;
      final matchesPlatform = _platformType == null ||
          app.platformType.toLowerCase().contains(_platformType!.toLowerCase());
      return matchesQuery && matchesType && matchesLaunchable && matchesCategory && matchesPlatform;
    }).toList(growable: false);

    final mutable = [...result];
    switch (_sort) {
      case AppSort.nameAsc:
        mutable.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case AppSort.nameDesc:
        mutable.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case AppSort.installNewest:
        mutable.sort((a, b) => (b.installedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.installedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        break;
      case AppSort.installOldest:
        mutable.sort((a, b) => (a.installedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.installedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        break;
    }
    return mutable;
  }
}
