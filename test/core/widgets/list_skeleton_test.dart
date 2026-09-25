import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/list_skeleton.dart';

void main() {
  testWidgets('sits at the top of the space instead of floating in the middle', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const Scaffold(body: ListSkeleton())));

    expect(tester.getTopLeft(find.byType(ListSkeleton).first).dy, 0);
    final firstRow = tester.getTopLeft(find.byType(Row).first).dy;
    expect(firstRow, lessThan(60));
  });

  testWidgets('can be pulled down while loading', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const Scaffold(body: ListSkeleton())));

    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    expect(scroll.physics, isA<AlwaysScrollableScrollPhysics>());
  });
}
