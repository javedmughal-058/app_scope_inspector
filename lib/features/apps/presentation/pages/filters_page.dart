import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/scaling.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../providers/app_filter_provider.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<AppFilterProvider>();
    const categories = [
      null,
      'Productivity',
      'Social',
      'Video',
      'Game',
      'Audio',
      'Image',
      'News',
      'Maps',
      'Undefined',
    ];
    const platforms = [
      null,
      'Flutter',
      'React Native',
      'Xamarin',
      'Ionic',
      'Native or Others',
    ];

    return Scaffold(
      body: AppPage(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        children: [
          AppTopBar(
            title: 'Filters & Sort',
            leading: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, size: 32),
            ),
            trailing: TextButton(
              onPressed: filter.clear,
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterSection(
            title: 'App Type',
            child: Column(
              children: [
                _RadioOption(
                  label: 'All Apps',
                  selected: filter.type == AppTypeFilter.all,
                  onTap: () => filter.setType(AppTypeFilter.all),
                ),
                _RadioOption(
                  label: 'User Apps',
                  selected: filter.type == AppTypeFilter.user,
                  onTap: () => filter.setType(AppTypeFilter.user),
                ),
                _RadioOption(
                  label: 'System Apps',
                  selected: filter.type == AppTypeFilter.system,
                  onTap: () => filter.setType(AppTypeFilter.system),
                ),
                _RadioOption(
                  label: 'Launchable Apps Only',
                  selected: filter.launchableOnly,
                  onTap: () => filter.setLaunchableOnly(!filter.launchableOnly),
                ),
              ],
            ),
          ),
          _FilterSection(
            title: 'Sort By',
            child: Column(
              children: AppSort.values
                  .map(
                    (sort) => _RadioOption(
                      label: _sortLabel(sort),
                      selected: filter.sort == sort,
                      onTap: () => filter.setSort(sort),
                    ),
                  )
                  .toList(),
            ),
          ),
          _FilterSection(
            title: 'Package Prefix',
            child: TextField(
              onChanged: filter.setQuery,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'com.google',
                suffixIcon: Icon(Icons.cancel_rounded),
              ),
            ),
          ),
          _FilterSection(
            title: 'Platform Type',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: platforms
                  .map(
                    (platform) => _PillChoice(
                      label: platform ?? 'Native',
                      selected: platform == filter.platformType ||
                          (platform == null && filter.platformType == null),
                      onTap: () => filter.setPlatformType(platform),
                    ),
                  )
                  .toList(),
            ),
          ),
          _FilterSection(
            title: 'App Category',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories
                  .map(
                    (category) => _PillChoice(
                      label: category ?? 'All Categories',
                      selected: category == filter.category ||
                          (category == null && filter.category == null),
                      onTap: () => filter.setCategory(category),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          GradientButton(
            label: 'Apply Filters',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _sortLabel(AppSort sort) => switch (sort) {
        AppSort.nameAsc => 'Name (A - Z)',
        AppSort.nameDesc => 'Name (Z - A)',
        AppSort.installNewest => 'Install Date (Newest)',
        AppSort.installOldest => 'Install Date (Oldest)',
      };
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: SoftCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium.r),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color!,
                  width: 2,
                ),
              ),
              child: selected
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChoice extends StatelessWidget {
  const _PillChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : null,
          ),
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      color: WidgetStatePropertyAll(
        selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
    );
  }
}
