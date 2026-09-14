import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/scaling.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../../../apps/presentation/providers/app_filter_provider.dart';
import '../../../apps/presentation/providers/installed_apps_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.openApps,
    required this.openStatistics,
    required this.openTools,
    required this.openSettings,
  });

  final void Function(AppTypeFilter type) openApps;
  final VoidCallback openStatistics;
  final VoidCallback openTools;
  final VoidCallback openSettings;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InstalledAppsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final isLoading = provider.status == LoadStatus.initial ||
        provider.status == LoadStatus.loading;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: provider.refresh,
          child: Column(
            children: [
              _HomeHeader(
                openApps: openApps,
                openSettings: openSettings,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    Container(
                      color: background,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 148),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                            padding: EdgeInsets.zero,
                            childAspectRatio: 0.9.h,
                            children: [
                              _SummaryCard(
                                title: 'Installed Apps',
                                subtitle: 'View all apps on your device',
                                value: provider.totalApps,
                                label: 'apps',
                                icon: Icons.grid_view_rounded,
                                gradient: AppGradients.blueCard,
                                color: AppColors.primary,
                                onTap: () => openApps(AppTypeFilter.all),
                              ),
                              _SummaryCard(
                                title: 'System Apps',
                                subtitle: 'Explore system applications',
                                value: provider.systemApps,
                                label: 'apps',
                                icon: Icons.settings_rounded,
                                gradient: AppGradients.purpleCard,
                                color: AppColors.purple,
                                onTap: () => openApps(AppTypeFilter.system),
                              ),
                              _SummaryCard(
                                title: 'User Apps',
                                subtitle: 'Explore user applications',
                                value: provider.userApps,
                                label: 'apps',
                                icon: Icons.person_rounded,
                                gradient: AppGradients.greenCard,
                                color: AppColors.success,
                                onTap: () => openApps(AppTypeFilter.user),
                              ),
                              _SummaryCard(
                                title: 'App Details',
                                subtitle: 'Get complete information',
                                value: null,
                                label: '',
                                icon: Icons.description_rounded,
                                gradient: AppGradients.orangeCard,
                                color: AppColors.warning,
                                onTap: () => openApps(AppTypeFilter.all),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Quick Tools',
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: openTools,
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(Icons.chevron_right_rounded),
                                label: const Text('See All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          _QuickToolRow(
                            icon: Icons.play_arrow_rounded,
                            gradient: AppGradients.blueCard,
                            title: 'Launch App',
                            subtitle: 'Open any installed app instantly',
                            onTap: () => openApps(AppTypeFilter.all),
                          ),
                          _QuickToolRow(
                            icon: Icons.file_download_rounded,
                            gradient: AppGradients.greenCard,
                            title: 'Check Installed',
                            subtitle: 'Verify and export installed apps',
                            onTap: () => openApps(AppTypeFilter.all),
                          ),
                          _QuickToolRow(
                            icon: Icons.filter_alt_rounded,
                            gradient: AppGradients.purpleCard,
                            title: 'Sort & Filter',
                            subtitle: 'Organize apps your way',
                            onTap: () => openApps(AppTypeFilter.all),
                          ),
                          _QuickToolRow(
                            icon: Icons.bar_chart_rounded,
                            gradient: AppGradients.orangeCard,
                            title: 'App Statistics',
                            subtitle: 'View app count and category usage',
                            onTap: openStatistics,
                          ),
                          const SizedBox(height: AppSpacing.base),
                          const _EvolixFooterCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // if (isLoading) const Positioned.fill(child: _HomeLoadingOverlay()),
      ],
    );
  }
}

class _HomeLoadingOverlay extends StatelessWidget {
  const _HomeLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AbsorbPointer(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
              .withValues(alpha: 0.42),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadius.card.r),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Loading apps...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.openApps,
    required this.openSettings,
  });

  final void Function(AppTypeFilter type) openApps;
  final VoidCallback openSettings;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _HeaderBackground(),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                              children: const [
                                TextSpan(text: 'App'),
                                TextSpan(
                                  text: 'Scope',
                                  style: TextStyle(color: Color(0xFF8EA9FF)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            AppConstants.tagline,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    _HeaderSettingsButton(onPressed: openSettings),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _HeaderSearchPill(onTap: () => openApps(AppTypeFilter.all)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF07195A),
              Color(0xFF061E7A),
              Color(0xFF175CFF),
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 72.h,
              right: (-96).w,
              child: const _HeaderBand(width: 360, height: 96),
            ),
            Positioned(
              top: 170.h,
              right: (-36).w,
              child: const _HeaderBand(width: 280, height: 88),
            ),
            Positioned(
              top: 250.h,
              left: (-94).w,
              child: const _HeaderBand(width: 250, height: 78),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBand extends StatelessWidget {
  const _HeaderBand({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.78,
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((height / 2).r),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.03),
              AppColors.primary.withValues(alpha: 0.34),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}

class _HeaderSettingsButton extends StatelessWidget {
  const _HeaderSettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Appearance',
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18.r),
          child: SizedBox(
            width: 46.w,
            height: 46.h,
            child: Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 26.r,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSearchPill extends StatelessWidget {
  const _HeaderSearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.12),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.deepNavy,
                    size: 24.r,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Search apps, packages, or developers...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                          ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 26.h,
                    color: AppColors.lightDivider,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.mic_rounded,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int? value;
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GradientIcon(icon: icon, gradient: gradient, size: 36),
              const Spacer(),
              CircleAvatar(
                radius: 16.r,
                backgroundColor: color.withValues(alpha: 0.10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: 24.r,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (value != null)
            Row(
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            )
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickToolRow extends StatelessWidget {
  const _QuickToolRow({
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
      child: _SurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            _GradientIcon(icon: icon, gradient: gradient, size: 46),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 30.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _EvolixFooterCard extends StatelessWidget {
  const _EvolixFooterCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Powered by',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Container(
            width: 1,
            height: 44.h,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            color: Theme.of(context).dividerColor,
          ),
          const Expanded(
            flex: 1,
            child: EvolixLogo(height: 26),
          ),
          Container(
            width: 1,
            height: 44.h,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: Text(
              'Building Smarter\nDigital Experiences',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.card.r);

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: radius,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({
    required this.icon,
    required this.gradient,
    required this.size,
  });

  final IconData icon;
  final Gradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular((size * 0.26).r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: (size * 0.48).r),
    );
  }
}
