import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../../domain/entities/device_app.dart';
import 'device_app_icon.dart';

class InstalledAppTile extends StatelessWidget {
  const InstalledAppTile({
    super.key,
    required this.app,
    required this.onTap,
    this.onLaunch,
    this.onSettings,
  });

  final DeviceApp app;
  final VoidCallback onTap;
  final VoidCallback? onLaunch;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(12.h, 12.h, 8.h, 12.h),
      child: Row(
        children: [
          DeviceAppIcon(app: app, size: 52),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  app.packageName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${app.isSystemApp ? 'System App' : 'User App'}  •  ${app.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.textTheme.titleLarge?.color,
            ),
            onSelected: (value) {
              if (value == 'launch') onLaunch?.call();
              if (value == 'settings') onSettings?.call();
            },
            itemBuilder: (_) => [
              if (app.isLaunchable)
                const PopupMenuItem(value: 'launch', child: Text('Launch')),
              const PopupMenuItem(value: 'settings', child: Text('App settings')),
            ],
          ),
        ],
      ),
    );
  }
}
