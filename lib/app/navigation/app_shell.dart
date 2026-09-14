import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/scaling.dart';
import '../../features/apps/presentation/pages/app_details_page.dart';
import '../../features/apps/presentation/pages/installed_apps_page.dart';
import '../../features/apps/presentation/providers/app_filter_provider.dart';
import '../../features/apps/presentation/providers/installed_apps_provider.dart';
import '../../features/developer/presentation/pages/developer_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _openApps(AppTypeFilter type) {
    context.read<AppFilterProvider>().setType(type);
    setState(() => _index = 1);
  }

  void _openDetails(String packageName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppDetailsPage(packageName: packageName),
      ),
    );
  }

  void _openStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StatisticsPage()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        openApps: _openApps,
        openStatistics: _openStatistics,
        openTools: () => setState(() => _index = 2),
        openSettings: _openSettings,
      ),
      InstalledAppsPage(openDetails: _openDetails),
      const ToolsPage(),
      DeveloperPage(openSettings: _openSettings),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _FloatingBottomNavigation(
        selectedIndex: _index,
        onSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _FloatingBottomNavigation extends StatelessWidget {
  const _FloatingBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: 58.h,
        margin: EdgeInsets.fromLTRB(22.w, 0, 22.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.white,
          ),
          boxShadow: AppShadows.forBrightness(theme.brightness),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _NavItem(
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_rounded,
              label: 'Apps',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            _NavItem(
              icon: Icons.construction_outlined,
              activeIcon: Icons.construction_rounded,
              label: 'Tools',
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Developer',
              selected: selectedIndex == 3,
              onTap: () => onSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).iconTheme.color;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large.r),
        child: SizedBox(
          height: 52.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 22.r),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
