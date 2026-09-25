import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/relative_time.dart';

void main() {
  final now = DateTime.utc(2026, 3, 10, 12);

  test('reads recent times in minutes, hours, and days', () {
    expect(relativeTime('2026-03-10T11:59:30.000Z', now: now), 'just now');
    expect(relativeTime('2026-03-10T11:55:00.000Z', now: now), '5 min ago');
    expect(relativeTime('2026-03-10T09:00:00.000Z', now: now), '3 h ago');
    expect(relativeTime('2026-03-08T12:00:00.000Z', now: now), '2 d ago');
  });

  test('falls back to the date after a week and for unparseable input', () {
    expect(relativeTime('2026-02-01T12:00:00.000Z', now: now), '2026-02-01');
    expect(relativeTime('not a date', now: now), 'not a date');
  });
}
