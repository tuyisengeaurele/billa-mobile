import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  test('every font file the theme asks for is bundled, so nothing is downloaded at runtime', () async {
    for (final name in [
      'Fraunces-SemiBold',
      'PlusJakartaSans-Regular',
      'PlusJakartaSans-Medium',
      'PlusJakartaSans-SemiBold',
      'PlusJakartaSans-Bold',
    ]) {
      final data = await rootBundle.load('assets/google_fonts/$name.ttf');
      expect(data.lengthInBytes, greaterThan(10000), reason: name);
    }
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

  test('inputs are filled and rounded with the label inside, and an accent underline on focus', () {
    for (final (theme, colors) in [(AppTheme.light, AppColors.light), (AppTheme.dark, AppColors.dark)]) {
      final input = theme.inputDecorationTheme;
      expect(input.filled, isTrue);
      expect(input.fillColor, colors.neutral100);

      final rest = input.enabledBorder as UnderlineInputBorder;
      expect(rest.borderSide, BorderSide.none);
      expect(rest.borderRadius, BorderRadius.circular(AppRadii.large));

      final focused = input.focusedBorder as UnderlineInputBorder;
      expect(focused.borderSide.color, colors.primary500);
      expect(focused.borderSide.width, 2);
    }
  });

  test('the app bar is neutral: page colour, no tint, no elevation', () {
    for (final (theme, colors) in [(AppTheme.light, AppColors.light), (AppTheme.dark, AppColors.dark)]) {
      final bar = theme.appBarTheme;
      expect(bar.backgroundColor, colors.page);
      expect(bar.surfaceTintColor, Colors.transparent);
      expect(bar.elevation, 0);
      expect(bar.scrolledUnderElevation, 0);
      expect(bar.foregroundColor, colors.neutral900);
    }
  });
}
