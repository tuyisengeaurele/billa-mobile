import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/password_field.dart';

void main() {
  Widget host(TextEditingController controller) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: PasswordField(key: const Key('field'), controller: controller)),
      );

  bool obscured(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).obscureText;

  testWidgets('is hidden by default and the eye reveals and hides it again', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    expect(obscured(tester), isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(obscured(tester), isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(obscured(tester), isTrue);
  });

  testWidgets('keeps what was typed when the visibility changes', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    await tester.enterText(find.byType(TextField), 'Abcdef1!');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(controller.text, 'Abcdef1!');
  });
}
