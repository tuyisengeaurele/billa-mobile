import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppRadii {
  static const double small = 8;
  static const double large = 12;
}

class AppTheme {
  // Material 3 filled fields: the label floats inside the box instead of
  // straddling its edge, so it can never collide with the error line of the
  // field above. The fill carries the shape; focus adds a curved accent line.
  static InputDecorationTheme _inputTheme(AppColors colors) {
    UnderlineInputBorder border(BorderSide side) => UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
          borderSide: side,
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.neutral100,
      border: border(BorderSide.none),
      enabledBorder: border(BorderSide.none),
      focusedBorder: border(BorderSide(color: colors.primary500, width: 2)),
      errorBorder: border(BorderSide(color: colors.error)),
      focusedErrorBorder: border(BorderSide(color: colors.error, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // The default app bar picks up a tint from the seed colour when content
  // scrolls under it, which turns the dark theme's bar maroon. Keeping it the
  // page colour makes it read as part of the screen, not a coloured band.
  static AppBarTheme _appBarTheme(AppColors colors, Brightness brightness) {
    return AppBarTheme(
      backgroundColor: colors.page,
      foregroundColor: colors.neutral900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.textTheme(brightness).headlineSmall?.copyWith(color: colors.neutral900),
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
      appBarTheme: _appBarTheme(colors, brightness),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.neutral300,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large))),
      ),
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
