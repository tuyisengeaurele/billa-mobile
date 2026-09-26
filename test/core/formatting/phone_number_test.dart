import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/phone_number.dart';

void main() {
  group('normaliseRwandaNumber', () {
    test('turns the local format into international digits', () {
      expect(normaliseRwandaNumber('0788123456'), '250788123456');
    });

    test('accepts a plus sign, spaces and dashes', () {
      expect(normaliseRwandaNumber('+250 788 123 456'), '250788123456');
      expect(normaliseRwandaNumber('0788-123-456'), '250788123456');
      expect(normaliseRwandaNumber('(0788) 123 456'), '250788123456');
    });

    test('keeps a number that is already international', () {
      expect(normaliseRwandaNumber('250788123456'), '250788123456');
    });

    test('adds the country code to a number written without the leading zero', () {
      expect(normaliseRwandaNumber('788123456'), '250788123456');
    });

    test('keeps another country as its digits instead of forcing rwanda onto it', () {
      expect(normaliseRwandaNumber('+254712345678'), '254712345678');
      expect(normaliseRwandaNumber('+1 415 555 0100'), '14155550100');
    });

    test('rejects blanks, letters and numbers too short to dial', () {
      expect(normaliseRwandaNumber(''), isNull);
      expect(normaliseRwandaNumber('   '), isNull);
      expect(normaliseRwandaNumber('call me'), isNull);
      expect(normaliseRwandaNumber('0788'), isNull);
    });
  });
}
