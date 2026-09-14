import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_design_widgets.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPage(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
        children: [AppTopBar(
            title: 'Privacy Policy',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left_rounded, size: 34),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Last updated: September 13, 2026',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'This Privacy Policy explains how AppScope handles information when you use our mobile application. AppScope is developed by EvoliX Technologies.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _PolicySection(
            title: '1. About AppScope',
            paragraphs: [
              'AppScope is an Android app management tool that helps users explore installed apps, system apps, user apps, package names, app details, and other app-related information available on their device.',
            ],
          ),
          const _PolicySection(
            title: '2. Information We Access',
            paragraphs: [
              'AppScope may access information about applications installed on your device in order to provide its core features. This may include:',
            ],
            bullets: [
              'Installed app names',
              'Package names',
              'App icons',
              'Version information',
              'App category or type, where available',
              'System app or user app status',
              'Installation and update information, where available',
            ],
            footer:
                'This information is used only to display app details and provide app management features inside AppScope.',
          ),
          const _PolicySection(
            title: '3. Personal Data Collection',
            paragraphs: [
              'AppScope does not require users to create an account and does not directly collect personal information such as your name, phone number, address, contacts, photos, messages, or email address.',
            ],
          ),
          const _PolicySection(
            title: '4. How We Use Information',
            paragraphs: [
              'The app information accessed by AppScope is used for the following purposes:',
            ],
            bullets: [
              'To show installed apps on your device',
              'To separate user apps and system apps',
              'To provide search and filtering features',
              'To show package and version details',
              'To help users launch apps quickly',
              'To provide app inspection and quick tools',
            ],
          ),
          const _PolicySection(
            title: '5. Data Sharing',
            paragraphs: [
              'AppScope does not sell, trade, or rent user information to third parties.',
              'AppScope does not upload your installed app list or app details to our servers unless such a feature is clearly introduced in a future version and disclosed in this Privacy Policy.',
            ],
          ),
          const _PolicySection(
            title: '6. Data Storage',
            paragraphs: [
              'AppScope primarily processes app information locally on your device. We do not maintain a remote database of your installed applications.',
            ],
          ),
          const _PolicySection(
            title: '7. Permissions',
            paragraphs: [
              'AppScope may use Android permissions or system APIs required to view and display installed application information. These permissions are used only for app management and inspection features.',
            ],
          ),
          const _PolicySection(
            title: '8. Third-Party Services',
            paragraphs: [
              'AppScope may include links to external pages such as our website, contact page, privacy policy, Play Store page, or open-source license pages. When you open external links, the privacy practices of those third-party websites or services may apply.',
              'If future versions of AppScope use analytics, crash reporting, advertising, or other third-party SDKs, this Privacy Policy will be updated accordingly.',
            ],
          ),
          const _PolicySection(
            title: "9. Children's Privacy",
            paragraphs: [
              'AppScope is not specifically directed to children under the age of 13. We do not knowingly collect personal information from children.',
            ],
          ),
          const _PolicySection(
            title: '10. Data Security',
            paragraphs: [
              'We take reasonable steps to protect user information. Since AppScope mainly processes app data locally on your device, users remain in control of their device and installed applications.',
            ],
          ),
          const _PolicySection(
            title: '11. Changes to This Privacy Policy',
            paragraphs: [
              'We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated "Last updated" date.',
            ],
          ),
          const _PolicySection(
            title: '12. Contact Us',
            paragraphs: [
              'If you have any questions about this Privacy Policy or AppScope, you can contact us at:',
            ],
          ),
          SoftCard(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EvoliX Technologies',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                const _ContactLine(label: 'Email', value: AppConstants.companyEmail),
                const SizedBox(height: AppSpacing.xs),
                const _ContactLine(
                  label: 'Website',
                  value: AppConstants.companyWebsite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.footer,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final paragraph in paragraphs) ...[
            Text(paragraph, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
          ],
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('- ', style: Theme.of(context).textTheme.bodyMedium),
                  Expanded(
                    child: Text(
                      bullet,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(footer!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
