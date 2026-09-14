import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../../../apps/presentation/providers/installed_apps_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstalledAppsProvider>();
    final categories = <String, int>{};
    for (final app in provider.apps) {
      categories[app.category] = (categories[app.category] ?? 0) + 1;
    }

    final categoryEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: AppPage(
          children: [
            AppTopBar(
              title: 'App Statistics',
              subtitle: 'Overview of your installed applications',
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left_rounded, size: 34),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.45.h,
              children: [
                _GradientStatCard(
                  title: 'Total Apps',
                  value: provider.totalApps,
                  subtitle: 'Apps installed on your device',
                  icon: Icons.grid_view_rounded,
                  gradient: AppGradients.blueCard,
                ),
                _GradientStatCard(
                  title: 'User Apps',
                  value: provider.userApps,
                  subtitle: 'Downloaded by you',
                  icon: Icons.person_rounded,
                  gradient: AppGradients.greenCard,
                ),
                _GradientStatCard(
                  title: 'System Apps',
                  value: provider.systemApps,
                  subtitle: 'Pre-installed by the system',
                  icon: Icons.settings_rounded,
                  gradient: AppGradients.purpleCard,
                ),
                _GradientStatCard(
                  title: 'Launchable',
                  value: provider.launchableApps,
                  subtitle: 'Apps with launcher activity',
                  icon: Icons.play_arrow_rounded,
                  gradient: AppGradients.orangeCard,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'App Availability',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '${provider.nonLaunchableApps} hidden',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _AvailabilityBar(
                    label: 'Launchable Apps',
                    value: provider.launchableApps,
                    total: provider.totalApps,
                    color: AppColors.primary,
                  ),
                  _AvailabilityBar(
                    label: 'Non-launchable Apps',
                    value: provider.nonLaunchableApps,
                    total: provider.totalApps,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Apps by Category',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        'View All',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18.h),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...categoryEntries.take(6).toList().asMap().entries.map((item) {
                      final index = item.key;
                      final entry = item.value;
                      return Column(
                        children: [
                          _CategoryRow(
                            label: entry.key,
                            value: entry.value,
                            total: provider.totalApps,
                          ),
                          if (index < 5)
                            const SizedBox(height: AppSpacing.base),
                        ],
                      );
                    }),
                  if (categoryEntries.isEmpty)
                    Text(
                      'No category information available yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.h,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 22.h),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),

                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBar extends StatelessWidget {
  const _AvailabilityBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.titleSmall),
              ),
              Text(
                '$value (${(fraction * 100).round()}%)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: fraction,
            color: color,
            minHeight: 12,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : value / total;
    final color = _colorFor(label);

    return Row(
      children: [
        GradientIconBox(
          icon: _iconFor(label),
          gradient: LinearGradient(colors: [color.withValues(alpha: 0.75), color]),
          size: 36,
          iconSize: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('$value', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        SizedBox(
          width: 110.w,
          child: LinearProgressIndicator(
            value: fraction,
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 42,
          child: Text(
            '${(fraction * 100).round()}%',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }

  static Color _colorFor(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('game')) return const Color(0xFFFF4D82);
    if (normalized.contains('social')) return AppColors.warning;
    if (normalized.contains('tool')) return AppColors.primary;
    if (normalized.contains('product')) return AppColors.success;
    return AppColors.purple;
  }

  static IconData _iconFor(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('game')) return Icons.sports_esports_rounded;
    if (normalized.contains('social')) return Icons.groups_rounded;
    if (normalized.contains('tool')) return Icons.construction_rounded;
    if (normalized.contains('product')) return Icons.android_rounded;
    return Icons.grid_view_rounded;
  }
}
