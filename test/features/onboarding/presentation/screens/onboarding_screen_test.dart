import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';
import 'package:billa_mobile/features/onboarding/domain/business_repository.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/business_repository_provider.dart';
import 'package:billa_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockBusinessRepository extends Mock implements BusinessRepository {}

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
}
