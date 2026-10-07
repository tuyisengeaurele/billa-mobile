/// Raised when the user closes the Google account picker. Not a failure: the
/// screens stay quiet instead of telling someone they did something wrong.
const googleSignInCancelledCode = 'google-sign-in-cancelled';

const _messages = {
  'wrong-password': "That password doesn't match this account.",
  'user-not-found': 'No account found with that email.',
  'email-already-in-use': 'An account with that email already exists.',
  'weak-password': 'Choose a stronger password.',
  'network-request-failed': 'Check your connection and try again.',
  'too-many-requests': 'Too many attempts — wait a moment and try again.',
};

String mapFirebaseAuthError(String code) {
  return _messages[code] ?? 'Something went wrong — please try again.';
}
