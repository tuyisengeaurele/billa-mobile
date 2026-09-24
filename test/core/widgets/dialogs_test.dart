import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/confirm_dialog.dart';
import 'package:billa_mobile/core/widgets/text_prompt_dialog.dart';

Widget _host(Future<void> Function(BuildContext) onTap) => MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(onPressed: () => onTap(context), child: const Text('Open')),
      ),
    );

void main() {
  testWidgets('confirm dialog returns true on confirm and false on cancel', (tester) async {
    bool? result;
    await tester.pumpWidget(_host((context) async {
      result = await showConfirmDialog(context, title: 'Sure?', confirmLabel: 'Yes');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('text prompt keeps confirm disabled until something is typed, then returns the trimmed text',
      (tester) async {
    String? result;
    await tester.pumpWidget(_host((context) async {
      result = await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Create')).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  New Co  ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(result, 'New Co');
  });

  testWidgets('text prompt returns null on cancel', (tester) async {
    String? result = 'unset';
    await tester.pumpWidget(_host((context) async {
      result = await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
