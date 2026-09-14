import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/asset_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../utils/scaling.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 18, 24, 120),
    this.scrollable = true,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    if (!scrollable) {
      return SafeArea(bottom: false, child: child);
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [child],
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.large = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = large ? theme.textTheme.displayMedium : theme.textTheme.headlineLarge;
    const sideWidth = 54.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            SizedBox(
              width: sideWidth.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: leading,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: sideWidth.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sideWidth.w),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum EvolixLogoTone { auto, lightOnDark, darkOnLight }

class EvolixLogo extends StatelessWidget {
  const EvolixLogo({
    super.key,
    required this.height,
    this.tone = EvolixLogoTone.auto,
    this.fit = BoxFit.contain,
  });

  final double height;
  final EvolixLogoTone tone;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTone = tone == EvolixLogoTone.auto
        ? (isDark ? EvolixLogoTone.lightOnDark : EvolixLogoTone.darkOnLight)
        : tone;

    return Image.asset(
      resolvedTone == EvolixLogoTone.lightOnDark
          ? AssetPaths.evolixLogo
          : AssetPaths.evolixLogoBlack,
      height: height.h,
      fit: fit,
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.background,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.card.r),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.forBrightness(theme.brightness),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card.r),
        child: card,
      ),
    );
  }
}

class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class GradientIconBox extends StatelessWidget {
  const GradientIconBox({
    super.key,
    required this.icon,
    this.gradient = AppGradients.primary,
    this.size = 58,
    this.iconSize = 28,
  });

  final IconData icon;
  final Gradient gradient;
  final double size;
  final double iconSize;

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
      child: Icon(icon, color: Colors.white, size: iconSize.r),
    );
  }
}

class SvgIconBox extends StatelessWidget {
  const SvgIconBox({
    super.key,
    required this.asset,
    this.gradient = AppGradients.primary,
    this.size = 58,
  });

  final String asset;
  final Gradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      padding: EdgeInsets.all((size * 0.26).r),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular((size * 0.26).r),
      ),
      child: SvgPicture.asset(
        asset,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.large.r),
        child: Ink(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadius.large.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, color: Colors.white, size: 18.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
