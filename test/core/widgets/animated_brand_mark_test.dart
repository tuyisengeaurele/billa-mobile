import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/animated_brand_mark.dart';

void main() {
  Widget host() => MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: AnimatedBrandMark())),
      );

  double opacity(WidgetTester tester) =>
      tester.widget<FadeTransition>(find.descendant(of: find.byType(AnimatedBrandMark), matching: find.byType(FadeTransition))).opacity.value;

  testWidgets('fades and scales in, then keeps showing the logo', (tester) async {
    await tester.pumpWidget(host());

    expect(find.byType(Image), findsOneWidget);
    expect(opacity(tester), lessThan(0.1));

    await tester.pump(const Duration(milliseconds: 700));

    expect(opacity(tester), 1.0);
  });

  testWidgets('keeps a soft glow pulsing after the entrance without ever leaving the screen', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.hasRunningAnimations, isTrue);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('is removed cleanly while animating', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.pumpWidget(const SizedBox());

    expect(tester.takeException(), isNull);
  });
}
