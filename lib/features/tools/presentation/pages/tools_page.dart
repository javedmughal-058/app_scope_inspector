import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../providers/tools_provider.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final _packageController = TextEditingController();
  final _toastController = TextEditingController(text: 'Hello from AppScope');
  final _prefixController = TextEditingController(text: 'com.');
  String _platformSlug = 'flutter';

  @override
  void dispose() {
    _packageController.dispose();
    _toastController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToolsProvider>();

    return AppPage(
      children: [
        AppTopBar(
          title: AppConstants.shortName,
          subtitle: AppConstants.tagline,
          large: true,
          trailing: SoftIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Tool settings',
            onPressed: () => _message(context, 'Tool settings are handled per action.'),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Quick Tools', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Powerful tools to explore and manage Android apps on your device.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _packageController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.inventory_2_outlined, size: 20.h),
            hintText: 'Package name',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.95.h,
          children: [
            _ToolCard(
              icon: Icons.grid_view_rounded,
              gradient: AppGradients.blueCard,
              title: 'Get Installed Apps',
              subtitle: 'List all installed apps on your device.',
              onTap: provider.busy
                  ? null
                  : () => _message(context, 'Installed apps are shown in Apps.'),
            ),
            _ToolCard(
              icon: Icons.settings_rounded,
              gradient: AppGradients.purpleCard,
              title: 'Get System Apps',
              subtitle: 'List all system apps (pre-installed).',
              onTap: provider.busy
                  ? null
                  : () => _message(context, 'Use the System Apps tab.'),
            ),
            _ToolCard(
              icon: Icons.visibility_off_rounded,
              gradient: AppGradients.greenCard,
              title: 'Get Non-launchable Apps',
              subtitle: 'Find apps without a launchable activity.',
              onTap: provider.busy
                  ? null
                  : () => _message(context, 'Use launchable filtering.'),
            ),
            _ToolCard(
              icon: Icons.search_rounded,
              gradient: AppGradients.orangeCard,
              title: 'Filter by Package Prefix',
              subtitle: 'Filter apps by package name prefix.',
              onTap: provider.busy
                  ? null
                  : () => provider.filterByPrefix(_prefixController.text),
            ),
            _ToolCard(
              icon: Icons.layers_rounded,
              gradient: AppGradients.purpleCard,
              title: 'Filter by Platform Type',
              subtitle: 'Filter apps by platform type.',
              onTap: provider.busy
                  ? null
                  : () => provider.filterByPlatform(_platformSlug),
            ),
            _ToolCard(
              icon: Icons.check_rounded,
              gradient: AppGradients.greenCard,
              title: 'Check Is Installed',
              subtitle: 'Check if a package is installed.',
              onTap:
                  provider.busy ? null : () => provider.checkInstalled(_package),
            ),
            _ToolCard(
              icon: Icons.settings_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5C7A), Color(0xFFFF2B55)],
              ),
              title: 'Check Is System App',
              subtitle: 'Check if a package is a system app.',
              onTap: provider.busy ? null : () => provider.checkSystem(_package),
            ),
            _ToolCard(
              icon: Icons.description_rounded,
              gradient: AppGradients.blueCard,
              title: 'Get App Info',
              subtitle: 'View detailed information about an app.',
              onTap: provider.busy
                  ? null
                  : () => _message(context, 'Open an app from the Apps list.'),
            ),
            _ToolCard(
              icon: Icons.play_arrow_rounded,
              gradient: AppGradients.blueCard,
              title: 'Launch App',
              subtitle: 'Open any installed app instantly.',
              onTap: provider.busy ? null : () => provider.launch(_package),
            ),
            _ToolCard(
              icon: Icons.open_in_new_rounded,
              gradient: AppGradients.purpleCard,
              title: 'Open App Settings',
              subtitle: "Open the app's system settings page.",
              onTap: provider.busy ? null : () => provider.openSettings(_package),
            ),
            _ToolCard(
              icon: Icons.delete_outline_rounded,
              gradient: AppGradients.orangeCard,
              title: 'Uninstall App',
              subtitle: 'Use details screen for uninstall confirmation.',
              onTap: provider.busy
                  ? null
                  : () => _message(context, 'Open app details to uninstall safely.'),
            ),
            _ToolCard(
              icon: Icons.chat_bubble_outline_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6BAA), Color(0xFFF72585)],
              ),
              title: 'Show Toast Message',
              subtitle: 'Display a custom toast message.',
              onTap: provider.busy
                  ? null
                  : () => provider.toast(_toastController.text.trim()),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<String>(
          initialValue: _platformSlug,
          decoration: const InputDecoration(labelText: 'Platform type'),
          items: const [
            DropdownMenuItem(value: 'flutter', child: Text('Flutter')),
            DropdownMenuItem(value: 'react_native', child: Text('React Native')),
            DropdownMenuItem(value: 'xamarin', child: Text('Xamarin')),
            DropdownMenuItem(value: 'ionic', child: Text('Ionic')),
            DropdownMenuItem(
              value: 'native_or_others',
              child: Text('Native or Others'),
            ),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _platformSlug = value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _prefixController,
          decoration: const InputDecoration(hintText: 'Package prefix'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _toastController,
          decoration: const InputDecoration(hintText: 'Toast message'),
        ),
        if (provider.busy) ...[
          const SizedBox(height: AppSpacing.base),
          const LinearProgressIndicator(),
        ],
        if (provider.result != null) ...[
          const SizedBox(height: AppSpacing.base),
          SoftCard(
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(provider.result!)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String get _package => _packageController.text.trim();

  static void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GradientIconBox(icon: icon, gradient: gradient, size: 36),
                const Spacer(),
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
