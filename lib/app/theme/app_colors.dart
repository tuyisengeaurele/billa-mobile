import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary500,
    required this.primary100,
    required this.primary700,
    required this.accent,
    required this.secondary,
    required this.secondaryDeep,
    required this.neutral50,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.neutral900,
    required this.success,
    required this.successBg,
    required this.error,
    required this.errorBg,
    required this.warning,
    required this.warningBg,
    required this.surface,
    required this.surfaceHover,
    required this.page,
  });

  final Color primary500;
  final Color primary100;
  final Color primary700;

  /// The brand colour for things drawn on the page rather than filled: selected
  /// icons, focus rings, links. The filled pink is too dark to read on dark surfaces.
  final Color accent;
  final Color secondary;
  final Color secondaryDeep;
  final Color neutral50;
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;
  final Color neutral600;
  final Color neutral700;
  final Color neutral800;
  final Color neutral900;
  final Color success;
  final Color successBg;
  final Color error;
  final Color errorBg;
  final Color warning;
  final Color warningBg;
  final Color surface;
  final Color surfaceHover;
  final Color page;

  static const light = AppColors(
    primary500: Color(0xFFC2185B),
    primary100: Color(0xFFF6D7E4),
    primary700: Color(0xFF8F1144),
    accent: Color(0xFFC2185B),
    secondary: Color(0xFFE0F2FE),
    secondaryDeep: Color(0xFF0369A1),
    neutral50: Color(0xFFFAFAFA),
    neutral100: Color(0xFFF4F4F5),
    neutral200: Color(0xFFE4E4E7),
    neutral300: Color(0xFFD4D4D8),
    neutral400: Color(0xFFA1A1AA),
    neutral500: Color(0xFF6B6B74),
    neutral600: Color(0xFF52525B),
    neutral700: Color(0xFF3F3F46),
    neutral800: Color(0xFF27272A),
    neutral900: Color(0xFF18181B),
    success: Color(0xFF166534),
    successBg: Color(0xFFDCFCE7),
    error: Color(0xFFB91C1C),
    errorBg: Color(0xFFFEE2E2),
    warning: Color(0xFF92400E),
    warningBg: Color(0xFFFEF3C7),
    surface: Color(0xFFFFFFFF),
    surfaceHover: Color(0xFFFAFAFA),
    page: Color(0xFFFAFAFA),
  );

  // primary500 and secondary are deliberately absent from this list, the
  // spec keeps them identical to light mode, so they fall through to light's.
  static const dark = AppColors(
    primary500: Color(0xFFC2185B),
    primary100: Color(0xFF3D1428),
    primary700: Color(0xFFF472B6),
    accent: Color(0xFFF472B6),
    secondary: Color(0xFFE0F2FE),
    secondaryDeep: Color(0xFF7DD3FC),
    neutral50: Color(0xFF232326),
    neutral100: Color(0xFF2A2A2E),
    neutral200: Color(0xFF3F3F46),
    neutral300: Color(0xFF54545C),
    neutral400: Color(0xFF8B8B93),
    neutral500: Color(0xFF9F9FA6),
    neutral600: Color(0xFFB4B4BB),
    neutral700: Color(0xFFC7C7CD),
    neutral800: Color(0xFFE4E4E7),
    neutral900: Color(0xFFFAFAFA),
    success: Color(0xFF4ADE80),
    successBg: Color(0xFF0F2C1C),
    error: Color(0xFFF87171),
    errorBg: Color(0xFF3A1212),
    warning: Color(0xFFFBBF24),
    warningBg: Color(0xFF3A2705),
    surface: Color(0xFF1C1C1F),
    surfaceHover: Color(0xFF26262A),
    page: Color(0xFF131315),
  );

  @override
  AppColors copyWith({
    Color? primary500,
    Color? primary100,
    Color? primary700,
    Color? accent,
    Color? secondary,
    Color? secondaryDeep,
    Color? neutral50,
    Color? neutral100,
    Color? neutral200,
    Color? neutral300,
    Color? neutral400,
    Color? neutral500,
    Color? neutral600,
    Color? neutral700,
    Color? neutral800,
    Color? neutral900,
    Color? success,
    Color? successBg,
    Color? error,
    Color? errorBg,
    Color? warning,
    Color? warningBg,
    Color? surface,
    Color? surfaceHover,
    Color? page,
  }) {
    return AppColors(
      primary500: primary500 ?? this.primary500,
      primary100: primary100 ?? this.primary100,
      primary700: primary700 ?? this.primary700,
      accent: accent ?? this.accent,
      secondary: secondary ?? this.secondary,
      secondaryDeep: secondaryDeep ?? this.secondaryDeep,
      neutral50: neutral50 ?? this.neutral50,
      neutral100: neutral100 ?? this.neutral100,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral400: neutral400 ?? this.neutral400,
      neutral500: neutral500 ?? this.neutral500,
      neutral600: neutral600 ?? this.neutral600,
      neutral700: neutral700 ?? this.neutral700,
      neutral800: neutral800 ?? this.neutral800,
      neutral900: neutral900 ?? this.neutral900,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      page: page ?? this.page,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary500: Color.lerp(primary500, other.primary500, t)!,
      primary100: Color.lerp(primary100, other.primary100, t)!,
      primary700: Color.lerp(primary700, other.primary700, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryDeep: Color.lerp(secondaryDeep, other.secondaryDeep, t)!,
      neutral50: Color.lerp(neutral50, other.neutral50, t)!,
      neutral100: Color.lerp(neutral100, other.neutral100, t)!,
      neutral200: Color.lerp(neutral200, other.neutral200, t)!,
      neutral300: Color.lerp(neutral300, other.neutral300, t)!,
      neutral400: Color.lerp(neutral400, other.neutral400, t)!,
      neutral500: Color.lerp(neutral500, other.neutral500, t)!,
      neutral600: Color.lerp(neutral600, other.neutral600, t)!,
      neutral700: Color.lerp(neutral700, other.neutral700, t)!,
      neutral800: Color.lerp(neutral800, other.neutral800, t)!,
      neutral900: Color.lerp(neutral900, other.neutral900, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      page: Color.lerp(page, other.page, t)!,
    );
  }
}
