import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_colors.dart';

double _ratio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, c) in [('light', AppColors.light), ('dark', AppColors.dark)]) {
    group('$name theme', () {
      test('body and secondary text reach 4.5:1 on the page, surfaces and filled fields', () {
        for (final text in [c.neutral900, c.neutral800, c.neutral700, c.neutral600, c.neutral500]) {
          for (final background in [c.page, c.surface, c.neutral50, c.neutral100]) {
            expect(_ratio(text, background), greaterThanOrEqualTo(4.5), reason: '$text on $background');
          }
        }
      });

      test('status text reaches 4.5:1 on its own tinted background', () {
        expect(_ratio(c.error, c.errorBg), greaterThanOrEqualTo(4.5));
        expect(_ratio(c.success, c.successBg), greaterThanOrEqualTo(4.5));
        expect(_ratio(c.warning, c.warningBg), greaterThanOrEqualTo(4.5));
        expect(_ratio(c.neutral800, c.warningBg), greaterThanOrEqualTo(4.5));
      });

      test('the accent used for selected icons, focus rings and links reaches 3:1', () {
        expect(_ratio(c.accent, c.page), greaterThanOrEqualTo(3));
        expect(_ratio(c.accent, c.surface), greaterThanOrEqualTo(3));
      });

      test('accent text on the tinted accent background reaches 4.5:1', () {
        expect(_ratio(c.primary700, c.primary100), greaterThanOrEqualTo(4.5));
      });

      test('the icons that mark navigation, such as chevrons, reach 3:1', () {
        expect(_ratio(c.neutral500, c.page), greaterThanOrEqualTo(3));
        expect(_ratio(c.neutral500, c.neutral50), greaterThanOrEqualTo(3));
      });
    });
  }

  test('white text on the brand gradient reaches 4.5:1 at both ends', () {
    expect(_ratio(Colors.white, AppColors.light.primary500), greaterThanOrEqualTo(4.5));
    expect(_ratio(Colors.white, AppColors.light.primary700), greaterThanOrEqualTo(4.5));
  });
}
