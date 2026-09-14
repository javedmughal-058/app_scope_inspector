import 'dart:async';

import 'package:app_scope_inspector/core/utils/scaling.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_design_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: Stack(
          children: [
            const Positioned(
              top: 92,
              right: -44,
              child: _SplashBar(width: 360, height: 90),
            ),
            const Positioned(
              top: 315,
              left: -86,
              child: _SplashBar(width: 260, height: 82),
            ),
            const Positioned(
              bottom: 170,
              right: -70,
              child: _SplashBar(width: 300, height: 96),
            ),
            SafeArea(
              child: SizedBox.expand(
                child: Column(
                  children: [
                    const Spacer(flex: 4),
                    Image.asset(AssetPaths.appLogo, height: 112.h, width: 112.h),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      AppConstants.shortName,
                      style: AppTextStyles.splash.copyWith(
                        fontSize: AppSpacing.xxl,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppConstants.tagline,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(flex: 5),
                    Text(
                      'Powered by',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    const EvolixLogo(
                      height: 58,
                      tone: EvolixLogoTone.lightOnDark,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBar extends StatelessWidget {
  const _SplashBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.78,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.02),
              Colors.white.withValues(alpha: 0.11),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
