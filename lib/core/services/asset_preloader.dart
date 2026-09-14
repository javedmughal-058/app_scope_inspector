import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppAssetPreloader {
  const AppAssetPreloader._();

  static const _imagePathPrefix = 'assets/images/';
  static const _supportedExtensions = {'.png', '.jpg', '.jpeg', '.webp'};

  static Future<void> preloadImageAssets() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
      final assets = manifest.keys.where(_isImageFolderAsset).toList();
      final imageAssets = assets.where(_isSupportedImageAsset);

      await Future.wait(assets.map(rootBundle.load));
      await Future.wait(imageAssets.map(_precacheAssetImage));
    } catch (_) {
      return;
    }
  }

  static bool _isImageFolderAsset(String assetPath) {
    return assetPath.toLowerCase().startsWith(_imagePathPrefix);
  }

  static bool _isSupportedImageAsset(String assetPath) {
    final lowerPath = assetPath.toLowerCase();
    return _isImageFolderAsset(assetPath) &&
        _supportedExtensions.any(lowerPath.endsWith);
  }

  static Future<void> _precacheAssetImage(String assetPath) {
    final completer = Completer<void>();
    final stream = AssetImage(assetPath).resolve(const ImageConfiguration());

    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
      onError: (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      },
    );

    stream.addListener(listener);
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        stream.removeListener(listener);
      },
    );
  }
}
