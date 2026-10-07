import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/short_date.dart';

void main() {
  test('writes a day, a three letter month and the year', () {
    expect(formatShortDate('2026-10-01'), '1 Oct 2026');
    expect(formatShortDate('2026-09-30T00:00:00.000Z'), '30 Sep 2026');
    expect(formatShortDate('2027-01-05T00:00:00.000Z'), '5 Jan 2027');
  });

  test('reads the calendar day it was written for, whatever the phone timezone', () {
    expect(formatShortDate('2026-10-01T23:59:59.000Z'), '1 Oct 2026');
  });

  test('returns the text unchanged when it is not a date', () {
    expect(formatShortDate('soon'), 'soon');
  });
}
