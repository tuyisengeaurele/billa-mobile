import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/domain/security_repository.dart';
import 'package:billa_mobile/features/account/domain/two_factor_setup.dart';
import 'package:billa_mobile/features/account/presentation/providers/current_user_provider.dart';
import 'package:billa_mobile/features/account/presentation/providers/security_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/two_factor_setup_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../support.dart';

class _MockSecurityRepository extends Mock implements SecurityRepository {}

const _pixel =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

const _setup = TwoFactorSetup(secret: 'JBSWY3DPEHPK3PXP', otpauthUrl: 'otpauth://totp/x', qrCodeDataUri: _pixel);

void main() {
  late _MockSecurityRepository repository;

  setUp(() {
    repository = _MockSecurityRepository();
    when(() => repository.setUpTwoFactor()).thenAnswer((_) async => _setup);
  });

  Widget buildApp() => accountApp(
        screen: const TwoFactorSetupScreen(),
        path: '/settings/security/two-factor',
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          securityRepositoryProvider.overrideWithValue(repository),
        ],
      );

  Future<void> enterCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byKey(const Key('two-factor-code')), code);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('two-factor-verify')));
    await tester.tap(find.byKey(const Key('two-factor-verify')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the key and keeps Verify disabled until six digits are entered', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('two-factor-code')), '123');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byKey(const Key('two-factor-verify'))).onPressed, isNull);
  });

  testWidgets('a wrong code shows the specific message', (tester) async {
    when(() => repository.verifyTwoFactor('000000')).thenThrow(apiError('invalid_code'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await enterCode(tester, '000000');

    expect(find.text("That code isn't right — try again"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a right code shows the backup codes once and gates Done on acknowledgement', (tester) async {
    when(() => repository.verifyTwoFactor('123456')).thenAnswer((_) async => ['aaaaaaaaaa', 'bbbbbbbbbb']);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await enterCode(tester, '123456');

    expect(find.text('aaaaaaaaaa'), findsOneWidget);
    expect(find.text('bbbbbbbbbb'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('two-factor-done'))).onPressed, isNull);

    await tester.tap(find.byKey(const Key('two-factor-saved')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byKey(const Key('two-factor-done'))).onPressed, isNotNull);
  });

  testWidgets('the signed-in user shows two-factor as on as soon as it is verified', (tester) async {
    when(() => repository.verifyTwoFactor('123456')).thenAnswer((_) async => ['aaaaaaaaaa']);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(TwoFactorSetupScreen)));
    // The screen never reads auth itself, so settle it the way a signed-in
    // session already would be before this screen opens.
    await container.read(authControllerProvider.future);
    await enterCode(tester, '123456');

    expect(container.read(currentUserProvider)!.totpEnabled, isTrue);
  });

  testWidgets('a failed setup load offers a retry', (tester) async {
    when(() => repository.setUpTwoFactor()).thenAnswer((_) async => throw apiError('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
