import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers/app_providers.dart';
import 'core/services/asset_preloader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final assetsReady = AppAssetPreloader.preloadImageAssets();
  final preferences = await SharedPreferences.getInstance();
  await assetsReady;
  runApp(AppProviders(preferences: preferences, child: const AppScopeApp()));
}
