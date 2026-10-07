import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billa_mobile/app/theme/app_colors.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/app/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('light and dark themes expose the matching AppColors extension', () {
    expect(AppTheme.light.extension<AppColors>(), AppColors.light);
    expect(AppTheme.dark.extension<AppColors>(), AppColors.dark);
  });

  test('light and dark themes use the correct brightness and page color', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.light.page);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.dark.page);
  });

  test('both themes use shared-axis page transitions on Android and iOS', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        expect(theme.pageTransitionsTheme.builders[platform], isA<SharedAxisPageTransitionsBuilder>());
      }
    }
  });

  test('display styles use Fraunces and body styles use Plus Jakarta Sans', () {
    // GoogleFonts appends a weight suffix to the family name when it loads a
    // specific weight variant (e.g. "Fraunces_600"), so match the prefix.
    final textTheme = AppTypography.textTheme(Brightness.light);
    expect(textTheme.displayLarge!.fontFamily, startsWith('Fraunces'));
    expect(textTheme.headlineSmall!.fontFamily, startsWith('Fraunces'));
    expect(textTheme.bodyLarge!.fontFamily, startsWith('PlusJakartaSans'));
    expect(textTheme.labelLarge!.fontFamily, startsWith('PlusJakartaSans'));
  });

  test('inputs are filled and rounded, with an accent outline on focus', () {
    for (final (theme, colors) in [(AppTheme.light, AppColors.light), (AppTheme.dark, AppColors.dark)]) {
      final input = theme.inputDecorationTheme;
      expect(input.filled, isTrue);
      expect(input.fillColor, colors.neutral100);
      expect((input.focusedBorder as OutlineInputBorder).borderSide.color, colors.primary500);
    }
  });
}
