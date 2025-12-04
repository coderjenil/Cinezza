import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';

class CommonShimmer extends StatelessWidget {
  final Widget child;
  final Duration period;
  final bool enabled;
  final double colorOpacity;

  const CommonShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1600),
    this.enabled = true,
    this.colorOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Shimmer.fromColors(
      // 🔥 Premium Royal Base Color (Dark navy with slight transparency)
      baseColor: const Color(0xFF0D1B2A).withValues(alpha: 0.08),

      // 🔥 Light Royal Highlight (Soft blue highlight)
      // highlightColor: const Color(0xFF2979FF).withMyOpacity(0.1),
      highlightColor: const Color(0xFFFFFFFF).withValues(alpha: colorOpacity),

      // Ultra smooth timing for premium feel
      period: period,

      // Premium easing direction
      direction: ShimmerDirection.ltr,

      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.1), // Your theme color
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}