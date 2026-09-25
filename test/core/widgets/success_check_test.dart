import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/success_check.dart';

void main() {
  testWidgets('shows a check with a light haptic, then closes itself', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    var finished = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showSuccessCheck(context).then((_) => finished = true),
          child: const Text('Go'),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(haptics, ['HapticFeedbackType.lightImpact']);
    expect(finished, isFalse);

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(finished, isTrue);
  });
}
