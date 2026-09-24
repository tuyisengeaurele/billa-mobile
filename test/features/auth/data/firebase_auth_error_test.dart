import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/auth/data/firebase_auth_error.dart';

void main() {
  final cases = {
    'wrong-password': "That password doesn't match this account.",
    'user-not-found': 'No account found with that email.',
    'email-already-in-use': 'An account with that email already exists.',
    'weak-password': 'Choose a stronger password.',
    'network-request-failed': 'Check your connection and try again.',
    'too-many-requests': 'Too many attempts — wait a moment and try again.',
  };

  for (final entry in cases.entries) {
    test('maps ${entry.key}', () {
      expect(mapFirebaseAuthError(entry.key), entry.value);
    });
  }

  test('falls back to a generic message for an unrecognized code', () {
    expect(mapFirebaseAuthError('something-new'), 'Something went wrong — please try again.');
  });
}
