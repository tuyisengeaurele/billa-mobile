import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_colors.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/app_sheet.dart';
import 'package:billa_mobile/core/widgets/confirm_dialog.dart';
import 'package:billa_mobile/core/widgets/text_prompt_dialog.dart';

Widget _host(Future<void> Function(BuildContext) onTap) => MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(onPressed: () => onTap(context), child: const Text('Open')),
      ),
    );

void main() {
  testWidgets('a sheet slides up from the bottom of the screen', (tester) async {
    await tester.pumpWidget(_host((context) async {
      await showAppSheet<void>(context, builder: (context) => const SizedBox(height: 120, child: Text('content')));
    }));

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final early = tester.getTopLeft(find.text('content')).dy;
    await tester.pumpAndSettle();
    final settled = tester.getTopLeft(find.text('content')).dy;

    expect(early, greaterThan(settled));
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('shows a drag handle and rounded top corners from the theme', (tester) async {
    await tester.pumpWidget(_host((context) async {
      await showAppSheet<void>(context, builder: (context) => const Text('content'));
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.showDragHandle, isTrue);
    expect(tester.widget<Material>(find.descendant(of: find.byType(BottomSheet), matching: find.byType(Material)).first).shape,
        const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large))));
  });

  testWidgets('confirm returns true on confirm, false on cancel, and false when dismissed', (tester) async {
    bool? result;
    await tester.pumpWidget(_host((context) async {
      result = await showConfirmDialog(context, title: 'Sure?', content: 'It cannot be undone.', confirmLabel: 'Yes');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('It cannot be undone.'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('a destructive confirm uses the error colour', (tester) async {
    await tester.pumpWidget(_host((context) async {
      await showConfirmDialog(context, title: 'Delete?', confirmLabel: 'Delete', destructive: true);
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Delete'));
    expect(button.style?.backgroundColor?.resolve({}), AppColors.light.error);
  });

  testWidgets('the text prompt keeps confirm disabled until something is typed, then returns trimmed text',
      (tester) async {
    String? result;
    await tester.pumpWidget(_host((context) async {
      result = await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Create')).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  New Co  ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(result, 'New Co');
  });

  testWidgets('the text prompt returns null on cancel', (tester) async {
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

  testWidgets('sheet content moves up with the keyboard', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host((context) async {
      await showTextPromptDialog(context, title: 'Name', label: 'Business name', confirmLabel: 'Create');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final bottom = tester.getBottomLeft(find.text('Create')).dy;
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;

    expect(bottom, lessThan(screenHeight - 300));
  });
}
