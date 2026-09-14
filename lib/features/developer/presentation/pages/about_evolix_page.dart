import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';

class AboutEvolixPage extends StatelessWidget {
  const AboutEvolixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        children: [
          AppTopBar(
            title: 'About Evolix',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left_rounded, size: 34),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SoftCard(
            background: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
            padding: const EdgeInsets.all(AppSpacing.base),
            child: const EvolixLogo(height: 62),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppConstants.companyName,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'We build innovative digital solutions that empower businesses and individuals. Our focus is on creating useful, reliable and modern technology products and experiences.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SoftCard(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                _ContactTile(
                  icon: Icons.language_rounded,
                  title: 'Our Website',
                  subtitle: AppConstants.companyWebsite,
                ),
                _ContactTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: AppConstants.companyEmail,
                ),
                _ContactTile(
                  icon: Icons.location_on_rounded,
                  title: 'Location',
                  subtitle: AppConstants.companyLocation,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Follow Us', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.base),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SocialButton(label: 'in', color: Color(0xFF0077B5)),
              _SocialButton(label: 'X', color: Color(0xFF050A1D)),
              _SocialButton(label: '◎', color: Color(0xFFE1306C)),
              _SocialButton(label: 'f', color: Color(0xFF175CFF)),
              _SocialButton(label: '▶', color: Color(0xFFFF2B2B)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          GradientButton(
            label: 'Let’s Build Tomorrow Together',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppConstants.companyEmail)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: GradientIconBox(
            icon: icon,
            gradient: AppGradients.blueCard,
            size: 36,
            iconSize: 18,
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleSmall),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
