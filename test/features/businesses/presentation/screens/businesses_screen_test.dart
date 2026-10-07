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
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/businesses_repository.dart';
import 'package:billa_mobile/features/businesses/domain/leave_result.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/businesses_repository_provider.dart';
import 'package:billa_mobile/features/businesses/presentation/screens/businesses_screen.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

class _MockBusinessesRepository extends Mock implements BusinessesRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockBusinessesRepository repository;

  setUp(() {
    repository = _MockBusinessesRepository();
    when(() => repository.list()).thenAnswer((_) async => [
          const BusinessSummary(id: 'b1', name: 'Acme', isOwner: true),
          const BusinessSummary(id: 'b2', name: 'Other Co', isOwner: false),
        ]);
  });

  Widget buildApp({String activeId = 'b1'}) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home screen'))),
      GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
      GoRoute(path: '/businesses/join', builder: (context, state) => const Scaffold(body: Text('join screen'))),
    ]);
    router.go('/businesses');
    return ProviderScope(
      overrides: [
        businessesRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(AuthStatus.authenticated(_user, Business(id: activeId, name: 'x'))),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('lists every business with ownership labels and marks the active one', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Other Co'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('tapping another business switches to it and goes home', (tester) async {
    when(() => repository.switchTo('b2')).thenAnswer((_) async => const Business(id: 'b2', name: 'Other Co'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other Co'));
    await tester.pumpAndSettle();

    verify(() => repository.switchTo('b2')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('creating a business prompts for a name and goes home', (tester) async {
    when(() => repository.create('New Co')).thenAnswer((_) async => const Business(id: 'b3', name: 'New Co'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Co');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    verify(() => repository.create('New Co')).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('hitting the business limit shows the specific message', (tester) async {
    when(() => repository.create('New Co')).thenThrow(_error('business_limit_reached'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New Co');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text("You've reached the limit of 3 businesses"), findsOneWidget);
  });

  testWidgets('leave is not offered for a business you own', (tester) async {
    await tester.pumpWidget(buildApp(activeId: 'b1'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('businesses-leave')), findsNothing);
  });

  testWidgets('leave is offered for a business you do not own, and confirms', (tester) async {
    when(() => repository.leaveCurrent()).thenAnswer(
      (_) async => const LeaveResult(business: Business(id: 'b1', name: 'Acme'), createdReplacement: false),
    );

    await tester.pumpWidget(buildApp(activeId: 'b2'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('businesses-leave')));
    await tester.tap(find.byKey(const Key('businesses-leave')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave').last);
    await tester.pumpAndSettle();

    verify(() => repository.leaveCurrent()).called(1);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('join opens the join screen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('businesses-join')));
    await tester.pumpAndSettle();

    expect(find.text('join screen'), findsOneWidget);
  });
}
