import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/app_button.dart';
import 'package:billa_mobile/features/auth/data/firebase_auth_service.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/auth/presentation/providers/firebase_auth_service_provider.dart';
import 'package:billa_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:billa_mobile/features/auth/presentation/widgets/auth_layout.dart';

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

  testWidgets('a failed session request after a good sign-in shows a connection message', (tester) async {
    when(() => firebaseAuthService.signInWithEmailAndPassword('a@b.com', 'correct'))
        .thenAnswer((_) async => 'id-token');
    when(() => authRepository.exchangeSession(idToken: 'id-token', businessName: null)).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/auth/session'), type: DioExceptionType.connectionError),
    );

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(tester.widget<AppButton>(find.byKey(const Key('login-submit'))).isLoading, isFalse);
  });

  testWidgets('cancelling the Google account picker shows no error and leaves the form usable', (tester) async {
    when(() => firebaseAuthService.signInWithGoogle())
        .thenAnswer((_) async => throw FirebaseAuthException(code: 'google-sign-in-cancelled'));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Something went wrong'), findsNothing);
    expect(find.text('Continue with Google'), findsOneWidget);
    verifyNever(() => authRepository.exchangeSession(idToken: any(named: 'idToken'), businessName: any(named: 'businessName')));
  });

  Future<void> reachCodeForm(WidgetTester tester) async {
    when(() => firebaseAuthService.signInWithEmailAndPassword('a@b.com', 'correct'))
        .thenAnswer((_) async => 'id-token');
    when(() => authRepository.exchangeSession(idToken: 'id-token', businessName: null))
        .thenAnswer((_) async => const AuthStatus.twoFactorRequired('challenge-1'));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
  }

  DioException challengeError(int status, String code) => DioException(
        requestOptions: RequestOptions(path: '/auth/2fa/challenge'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/2fa/challenge'),
          statusCode: status,
          data: {'error': code},
        ),
      );

  Future<void> submitCode(WidgetTester tester, DioException error) async {
    when(() => authRepository.submitTwoFactorChallenge(challengeId: 'challenge-1', code: '123456'))
        .thenAnswer((_) async => throw error);
    await reachCodeForm(tester);
    await tester.enterText(find.byKey(const Key('login-2fa-code')), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
  }

  testWidgets('a wrong verification code says the code is wrong and stays on the code form', (tester) async {
    await submitCode(tester, challengeError(401, 'invalid_code'));

    expect(find.text("That code isn't right. Try again"), findsOneWidget);
    expect(find.byKey(const Key('login-2fa-code')), findsOneWidget);
  });

  testWidgets('an expired sign-in returns to the login form and says so', (tester) async {
    await submitCode(tester, challengeError(401, 'invalid_challenge'));

    expect(find.text('This sign-in expired. Log in again'), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsOneWidget);
  });

  testWidgets('being rate limited is reported as such, not as a wrong code', (tester) async {
    await submitCode(tester, challengeError(429, 'too_many_requests'));

    expect(find.text('Too many attempts. Wait a few minutes and try again'), findsOneWidget);
    expect(find.textContaining('incorrect'), findsNothing);
  });

  testWidgets('a dropped connection is reported as a connection problem', (tester) async {
    await submitCode(
      tester,
      DioException(requestOptions: RequestOptions(path: '/auth/2fa/challenge'), type: DioExceptionType.connectionError),
    );

    expect(find.text('Check your connection and try again'), findsOneWidget);
  });

  testWidgets('shows the welcome heading, the Google option, and a way to sign up', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('a sign-in error appears in the inline error block', (tester) async {
    when(() => firebaseAuthService.signInWithEmailAndPassword('a@b.com', 'wrong'))
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('login-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(AuthError), findsOneWidget);
    expect(find.descendant(of: find.byType(AuthError), matching: find.text("That password doesn't match this account.")), findsOneWidget);
  });
}
