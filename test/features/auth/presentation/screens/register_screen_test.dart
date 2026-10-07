import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/data/firebase_auth_service.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/auth/presentation/providers/firebase_auth_service_provider.dart';
import 'package:billa_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';
import '../../../../support/tall_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);
const _business = Business(id: 'b1', name: 'My Business');

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
      child: MaterialApp(theme: AppTheme.light, home: const RegisterScreen()),
    );
  }

  testWidgets('sends the placeholder business name, not a user-entered one', (tester) async {
    useTallScreen(tester);
    when(() => firebaseAuthService.registerWithEmailAndPassword('a@b.com', 'Abcdef1!'))
        .thenAnswer((_) async => 'id-token');
    when(() => authRepository.exchangeSession(idToken: 'id-token', businessName: 'My Business'))
        .thenAnswer((_) async => const AuthStatus.authenticated(_user, _business));

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('register-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('register-password')), 'Abcdef1!');
    await tester.enterText(find.byKey(const Key('register-confirm-password')), 'Abcdef1!');
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    verify(() => authRepository.exchangeSession(idToken: 'id-token', businessName: 'My Business')).called(1);
  });

  testWidgets('shows an error when passwords do not match', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('register-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('register-password')), 'Abcdef1!');
    await tester.enterText(find.byKey(const Key('register-confirm-password')), 'different');
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text("Passwords don't match"), findsOneWidget);
    verifyNever(() => firebaseAuthService.registerWithEmailAndPassword(any(), any()));
  });

  testWidgets('a failed session request after registering shows a connection message', (tester) async {
    useTallScreen(tester);
    when(() => firebaseAuthService.registerWithEmailAndPassword('a@b.com', 'Abcdef1!'))
        .thenAnswer((_) async => 'id-token');
    when(() => authRepository.exchangeSession(idToken: 'id-token', businessName: 'My Business')).thenAnswer(
      (_) async => throw DioException(requestOptions: RequestOptions(path: '/auth/session'), type: DioExceptionType.connectionError),
    );

    await tester.pumpWidget(buildApp());
    await tester.enterText(find.byKey(const Key('register-email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('register-password')), 'Abcdef1!');
    await tester.enterText(find.byKey(const Key('register-confirm-password')), 'Abcdef1!');
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
  });

  testWidgets('cancelling the Google account picker shows no error and leaves the form usable', (tester) async {
    useTallScreen(tester);
    when(() => firebaseAuthService.signInWithGoogle())
        .thenAnswer((_) async => throw FirebaseAuthException(code: 'google-sign-in-cancelled'));

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Something went wrong'), findsNothing);
    expect(find.text('Continue with Google'), findsOneWidget);
    verifyNever(() => authRepository.exchangeSession(idToken: any(named: 'idToken'), businessName: any(named: 'businessName')));
  });

  testWidgets('shows the create-account heading and a way back to log in', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsNWidgets(2));
  });
}
