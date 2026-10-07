import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/data/firebase_auth_service.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/auth/presentation/providers/firebase_auth_service_provider.dart';
import 'package:billa_mobile/features/auth/presentation/screens/login_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockFirebaseAuthService firebaseAuthService;

  setUp(() {
    authRepository = _MockAuthRepository();
    firebaseAuthService = _MockFirebaseAuthService();
    when(() => authRepository.me()).thenAnswer((_) async => const AuthStatus.unauthenticated());
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        firebaseAuthServiceProvider.overrideWithValue(firebaseAuthService),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );
  }

  testWidgets('shows a mapped error message when sign-in fails', (tester) async {
    when(() => firebaseAuthService.signInWithEmailAndPassword('a@b.com', 'wrong'))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text("That password doesn't match this account."), findsOneWidget);
  });

  testWidgets('swaps to the 2FA code form when the server requires it', (tester) async {
    when(() => firebaseAuthService.signInWithEmailAndPassword('a@b.com', 'correct'))
        .thenAnswer((_) async => 'id-token');
    when(() => authRepository.exchangeSession(idToken: 'id-token', businessName: null))
        .thenAnswer((_) async => const AuthStatus.twoFactorRequired('challenge-1'));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-2fa-code')), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsNothing);
  });

  testWidgets('forgot password always shows the same confirmation message', (tester) async {
    when(() => firebaseAuthService.sendPasswordResetEmail('a@b.com')).thenThrow(
      FirebaseAuthException(code: 'user-not-found'),
    );

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.tap(find.byKey(const Key('login-forgot-password')));
    await tester.pumpAndSettle();

    expect(find.text('Check your email for a link to reset your password.'), findsOneWidget);
  });
}
