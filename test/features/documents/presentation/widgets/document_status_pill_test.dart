import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/document_status_pill.dart';

void main() {
  testWidgets('shows Draft for a draft document', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: DocumentStatusPill(status: DocumentStatus.draft)),
    ));
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('shows the payment status label for a finalized invoice', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: DocumentStatusPill(status: DocumentStatus.finalized, paymentStatus: PaymentStatus.partiallyPaid),
      ),
    ));
    expect(find.text('Partially paid'), findsOneWidget);
  });

  testWidgets('shows Finalized when there is no payment status', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: DocumentStatusPill(status: DocumentStatus.finalized)),
    ));
    expect(find.text('Finalized'), findsOneWidget);
  });
}
