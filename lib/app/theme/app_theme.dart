import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppRadii {
  static const double small = 8;
  static const double large = 12;
}

class AppTheme {
  // Filled, softly rounded fields with a single accent outline on focus: the
  // fill carries the shape, so there is no border noise at rest.
  static InputDecorationTheme _inputTheme(AppColors colors) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.neutral100,
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(colors.primary500, 1.5),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ThemeData _base(AppColors colors, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.page,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary500,
        brightness: brightness,
      ).copyWith(surface: colors.surface),
      textTheme: AppTypography.textTheme(brightness),
      extensions: [colors],
      inputDecorationTheme: _inputTheme(colors),
      // Forward pushes move along one axis so depth reads as "deeper into the
      // app", matching the same motion on both platforms.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
        TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
      }),
    );
  }

  static final ThemeData light = _base(AppColors.light, Brightness.light);
  static final ThemeData dark = _base(AppColors.dark, Brightness.dark);
}
