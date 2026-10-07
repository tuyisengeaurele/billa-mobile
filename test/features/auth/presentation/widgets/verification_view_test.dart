import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/presentation/widgets/verification_view.dart';

void main() {
  late TextEditingController controller;
  var submitted = 0;
  var wentBack = 0;

  setUp(() {
    controller = TextEditingController();
    submitted = 0;
    wentBack = 0;
  });

  Widget host({String? email = 'ada@example.com', String? error, bool submitting = false}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VerificationView(
              controller: controller,
              email: email,
              errorMessage: error,
              isSubmitting: submitting,
              onSubmit: () => submitted++,
              onBack: () => wentBack++,
            ),
          ),
        ),
      );

  test('masks all but the first letter of the address', () {
    expect(maskEmail('ada@example.com'), 'a***@example.com');
    expect(maskEmail('nonsense'), 'nonsense');
  });

  testWidgets('shows the masked email and Change goes back', (tester) async {
    await tester.pumpWidget(host());

    expect(find.text('a***@example.com'), findsOneWidget);
    await tester.tap(find.byKey(const Key('verification-change')));
    expect(wentBack, 1);
  });

  testWidgets('without an email there is a Back to login button instead of Change', (tester) async {
    await tester.pumpWidget(host(email: null));

    expect(find.byKey(const Key('verification-change')), findsNothing);
    await tester.tap(find.byKey(const Key('verification-back')));
    expect(wentBack, 1);
  });

  testWidgets('Verify waits for six digits', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.byKey(const Key('verification-submit')));
    expect(submitted, 0);

    await tester.enterText(find.byKey(const Key('login-2fa-code')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('verification-submit')));
    expect(submitted, 1);
  });

  testWidgets('counts down and then explains that the sign-in expired', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('Code request expires in 5:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 65));
    expect(find.text('Code request expires in 3:55'), findsOneWidget);

    await tester.pump(const Duration(minutes: 4));
    expect(find.textContaining('expired'), findsOneWidget);
    await tester.tap(find.byKey(const Key('verification-expired-back')));
    expect(wentBack, 1);
  });

  testWidgets('a backup code can be typed instead, with a way back to the app code', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.byKey(const Key('verification-toggle-backup')));
    await tester.pump();

    expect(find.text('Backup code'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login-2fa-code')), 'ABCDE12345');
    await tester.pump();
    await tester.tap(find.byKey(const Key('verification-submit')));
    expect(submitted, 1);

    await tester.tap(find.byKey(const Key('verification-toggle-backup')));
    await tester.pump();
    expect(find.text('Backup code'), findsNothing);
    expect(controller.text, isEmpty);
  });

  testWidgets('shows the error message under the boxes', (tester) async {
    await tester.pumpWidget(host(error: "That code isn't right. Try again"));

    expect(find.text("That code isn't right. Try again"), findsOneWidget);
  });
}
