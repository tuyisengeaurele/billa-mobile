import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/businesses/domain/invite_token.dart';

void main() {
  test('takes the last path segment of a pasted link', () {
    expect(extractInviteToken('https://app.example.com/invite/tok123'), 'tok123');
  });

  test('ignores a trailing slash, query string, and surrounding whitespace', () {
    expect(extractInviteToken('  https://app.example.com/invite/tok123/  '), 'tok123');
    expect(extractInviteToken('https://app.example.com/invite/tok123?ref=email'), 'tok123');
  });

  test('accepts a bare token', () {
    expect(extractInviteToken('tok123'), 'tok123');
  });

  test('returns null for empty input', () {
    expect(extractInviteToken('   '), isNull);
  });
}
