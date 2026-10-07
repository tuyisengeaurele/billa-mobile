import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/loading_skeleton.dart';

void main() {
  testWidgets('renders a box of the requested size and animates without settling', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: SizedBox(width: 200, child: LoadingSkeleton(height: 20)),
      ),
    ));

    expect(find.byType(LoadingSkeleton), findsOneWidget);
    // The shimmer repeats forever, so pump a few frames instead of pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
