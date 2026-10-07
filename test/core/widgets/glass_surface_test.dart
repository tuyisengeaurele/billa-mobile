import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_colors.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/platform/glass_support.dart';
import 'package:billa_mobile/core/widgets/glass_surface.dart';

Widget _host({required bool blur, ThemeData? theme, Widget? child}) => ProviderScope(
      overrides: [glassBlurEnabledProvider.overrideWithValue(blur)],
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        home: Scaffold(
          body: Center(
            child: GlassSurface(
              padding: const EdgeInsets.all(12),
              child: child ?? const Text('inside'),
            ),
          ),
        ),
      ),
    );

double _tintAlpha(WidgetTester tester) {
  final box = tester.widgetList<DecoratedBox>(find.descendant(of: find.byType(GlassSurface), matching: find.byType(DecoratedBox)))
      .map((d) => d.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((d) => d.color != null);
  return box.color!.a;
}

void main() {
  testWidgets('blurs what is behind it when the device can afford it', (tester) async {
    await tester.pumpWidget(_host(blur: true));

    expect(find.descendant(of: find.byType(GlassSurface), matching: find.byType(BackdropFilter)), findsOneWidget);
    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('falls back to a more opaque tint with no blur on weak devices', (tester) async {
    await tester.pumpWidget(_host(blur: true));
    final blurredAlpha = _tintAlpha(tester);

    await tester.pumpWidget(_host(blur: false));

    expect(find.descendant(of: find.byType(GlassSurface), matching: find.byType(BackdropFilter)), findsNothing);
    expect(_tintAlpha(tester), greaterThan(blurredAlpha));
  });

  testWidgets('uses the dark surface colour as its tint in the dark theme', (tester) async {
    await tester.pumpWidget(_host(blur: true, theme: AppTheme.dark));

    final decorations = tester
        .widgetList<DecoratedBox>(find.descendant(of: find.byType(GlassSurface), matching: find.byType(DecoratedBox)))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>();
    final tinted = decorations.firstWhere((d) => d.color != null);

    expect(tinted.color!.withValues(alpha: 1), AppColors.dark.surface.withValues(alpha: 1));
  });

  testWidgets('has a fine highlight edge and lays its child out inside the padding', (tester) async {
    await tester.pumpWidget(_host(blur: false));

    final decorations = tester
        .widgetList<DecoratedBox>(find.descendant(of: find.byType(GlassSurface), matching: find.byType(DecoratedBox)))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>();
    expect(decorations.any((d) => d.border != null), isTrue);

    final surfaceRect = tester.getRect(find.byType(GlassSurface));
    final textRect = tester.getRect(find.text('inside'));
    expect(textRect.left - surfaceRect.left, greaterThanOrEqualTo(12));
    expect(textRect.top - surfaceRect.top, greaterThanOrEqualTo(12));
  });
}
