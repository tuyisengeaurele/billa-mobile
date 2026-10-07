import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021(platform: TargetPlatform.android).white
        : Typography.material2021(platform: TargetPlatform.android).black;

    return base.copyWith(
      displayLarge: GoogleFonts.fraunces(textStyle: base.displayLarge, fontWeight: FontWeight.w600),
      displayMedium: GoogleFonts.fraunces(textStyle: base.displayMedium, fontWeight: FontWeight.w600),
      displaySmall: GoogleFonts.fraunces(textStyle: base.displaySmall, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.fraunces(textStyle: base.headlineLarge, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.fraunces(textStyle: base.headlineMedium, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.fraunces(textStyle: base.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.plusJakartaSans(textStyle: base.titleLarge, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.plusJakartaSans(textStyle: base.titleMedium, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.plusJakartaSans(textStyle: base.titleSmall, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.plusJakartaSans(textStyle: base.bodyLarge),
      bodyMedium: GoogleFonts.plusJakartaSans(textStyle: base.bodyMedium),
      bodySmall: GoogleFonts.plusJakartaSans(textStyle: base.bodySmall),
      labelLarge: GoogleFonts.plusJakartaSans(textStyle: base.labelLarge, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.plusJakartaSans(textStyle: base.labelMedium),
      labelSmall: GoogleFonts.plusJakartaSans(textStyle: base.labelSmall),
    );
  }
}
