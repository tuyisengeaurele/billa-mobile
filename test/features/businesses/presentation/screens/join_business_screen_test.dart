import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/domain/invite_preview.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/businesses/presentation/screens/join_business_screen.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _FakeAuthController extends AuthController {
  @override
  Future<AuthStatus> build() async => const AuthStatus.authenticated(_user, Business(id: 'b1', name: 'Mine'));
}

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockBusinessesRepository repository;

  setUp(() {
    repository = _MockBusinessesRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home screen'))),
      GoRoute(path: '/join', builder: (context, state) => const JoinBusinessScreen()),
    ]);
    router.go('/join');
    return ProviderScope(
      overrides: [
        businessesRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FakeAuthController.new),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> pasteAndContinue(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('invite-link')), 'https://app.example.com/invite/tok123');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('invite-continue')));
    await tester.pumpAndSettle();
  }

  testWidgets('previews the business and email, then accepts and goes home', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'a@b.com',
          businessName: 'Acme',
          expired: false,
          alreadyAccepted: false,
        ));
    when(() => repository.acceptInvite('tok123')).thenAnswer((_) async => const Business(id: 'b2', name: 'Acme'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.textContaining('Acme'), findsWidgets);
    await tester.tap(find.byKey(const Key('invite-accept')));
    await tester.pumpAndSettle();

    verify(() => repository.acceptInvite('tok123')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('an expired invite disables Accept and says why', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'a@b.com',
          businessName: 'Acme',
          expired: true,
          alreadyAccepted: false,
        ));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.text('This invite has expired'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('invite-accept'))).onPressed, isNull);
  });

  testWidgets('an unknown link shows the not-found message', (tester) async {
    when(() => repository.previewInvite('tok123')).thenThrow(_error('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);

    expect(find.text("We couldn't find that. It may have been removed"), findsOneWidget);
  });

  testWidgets('a different-email invite shows the mismatch message on accept', (tester) async {
    when(() => repository.previewInvite('tok123')).thenAnswer((_) async => const InvitePreview(
          email: 'other@b.com',
          businessName: 'Acme',
          expired: false,
          alreadyAccepted: false,
        ));
    when(() => repository.acceptInvite('tok123')).thenThrow(_error('email_mismatch'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await pasteAndContinue(tester);
    await tester.tap(find.byKey(const Key('invite-accept')));
    await tester.pumpAndSettle();

    expect(find.text('This invite was sent to a different email address'), findsOneWidget);
  });
}
