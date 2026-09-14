import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/device_app.dart';

class DeviceAppIcon extends StatelessWidget {
  const DeviceAppIcon({super.key, required this.app, this.size = 52});
  final DeviceApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;
    if (icon != null && icon.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * .24),
        child: Image.memory(icon, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    return Container(
      width: size.h,
      height: size.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(size * .24),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.android_rounded, color: Theme.of(context).colorScheme.primary, size: size * .52),
    );
  }
}
