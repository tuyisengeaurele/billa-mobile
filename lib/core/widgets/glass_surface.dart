import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../platform/glass_support.dart';

/// A translucent material in the spirit of iOS "liquid glass": it lets what is
/// behind it show through, softened by a blur where the device can afford one,
/// with a fine highlight edge and a soft shadow that lift it off the content.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.padding = EdgeInsets.zero,
    this.blurSigma = 24,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final blur = ref.watch(glassBlurEnabledProvider);

    // Without a blur the tint has to do the job of keeping text legible over
    // busy content, so it is much more opaque.
    final base = dark ? colors.surface : Colors.white;
    final tint = base.withValues(alpha: blur ? (dark ? 0.55 : 0.70) : 0.94);
    final edge = Colors.white.withValues(alpha: dark ? 0.10 : 0.70);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: borderRadius,
        border: Border.all(color: edge),
      ),
      child: Padding(padding: padding, child: child),
    );

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.35 : 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: blur ? BackdropFilter(filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma), child: surface) : surface,
        ),
      ),
    );
  }
}
