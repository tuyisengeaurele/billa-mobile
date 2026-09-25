import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/data/logo_pipeline_service.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/logo_pipeline_provider.dart';
import 'package:billa_mobile/features/onboarding/domain/business_repository.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/business_repository_provider.dart';
import 'package:billa_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockBusinessRepository extends Mock implements BusinessRepository {}
class _MockLogoPipelineService extends Mock implements LogoPipelineService {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

void main() {
  testWidgets('skip onboarding completes it and does not require the logo step', (tester) async {
    final authRepository = _MockAuthRepository();
    final businessRepository = _MockBusinessRepository();
    const business = Business(id: 'b1', name: 'My Business', onboardingCompletedAt: null);
    const completed = Business(id: 'b1', name: 'My Business', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');

    when(() => authRepository.me()).thenAnswer((_) async => const AuthStatus.authenticated(_user, business));
    when(() => businessRepository.completeOnboarding()).thenAnswer((_) async => completed);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        businessRepositoryProvider.overrideWithValue(businessRepository),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const OnboardingScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip onboarding'));
    await tester.pumpAndSettle();

    verify(() => businessRepository.completeOnboarding()).called(1);
  });

  Future<(_MockBusinessRepository, _MockAuthRepository)> pumpOnboarding(WidgetTester tester) async {
    final authRepository = _MockAuthRepository();
    final businessRepository = _MockBusinessRepository();
    const business = Business(id: 'b1', name: 'My Business', onboardingCompletedAt: null);
    when(() => authRepository.me()).thenAnswer((_) async => const AuthStatus.authenticated(_user, business));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        businessRepositoryProvider.overrideWithValue(businessRepository),
        logoPipelineServiceProvider.overrideWithValue(_MockLogoPipelineService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const OnboardingScreen()),
    ));
    await tester.pumpAndSettle();
    return (businessRepository, authRepository);
  }

  DioException offline() =>
      DioException(requestOptions: RequestOptions(path: '/business'), type: DioExceptionType.connectionError);

  testWidgets('a failed details save shows a message, keeps the step, and Retry moves on', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var failing = true;
    final (businessRepository, _) = await pumpOnboarding(tester);
    when(
      () => businessRepository.updateProfile(
        name: any(named: 'name'),
        tin: any(named: 'tin'),
        industry: any(named: 'industry'),
        phone: any(named: 'phone'),
        email: any(named: 'email'),
        address: any(named: 'address'),
        rraEbmNumber: any(named: 'rraEbmNumber'),
      ),
    ).thenAnswer((_) async {
      if (failing) throw offline();
      return const Business(id: 'b1', name: 'My Business');
    });

    await tester.tap(find.byKey(const Key('onboarding-details-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Check your connection and try again'), findsNothing);
  });

  testWidgets('a failed skip shows a message and Retry completes onboarding', (tester) async {
    var failing = true;
    final (businessRepository, _) = await pumpOnboarding(tester);
    when(() => businessRepository.completeOnboarding()).thenAnswer((_) async {
      if (failing) throw offline();
      return const Business(id: 'b1', name: 'My Business', onboardingCompletedAt: '2026-01-01T00:00:00.000Z');
    });

    await tester.tap(find.text('Skip onboarding'));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => businessRepository.completeOnboarding()).called(2);
  });
}
