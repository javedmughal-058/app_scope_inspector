import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/device_app.dart';
import '../../domain/usecases/app_use_cases.dart';
import '../providers/app_filter_provider.dart';
import '../providers/installed_apps_provider.dart';
import '../widgets/installed_app_tile.dart';
import 'filters_page.dart';

class InstalledAppsPage extends StatefulWidget {
  const InstalledAppsPage({super.key, required this.openDetails});

  final void Function(String packageName) openDetails;

  @override
  State<InstalledAppsPage> createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _lastIconWindowKey;

  static const double _estimatedRowExtent = 112;
  static const int _iconBufferRows = 8;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scheduleVisibleIconLoad);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsProvider = context.watch<InstalledAppsProvider>();
    final filter = context.watch<AppFilterProvider>();
    final visible = filter.apply(appsProvider.apps);
    final hasActiveFilters = filter.hasActiveFilters;

    if (_searchController.text != filter.query) {
      _searchController.value = TextEditingValue(
        text: filter.query,
        selection: TextSelection.collapsed(offset: filter.query.length),
      );
    }

    _scheduleVisibleIconLoad(visible);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Column(
              children: [
                AppTopBar(
                  title: 'Installed Apps (${appsProvider.totalApps})',
                  leading: IconButton(
                    tooltip: 'Refresh apps',
                    onPressed: appsProvider.refresh,
                    icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  ),
                  trailing: IconButton(
                    tooltip: 'More options',
                    onPressed: appsProvider.refresh,
                    icon: const Icon(Icons.more_vert_rounded, size: 30),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Row(
                  children: [
                    Expanded(
                      child: _TypeSegment(
                        label: 'All',
                        value: AppTypeFilter.all,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _TypeSegment(
                        label: 'User Apps',
                        value: AppTypeFilter.user,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _TypeSegment(
                        label: 'System Apps',
                        value: AppTypeFilter.system,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: context.read<AppFilterProvider>().setQuery,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded, size: 26.h),
                          hintText: 'Search apps...',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      height: 56.h,
                      width: 56.h,
                      child: SoftCard(
                        background: hasActiveFilters
                          ? Theme.of(context).colorScheme.primary
                          : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: context.read<AppFilterProvider>(),
                              child: const FiltersPage(),
                            ),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.filter_alt_outlined,
                          color: !hasActiveFilters
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          size: 26.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: switch (appsProvider.status) {
            LoadStatus.initial || LoadStatus.loading => const AppLoadingView(),
            LoadStatus.failure => AppErrorView(
                message: appsProvider.errorMessage ?? 'Unknown error',
                onRetry: appsProvider.refresh,
              ),
            LoadStatus.empty => const AppEmptyView(
                title: 'No apps available',
                message: 'No installed applications were returned by Android.',
              ),
            LoadStatus.success when visible.isEmpty => const AppEmptyView(
                title: 'No matching apps',
                message: 'Try changing your search or filters.',
              ),
            LoadStatus.success => RefreshIndicator(
                onRefresh: appsProvider.refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 122),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final app = visible[index];
                    final start = context.read<StartAppUseCase>();
                    final settings = context.read<OpenAppSettingsUseCase>();
                    return InstalledAppTile(
                      app: app,
                      onTap: () => widget.openDetails(app.packageName),
                      onLaunch: () => start(app.packageName),
                      onSettings: () => settings(app.packageName),
                    );
                  },
                ),
              ),
          },
        ),
      ],
    );
  }

  void _scheduleVisibleIconLoad([List<DeviceApp>? currentVisible]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appsProvider = context.read<InstalledAppsProvider>();
      final visible = currentVisible ??
          context.read<AppFilterProvider>().apply(appsProvider.apps);
      _loadVisibleIcons(visible);
    });
  }

  void _loadVisibleIcons(List<DeviceApp> visible) {
    if (visible.isEmpty) return;

    final viewport = _scrollController.hasClients
        ? _scrollController.position.viewportDimension
        : MediaQuery.of(context).size.height;
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final firstVisible = (offset / _estimatedRowExtent).floor();
    final visibleCount = (viewport / _estimatedRowExtent).ceil();
    final start = (firstVisible - _iconBufferRows).clamp(0, visible.length).toInt();
    final end = (firstVisible + visibleCount + _iconBufferRows).clamp(0, visible.length).toInt();
    final firstPackage = start < visible.length ? visible[start].packageName : '';
    final lastPackage = end > start ? visible[end - 1].packageName : '';
    final key = '$start:$end:${visible.length}:$firstPackage:$lastPackage';

    if (_lastIconWindowKey == key) return;
    _lastIconWindowKey = key;

    context.read<InstalledAppsProvider>().loadIconsForPackages(
          visible.sublist(start, end),
        );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({required this.label, required this.value});

  final String label;
  final AppTypeFilter value;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppFilterProvider, bool>(
      (provider) => provider.type == value,
    );

    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.read<AppFilterProvider>().setType(value),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 42.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? Colors.white : null,
                ),
          ),
        ),
      ),
    );
  }
}
