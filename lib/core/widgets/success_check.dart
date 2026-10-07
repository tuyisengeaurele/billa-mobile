import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

/// A brief confirmation for actions that matter (finalize, record payment):
/// a light haptic and a check that scales in and fades out on its own. It is
/// driven by an animation controller rather than a timer so it settles under
/// test and never leaves a pending timer behind.
Future<void> showSuccessCheck(BuildContext context) {
  HapticFeedback.lightImpact();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => const _SuccessCheck(),
  );
}

class _SuccessCheck extends StatefulWidget {
  const _SuccessCheck();

  @override
  State<_SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<_SuccessCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward().whenComplete(() {
      if (mounted) Navigator.of(context).pop();
    });

  late final Animation<double> _scale = Tween(begin: 0.6, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4, curve: Curves.easeOutBack)),
  );

  late final Animation<double> _opacity = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Semantics(
            label: 'Done',
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: colors.successBg, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, size: 48, color: colors.success),
            ),
          ),
        ),
      ),
    );
  }
}
