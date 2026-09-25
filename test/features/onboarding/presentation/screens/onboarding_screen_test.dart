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
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/document_sequence.dart';
import 'package:billa_mobile/features/business_settings/domain/document_template.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/onboarding/data/logo_pipeline_service.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/logo_pipeline_provider.dart';
import 'package:billa_mobile/features/onboarding/domain/business_repository.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/business_repository_provider.dart';
import 'package:billa_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockBusinessRepository extends Mock implements BusinessRepository {}
class _MockLogoPipelineService extends Mock implements LogoPipelineService {}
class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

const _user = AuthUser(id: 'u1', email: 'a@b.com', totpEnabled: false, isAdmin: false);

const _defaults = [
  DocumentSequence(type: DocumentType.invoice, prefix: 'INV-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.proforma, prefix: 'PRO-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.deliveryNote, prefix: 'DN-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.quote, prefix: 'QTE-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.receipt, prefix: 'RCT-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.creditNote, prefix: 'CN-', nextNumber: 1, resetYearly: false),
];

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

  late _MockBusinessSettingsRepository settingsRepository;

  Future<(_MockBusinessRepository, _MockAuthRepository)> pumpOnboarding(WidgetTester tester) async {
    settingsRepository = _MockBusinessSettingsRepository();
    when(() => settingsRepository.sequences()).thenAnswer((_) async => _defaults);
    final authRepository = _MockAuthRepository();
    final businessRepository = _MockBusinessRepository();
    const business = Business(id: 'b1', name: 'My Business', onboardingCompletedAt: null);
    when(() => authRepository.me()).thenAnswer((_) async => const AuthStatus.authenticated(_user, business));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        businessRepositoryProvider.overrideWithValue(businessRepository),
        logoPipelineServiceProvider.overrideWithValue(_MockLogoPipelineService()),
        businessSettingsRepositoryProvider.overrideWithValue(settingsRepository),
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
    expect(find.text('Step 1 of 4'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 4'), findsOneWidget);
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

  Future<void> tallScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> skipTo(WidgetTester tester, int step) async {
    // Details and logo can both be skipped, which is also how a user who
    // wants to reach the later steps quickly would get there.
    if (step >= 1) {
      await tester.tap(find.byKey(const Key('onboarding-details-skip')));
      await tester.pumpAndSettle();
    }
    if (step >= 2) {
      await tester.tap(find.byKey(const Key('onboarding-logo-skip')));
      await tester.pumpAndSettle();
    }
    if (step >= 3) {
      await tester.tap(find.byKey(const Key('onboarding-template-skip')));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('skipping the logo step moves on to the document style step instead of finishing', (tester) async {
    await tallScreen(tester);
    final (businessRepository, _) = await pumpOnboarding(tester);

    await skipTo(tester, 2);

    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.text('Choose a document style'), findsOneWidget);
    verifyNever(() => businessRepository.completeOnboarding());
  });

  testWidgets('a chosen template is saved and the numbering step follows', (tester) async {
    await tallScreen(tester);
    await pumpOnboarding(tester);
    when(() => settingsRepository.setDefaultTemplate(DocumentTemplate.classic))
        .thenAnswer((_) async => const BusinessSettings(id: 'b1', name: 'My Business'));

    await skipTo(tester, 2);
    await tester.tap(find.byKey(const Key('onboarding-template-classic')));
    await tester.tap(find.byKey(const Key('onboarding-template-continue')));
    await tester.pumpAndSettle();

    verify(() => settingsRepository.setDefaultTemplate(DocumentTemplate.classic)).called(1);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Number your documents'), findsOneWidget);
  });

  testWidgets('a failed template save shows a message, stays on the step, and Retry moves on', (tester) async {
    await tallScreen(tester);
    await pumpOnboarding(tester);
    var failing = true;
    when(() => settingsRepository.setDefaultTemplate(DocumentTemplate.minimal)).thenAnswer((_) async {
      if (failing) throw offline();
      return const BusinessSettings(id: 'b1', name: 'My Business');
    });

    await skipTo(tester, 2);
    await tester.tap(find.byKey(const Key('onboarding-template-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Step 4 of 4'), findsOneWidget);
  });

  testWidgets('finishing the numbering step saves the sequences and completes onboarding', (tester) async {
    await tallScreen(tester);
    final (businessRepository, _) = await pumpOnboarding(tester);
    when(() => settingsRepository.saveSequences(_defaults)).thenAnswer((_) async => _defaults);
    when(() => businessRepository.completeOnboarding()).thenAnswer(
      (_) async => const Business(id: 'b1', name: 'My Business', onboardingCompletedAt: '2026-01-01T00:00:00.000Z'),
    );

    await skipTo(tester, 3);
    verifyNever(() => businessRepository.completeOnboarding());
    await tester.tap(find.byKey(const Key('num-save')));
    await tester.pumpAndSettle();

    verify(() => settingsRepository.saveSequences(_defaults)).called(1);
    verify(() => businessRepository.completeOnboarding()).called(1);
  });

  testWidgets('a failed numbering save shows its message, does not complete, and Retry finishes', (tester) async {
    await tallScreen(tester);
    final (businessRepository, _) = await pumpOnboarding(tester);
    var failing = true;
    when(() => settingsRepository.saveSequences(_defaults)).thenAnswer((_) async {
      if (failing) throw offline();
      return _defaults;
    });
    when(() => businessRepository.completeOnboarding()).thenAnswer(
      (_) async => const Business(id: 'b1', name: 'My Business', onboardingCompletedAt: '2026-01-01T00:00:00.000Z'),
    );

    await skipTo(tester, 3);
    await tester.tap(find.byKey(const Key('num-save')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    verifyNever(() => businessRepository.completeOnboarding());

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => businessRepository.completeOnboarding()).called(1);
  });

  testWidgets('skipping the numbering step completes onboarding without saving sequences', (tester) async {
    await tallScreen(tester);
    final (businessRepository, _) = await pumpOnboarding(tester);
    when(() => businessRepository.completeOnboarding()).thenAnswer(
      (_) async => const Business(id: 'b1', name: 'My Business', onboardingCompletedAt: '2026-01-01T00:00:00.000Z'),
    );

    await skipTo(tester, 3);
    await tester.tap(find.byKey(const Key('onboarding-numbering-skip')));
    await tester.pumpAndSettle();

    verifyNever(() => settingsRepository.saveSequences(any()));
    verify(() => businessRepository.completeOnboarding()).called(1);
  });

  testWidgets('a failed sequences load offers a retry that reloads', (tester) async {
    await tallScreen(tester);
    await pumpOnboarding(tester);
    var failing = true;
    when(() => settingsRepository.sequences()).thenAnswer((_) async {
      if (failing) throw offline();
      return _defaults;
    });

    await skipTo(tester, 3);
    expect(find.text("Couldn't load your numbering settings"), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('num-prefix-INVOICE')), findsOneWidget);
  });

  testWidgets('moving to the next step cross-fades instead of jumping', (tester) async {
    await tallScreen(tester);
    await pumpOnboarding(tester);

    await tester.tap(find.byKey(const Key('onboarding-details-skip')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tell us about your business'), findsOneWidget);
    expect(find.text('Add your logo'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Tell us about your business'), findsNothing);
    expect(find.text('Add your logo'), findsOneWidget);
  });
}
