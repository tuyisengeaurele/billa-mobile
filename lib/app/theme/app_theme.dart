import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppRadii {
  static const double small = 8;
  static const double large = 12;
}

class AppTheme {
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
    );
  }

  static final ThemeData light = _base(AppColors.light, Brightness.light);
  static final ThemeData dark = _base(AppColors.dark, Brightness.dark);
}
