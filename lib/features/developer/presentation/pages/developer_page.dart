import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';
import 'about_evolix_page.dart';
import 'privacy_policy_page.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key, required this.openSettings});

  final VoidCallback openSettings;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        const AppTopBar(title: 'Developer'),
        const SizedBox(height: AppSpacing.xl),
        SoftCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          background: Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
          child: Column(
            children: [
              const EvolixLogo(height: 42),
              const SizedBox(height: AppSpacing.base),
              Text(
                AppConstants.shortName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Version ${AppConstants.version}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'A powerful tool to explore, manage, and understand installed applications on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        SoftCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              _DeveloperMenuTile(
                icon: Icons.description_outlined,
                title: 'About Evolix Technologies',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutEvolixPage()),
                ),
              ),
              _DeveloperMenuTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                onTap: openSettings,
              ),
              _DeveloperMenuTile(
                icon: Icons.language_rounded,
                title: 'Visit Our Website',
                onTap: () => _message(context, AppConstants.companyWebsite),
              ),
              _DeveloperMenuTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Contact Us',
                onTap: () => _message(context, AppConstants.companyEmail),
              ),
              _DeveloperMenuTile(
                icon: Icons.star_border_rounded,
                title: 'Rate on Play Store',
                onTap: () => _message(context, 'Play Store rating link pending.'),
              ),
              _DeveloperMenuTile(
                icon: Icons.share_outlined,
                title: 'Share App',
                onTap: () => _message(context, 'Share integration pending.'),
              ),
              _DeveloperMenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy Policy',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                ),
              ),
              _DeveloperMenuTile(
                icon: Icons.code_rounded,
                title: 'Open Source Licenses',
                showDivider: false,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConstants.shortName,
                  applicationVersion: AppConstants.version,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        Center(
          child: Column(
            children: [
              Text(
                'Developed with love by',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppConstants.companyName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Innovation for a Smarter Tomorrow',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _DeveloperMenuTile extends StatelessWidget {
  const _DeveloperMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          dense: true,
          leading: GradientIconBox(
            icon: icon,
            gradient: AppGradients.blueCard,
            size: 36,
            iconSize: 18,
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleSmall),
          trailing: Icon(Icons.chevron_right_rounded, size: 26.h, color: Theme.of(context).iconTheme.color),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 50.w),
            child: Divider(color: Theme.of(context).dividerColor),
          ),
      ],
    );
  }
}
