import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/empty_state.dart';

void main() {
  testWidgets('shows the icon, message, and a working primary action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No customers yet',
        actionLabel: 'Add customer',
        onAction: () => tapped = true,
      ),
    ));

    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.text('No customers yet'), findsOneWidget);
    await tester.tap(find.text('Add customer'));
    expect(tapped, isTrue);
  });

  testWidgets('renders with no button when no action is given', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const EmptyState(icon: Icons.description_outlined, message: 'No documents yet'),
    ));

    expect(find.text('No documents yet'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
