import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_colors.dart';

void main() {
  test('light tokens match the design spec exactly', () {
    expect(AppColors.light.primary500, const Color(0xFFC2185B));
    expect(AppColors.light.primary100, const Color(0xFFF6D7E4));
    expect(AppColors.light.primary700, const Color(0xFF8F1144));
    expect(AppColors.light.secondary, const Color(0xFFE0F2FE));
    expect(AppColors.light.secondaryDeep, const Color(0xFF0369A1));
    expect(AppColors.light.neutral900, const Color(0xFF18181B));
    expect(AppColors.light.success, const Color(0xFF166534));
    expect(AppColors.light.errorBg, const Color(0xFFFEE2E2));
    expect(AppColors.light.surface, const Color(0xFFFFFFFF));
    expect(AppColors.light.page, const Color(0xFFFAFAFA));
  });

  test('dark tokens override only what the spec lists as changed', () {
    expect(AppColors.dark.primary500, AppColors.light.primary500);
    expect(AppColors.dark.secondary, AppColors.light.secondary);
    expect(AppColors.dark.primary100, const Color(0xFF3D1428));
    expect(AppColors.dark.primary700, const Color(0xFFF472B6));
    expect(AppColors.dark.successBg, const Color(0xFF0F2C1C));
    expect(AppColors.dark.page, const Color(0xFF131315));
    expect(AppColors.dark.surface, const Color(0xFF1C1C1F));
  });

  test('copyWith overrides only the requested field', () {
    final copy = AppColors.light.copyWith(primary500: Colors.black);
    expect(copy.primary500, Colors.black);
    expect(copy.neutral900, AppColors.light.neutral900);
  });

  test('lerp at t=0 returns the start, at t=1 returns the end', () {
    final start = AppColors.light.lerp(AppColors.dark, 0);
    final end = AppColors.light.lerp(AppColors.dark, 1);
    expect(start.page, AppColors.light.page);
    expect(end.page, AppColors.dark.page);
  });
}
