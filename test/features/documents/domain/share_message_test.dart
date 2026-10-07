import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/currency.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/share_message.dart';

void main() {
  test('builds the customer-facing link from the origin and token', () {
    expect(publicDocumentUrl('https://billa.example.com', 'tok'), 'https://billa.example.com/view/tok');
    expect(publicDocumentUrl('https://billa.example.com/', 'tok'), 'https://billa.example.com/view/tok');
  });

  test('a reminder names the customer, the business, the invoice, the amount, the due date and the link', () {
    final message = reminderMessage(
      customer: 'Acme Ltd',
      business: 'Kigali Traders',
      number: 'INV-0001',
      amountOwed: 4000,
      dueDate: '2026-10-01T00:00:00.000Z',
      link: 'https://x/view/t',
      payable: true,
    );

    expect(
      message,
      'Hello Acme Ltd, a reminder from Kigali Traders that invoice INV-0001 has RWF 4,000 outstanding.\n'
      'Due date: 1 Oct 2026.\n'
      'View and pay it here: https://x/view/t',
    );
  });

  test('a reminder for an unnumbered invoice still reads naturally', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      number: null,
      amountOwed: 500,
      dueDate: null,
      link: 'l',
    );

    expect(message, contains('that invoice has RWF 500 outstanding.'));
    expect(message, isNot(contains('null')));
    expect(message, isNot(contains('Due date')));
  });

  test('a reminder for an invoice on a plan says which instalment is due now', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      number: 'INV-1',
      amountOwed: 10000,
      dueDate: '2026-10-01',
      link: 'l',
      instalment: (label: 'Deposit', amount: 3000),
    );

    expect(message, contains('has RWF 10,000 outstanding, of which RWF 3,000 (Deposit) is due now.'));
  });

  test('an unnamed instalment is called the next instalment', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 10000,
      dueDate: null,
      link: 'l',
      instalment: (label: '  ', amount: 3000),
    );

    expect(message, contains('(the next instalment) is due now'));
  });

  test('a foreign invoice is written in its own currency and is not offered online payment', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 125050,
      dueDate: null,
      link: 'https://x/view/t',
      currency: Currency.usd,
      payable: true,
    );

    expect(message, contains('USD 1,250.50 outstanding'));
    expect(message, contains('View it here: https://x/view/t'));
    expect(message, isNot(contains('pay')));
  });

  test('an invoice the business cannot take payment for says view it', () {
    final message = reminderMessage(
      customer: 'Acme',
      business: 'B',
      number: 'INV-1',
      amountOwed: 4000,
      dueDate: null,
      link: 'l',
    );

    expect(message, contains('View it here: l'));
  });

  test('a share message names the business, the document and the total', () {
    final message = shareMessage(
      customer: 'Acme',
      business: 'Kigali Traders',
      type: DocumentType.quote,
      typeLabel: 'quote',
      number: 'QUO-1',
      total: 12000,
      dueDate: '2026-10-15',
      link: 'https://x/view/t',
    );

    expect(
      message,
      'Hello Acme, Kigali Traders sent you quote QUO-1 for RWF 12,000.\n'
      'Valid until: 15 Oct 2026.\n'
      'View it here: https://x/view/t',
    );
  });

  test('only an invoice is offered online payment, and a delivery note has no due line', () {
    final invoice = shareMessage(
      customer: 'A',
      business: 'B',
      type: DocumentType.invoice,
      typeLabel: 'invoice',
      number: 'INV-1',
      total: 1000,
      dueDate: '2026-10-01',
      link: 'l',
      payable: true,
    );
    final note = shareMessage(
      customer: 'A',
      business: 'B',
      type: DocumentType.deliveryNote,
      typeLabel: 'delivery note',
      number: 'DN-1',
      total: 1000,
      dueDate: '2026-10-01',
      link: 'l',
      payable: true,
    );

    expect(invoice, contains('View and pay it here: l'));
    expect(note, contains('View it here: l'));
    expect(note, isNot(contains('Due date')));
    expect(note, isNot(contains('Valid until')));
  });

  test('messages contain no em dashes', () {
    final all = [
      reminderMessage(customer: 'A', business: 'B', number: 'N', amountOwed: 1, dueDate: null, link: 'l'),
      shareMessage(
        customer: 'A',
        business: 'B',
        type: DocumentType.invoice,
        typeLabel: 'invoice',
        number: 'N',
        total: 1,
        dueDate: null,
        link: 'l',
      ),
    ];

    for (final message in all) {
      expect(message.contains('\u2014'), isFalse);
    }
  });
}
