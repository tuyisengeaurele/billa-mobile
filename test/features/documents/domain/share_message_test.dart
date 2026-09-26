import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/domain/share_message.dart';

void main() {
  test('builds the customer-facing link from the origin and token', () {
    expect(publicDocumentUrl('https://billa.example.com', 'tok'), 'https://billa.example.com/view/tok');
    expect(publicDocumentUrl('https://billa.example.com/', 'tok'), 'https://billa.example.com/view/tok');
  });

  test('a reminder names the customer, the invoice, the amount owed and the link', () {
    final message = reminderMessage(
      customer: 'Acme Ltd',
      number: 'INV-0001',
      amountOwed: 4000,
      link: 'https://x/view/t',
    );

    expect(message, contains('Acme Ltd'));
    expect(message, contains('INV-0001'));
    expect(message, contains('RWF 4,000'));
    expect(message, contains('https://x/view/t'));
  });

  test('a reminder for an unnumbered invoice still reads naturally', () {
    final message = reminderMessage(customer: 'Acme', number: null, amountOwed: 500, link: 'l');

    expect(message, contains('your invoice'));
    expect(message, isNot(contains('null')));
  });

  test('a share message names the document type and total', () {
    final message = shareMessage(
      customer: 'Acme',
      typeLabel: 'quote',
      number: 'QUO-1',
      total: 12000,
      link: 'https://x/view/t',
    );

    expect(message, contains('quote QUO-1'));
    expect(message, contains('RWF 12,000'));
    expect(message, contains('https://x/view/t'));
  });

  test('messages contain no em dashes', () {
    final all = [
      reminderMessage(customer: 'A', number: 'N', amountOwed: 1, link: 'l'),
      shareMessage(customer: 'A', typeLabel: 'invoice', number: 'N', total: 1, link: 'l'),
    ];

    for (final message in all) {
      expect(message.contains('\u2014'), isFalse);
    }
  });
}
