import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// The logo settles in (fade and a small scale) and then breathes with a soft
/// glow while the app is busy. Only the mark moves: the wordmark beside it is
/// left to the caller and stays still, so the screen reads as calm, not busy.
class AnimatedBrandMark extends StatefulWidget {
  const AnimatedBrandMark({super.key, this.size = 96});

  final double size;

  @override
  State<AnimatedBrandMark> createState() => _AnimatedBrandMarkState();
}

class _AnimatedBrandMarkState extends State<AnimatedBrandMark> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  late final Animation<double> _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    // Starting the glow after the entrance keeps the two motions from
    // competing for attention in the first half second.
    _intro.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary500.withValues(alpha: 0.10 + 0.16 * _pulse.value),
                  blurRadius: 24 + 20 * _pulse.value,
                  spreadRadius: 2 + 6 * _pulse.value,
                ),
              ],
            ),
            child: child,
          ),
          child: Image.asset('assets/logo.png', width: widget.size, height: widget.size, semanticLabel: 'Billa'),
        ),
      ),
    );
  }
}
