import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Scaffold(
      body: AppPage(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        children: [
          AppTopBar(
            title: 'Appearance',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left_rounded, size: 34),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Theme Mode',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose how AppScope should look across all screens.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          _ThemeOption(
            icon: Icons.phone_android_rounded,
            title: 'System Default',
            subtitle: 'Follow the Android device setting',
            value: ThemeMode.system,
            current: provider.themeMode,
          ),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            title: 'Light',
            subtitle: 'Use the bright AppScope theme',
            value: ThemeMode.light,
            current: provider.themeMode,
          ),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            title: 'Dark',
            subtitle: 'Use the deep navy AppScope theme',
            value: ThemeMode.dark,
            current: provider.themeMode,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.current,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SoftCard(
        onTap: () => context.read<ThemeProvider>().setThemeMode(value),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            GradientIconBox(
              icon: icon,
              gradient: selected ? AppGradients.primary : AppGradients.blueCard,
              size: 36,
              iconSize: 18,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: current,
              onChanged: (mode) {
                if (mode != null) {
                  context.read<ThemeProvider>().setThemeMode(mode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
