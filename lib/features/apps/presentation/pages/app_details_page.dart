import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/device_app.dart';
import '../../domain/usecases/app_use_cases.dart';
import '../providers/app_details_provider.dart';
import '../widgets/device_app_icon.dart';

class AppDetailsPage extends StatelessWidget {
  const AppDetailsPage({super.key, required this.packageName});

  final String packageName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppDetailsProvider(
        getAppInfo: context.read<GetAppInfoUseCase>(),
        startApp: context.read<StartAppUseCase>(),
        openSettings: context.read<OpenAppSettingsUseCase>(),
        uninstallApp: context.read<UninstallAppUseCase>(),
      )..load(packageName),
      child: const _AppDetailsBody(),
    );
  }
}

class _AppDetailsBody extends StatelessWidget {
  const _AppDetailsBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDetailsProvider>();
    final app = provider.app;

    return Scaffold(
      body: provider.loading
          ? const AppLoadingView(message: 'Loading app details...')
          : app == null
              ? AppEmptyView(
                  title: 'Details unavailable',
                  message: provider.message ?? 'No app information was returned.',
                )
              : AppPage(
                  children: [
                    AppTopBar(
                      title: app.name,
                      leading: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.chevron_left_rounded, size: 34),
                      ),
                      trailing: IconButton(
                        tooltip: 'More options',
                        onPressed: provider.openSettings,
                        icon: const Icon(Icons.more_vert_rounded, size: 30),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        DeviceAppIcon(app: app, size: 92),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                app.packageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _StatusPill(
                                label: app.isSystemApp ? 'System App' : 'User App',
                                color: app.isSystemApp
                                    ? AppColors.purple
                                    : AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.play_arrow_rounded,
                            label: 'Launch',
                            gradient: AppGradients.blueCard,
                            enabled: app.isLaunchable && !provider.actionLoading,
                            onTap: () => _launch(context, provider),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.settings_rounded,
                            label: 'Open Settings',
                            gradient: AppGradients.purpleCard,
                            onTap: provider.openSettings,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.delete_outline_rounded,
                            label: 'Uninstall',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB3B3), Color(0xFFFFECEC)],
                            ),
                            foreground: AppColors.error,
                            onTap: () => _confirmUninstall(context, provider, app.name),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    _InfoCard(app: app),
                    const SizedBox(height: AppSpacing.base),
                    _OptionTile(
                      icon: Icons.check_rounded,
                      gradient: AppGradients.greenCard,
                      title: 'Check if installed',
                      subtitle: 'Verify if this app is installed on your device',
                      onTap: () => _message(context, 'Installed: ${app.name}'),
                    ),
                    _OptionTile(
                      icon: Icons.settings_rounded,
                      gradient: AppGradients.purpleCard,
                      title: 'Check if system app',
                      subtitle: 'Find out if this is a system application',
                      onTap: () => _message(
                        context,
                        app.isSystemApp ? 'This is a system app.' : 'This is a user app.',
                      ),
                    ),
                    _OptionTile(
                      icon: Icons.shop_rounded,
                      gradient: AppGradients.blueCard,
                      title: 'View in Play Store',
                      subtitle: 'Open this app in Google Play Store',
                      onTap: provider.openSettings,
                    ),
                  ],
                ),
    );
  }

  Future<void> _launch(
    BuildContext context,
    AppDetailsProvider provider,
  ) async {
    final ok = await provider.launch();
    if (!context.mounted) return;
    _message(context, ok ? 'Launch request sent.' : 'Unable to launch this app.');
  }

  Future<void> _confirmUninstall(
    BuildContext context,
    AppDetailsProvider provider,
    String appName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Uninstall $appName?'),
        content: const Text(
          'Android will open the system uninstall flow for this application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await provider.uninstall();
    if (!context.mounted) return;
    _message(context, ok ? 'Uninstall request sent.' : 'Unable to start uninstall.');
  }

  static void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.foreground = AppColors.deepNavy,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final Color foreground;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SoftCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            GradientIconBox(
              icon: icon,
              gradient: gradient,
              size: 48,
              iconSize: 26,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground == AppColors.deepNavy
                        ? Theme.of(context).textTheme.titleLarge?.color
                        : foreground,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.app});

  final DeviceApp app;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('App Name', app.name),
      ('Package Name', app.packageName),
      ('Version Name', app.versionName),
      ('Version Code', '${app.versionCode}'),
      ('Install Date', _formatDate(app.installedAt)),
      ('App Category', app.category),
      ('Platform Type', app.platformType),
      ..._nativeInspectionRows(app.nativeInfo),
      ..._frameworkRows(app.nativeInfo, app.platformType),
      ('Launchable', app.isLaunchable ? 'Yes' : 'No'),
    ];

    return SoftCard(
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.$1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        row.$2,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  static List<(String, String)> _nativeInspectionRows(NativeAppInfo? info) {
    if (info == null || !info.hasAnyValue) {
      return const [
        ('Native Inspection', 'Unavailable'),
      ];
    }

    return [
      ('Min Android SDK', _versionOrUnknown(info.minSdkVersion)),
      ('Target Android SDK', _versionOrUnknown(info.targetSdkVersion)),
      ('Compile Android SDK', _versionOrUnknown(info.compileSdkVersion)),
      if (_hasText(info.compileSdkVersionCodename))
        ('Compile SDK Codename', info.compileSdkVersionCodename!),
      if (info.firstInstalledAt != null)
        ('First Installed', _formatDate(info.firstInstalledAt)),
      if (info.lastUpdatedAt != null)
        ('Last Updated', _formatDate(info.lastUpdatedAt)),
      if (_hasText(info.installerPackageName))
        ('Installer', info.installerPackageName!),
      if (_hasText(info.processName)) ('Process', info.processName!),
      if (_hasText(info.taskAffinity)) ('Task Affinity', info.taskAffinity!),
      if (info.uid != null) ('App UID', '${info.uid}'),
      if (info.debuggable != null) ('Debuggable', info.debuggable! ? 'Yes' : 'No'),
      if (info.hasNativeCode != null)
        ('Native Code', info.hasNativeCode! ? 'Yes' : 'No'),
      if (_hasText(info.sourceDir)) ('APK Source', info.sourceDir!),
      if (_hasText(info.publicSourceDir)) ('Public APK Source', info.publicSourceDir!),
      if (_hasText(info.nativeLibraryDir))
        ('Native Library Path', info.nativeLibraryDir!),
      if (_hasText(info.dataDir)) ('Data Directory', info.dataDir!),
      if (info.requestedPermissions.isNotEmpty)
        (
          'Permissions',
          '${info.requestedPermissions.length}: ${_previewList(info.requestedPermissions)}',
        ),
      if (info.requestedFeatures.isNotEmpty)
        (
          'Device Features',
          '${info.requestedFeatures.length}: ${_previewList(info.requestedFeatures)}',
        ),
    ];
  }

  static String _versionOrUnknown(int? version) {
    return version == null ? 'Unknown' : '$version';
  }

  static List<(String, String)> _frameworkRows(
    NativeAppInfo? info,
    String platformType,
  ) {
    final detectedFramework = _hasText(info?.detectedFramework)
        ? info!.detectedFramework!
        : platformType;
    final normalized = detectedFramework.toLowerCase();

    if (normalized.contains('flutter')) {
      return [
        ('Detected Framework', detectedFramework),
        ('Language', _valueOrUnknown(info?.language)),
        ('Runtime', _valueOrUnknown(info?.runtime)),
        ('Flutter SDK Version', _frameworkVersion(info)),
        ('Dart SDK Version', _valueOrUnknown(info?.sdkVersion)),
        if (info != null && info.frameworkEvidence.isNotEmpty)
          ('Detection Evidence', _previewList(info.frameworkEvidence)),
      ];
    }

    if (normalized.contains('react')) {
      return [
        ('Detected Framework', detectedFramework),
        ('Language', _valueOrUnknown(info?.language)),
        ('Runtime', _valueOrUnknown(info?.runtime)),
        ('React Native Version', _frameworkVersion(info)),
        if (info != null && info.frameworkEvidence.isNotEmpty)
          ('Detection Evidence', _previewList(info.frameworkEvidence)),
      ];
    }

    if (normalized.contains('xamarin') || normalized.contains('.net')) {
      return [
        ('Detected Framework', detectedFramework),
        ('Language', _valueOrUnknown(info?.language)),
        ('Runtime', _valueOrUnknown(info?.runtime)),
        ('Xamarin/.NET Version', _frameworkVersion(info)),
        if (info != null && info.frameworkEvidence.isNotEmpty)
          ('Detection Evidence', _previewList(info.frameworkEvidence)),
      ];
    }

    if (normalized.contains('ionic') ||
        normalized.contains('capacitor') ||
        normalized.contains('cordova')) {
      return [
        ('Detected Framework', detectedFramework),
        ('Language', _valueOrUnknown(info?.language)),
        ('Runtime', _valueOrUnknown(info?.runtime)),
        ('Ionic Version', _frameworkVersion(info)),
        if (info != null && info.frameworkEvidence.isNotEmpty)
          ('Detection Evidence', _previewList(info.frameworkEvidence)),
      ];
    }

    return [
      ('Detected Framework', detectedFramework),
      ('Language', _valueOrUnknown(info?.language)),
      ('Runtime', _valueOrUnknown(info?.runtime)),
      if (info != null && info.frameworkEvidence.isNotEmpty)
        ('Detection Evidence', _previewList(info.frameworkEvidence)),
    ];
  }

  static String _frameworkVersion(NativeAppInfo? info) {
    if (info == null) return 'Unknown';
    if (info.frameworkVersionAvailable && _hasText(info.frameworkVersion)) {
      return info.frameworkVersion!;
    }
    return info.frameworkVersion ?? 'Not packaged in APK metadata';
  }

  static String _valueOrUnknown(String? value) {
    return _hasText(value) ? value! : 'Unknown';
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _previewList(List<String> values) {
    const maxItems = 3;
    final preview = values.take(maxItems).join(', ');
    final remaining = values.length - maxItems;
    return remaining > 0 ? '$preview +$remaining more' : preview;
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            GradientIconBox(icon: icon, gradient: gradient, size: 56),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 30),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
