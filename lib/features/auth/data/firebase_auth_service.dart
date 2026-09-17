import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInReady = false;

  Future<String> _idTokenOf(UserCredential credential) async {
    final token = await credential.user!.getIdToken();
    return token!;
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _idTokenOf(credential);
  }

  Future<String> registerWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return _idTokenOf(credential);
  }

  Future<String> signInWithGoogle() async {
    if (!_googleSignInReady) {
      await _googleSignIn.initialize();
      _googleSignInReady = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(code: 'google-sign-in-cancelled', message: 'Sign-in was cancelled.');
      }
      rethrow;
    }

    final credential = GoogleAuthProvider.credential(idToken: account.authentication.idToken);
    final userCredential = await _auth.signInWithCredential(credential);
    return _idTokenOf(userCredential);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Errors are intentionally swallowed by the caller (login_screen.dart), not here —
    // the UI always shows the same message so it never reveals whether the email exists.
    await _auth.sendPasswordResetEmail(email: email);
  }
}
