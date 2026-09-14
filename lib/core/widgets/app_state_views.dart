import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message = 'Loading applications...'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.base),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({super.key, required this.title, required this.message, this.icon = Icons.apps_outlined});
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52.h),
            const SizedBox(height: AppSpacing.base),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.base),
            Text('Could not load apps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
