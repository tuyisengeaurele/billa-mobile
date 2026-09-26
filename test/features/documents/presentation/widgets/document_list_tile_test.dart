import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/document_list_tile.dart';

const _customer = DocumentCustomerRef(name: 'Acme');
const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: _customer,
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 1800,
  total: 11800,
  amountPaid: 0,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  testWidgets('shows the document number, type, customer, and total', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: _document, onTap: () {})),
    ));

    expect(find.text('INV-0001'), findsOneWidget);
    expect(find.textContaining('Acme'), findsOneWidget);
    expect(find.text('RWF 11,800'), findsOneWidget);
  });

  testWidgets('shows "Draft <Type>" when the document has no number yet', (tester) async {
    const draft = Document(
      id: 'd2',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: draft, onTap: () {})),
    ));

    expect(find.text('Draft Invoice'), findsOneWidget);
  });

  testWidgets('with actions given, swiping right duplicates and swiping left contacts', (tester) async {
    var duplicated = 0;
    var contacted = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: DocumentListTile(
          document: _document,
          onTap: () {},
          onDuplicate: () => duplicated++,
          onContact: () => contacted++,
        ),
      ),
    ));

    await tester.drag(find.text('INV-0001'), const Offset(400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-swipe-duplicate-d1')));
    await tester.pumpAndSettle();
    await tester.drag(find.text('INV-0001'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-swipe-contact-d1')));
    await tester.pumpAndSettle();

    expect(duplicated, 1);
    expect(contacted, 1);
  });

  testWidgets('without actions the tile does not swipe', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: DocumentListTile(document: _document, onTap: () {})),
    ));

    expect(find.byKey(const Key('document-swipe-duplicate-d1')), findsNothing);
  });
}
