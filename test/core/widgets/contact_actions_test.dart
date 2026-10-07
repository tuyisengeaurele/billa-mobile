import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/platform/link_launcher.dart';
import 'package:billa_mobile/core/widgets/contact_actions.dart';
import '../../support/tall_screen.dart';

class _FakeLauncher implements LinkLauncher {
  final calls = <String>[];
  bool succeeds = true;

  @override
  Future<bool> call(String phone) async {
    calls.add('call $phone');
    return succeeds;
  }

  @override
  Future<bool> sms(String phone, {String? body}) async {
    calls.add('sms $phone $body');
    return succeeds;
  }

  @override
  Future<bool> whatsapp(String phone, String message) async {
    calls.add('whatsapp $phone $message');
    return succeeds;
  }
}

void main() {
  late _FakeLauncher launcher;

  setUp(() {
    launcher = _FakeLauncher();
  });

  Future<void> open(WidgetTester tester, {required String? phone}) async {
    useTallScreen(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [linkLauncherProvider.overrideWithValue(launcher)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () => showContactActions(context, ref, title: 'Acme', phone: phone, message: 'Hello there'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the message that will be sent and the three ways to reach the customer', (tester) async {
    await open(tester, phone: '0788123456');

    expect(find.text('Hello there'), findsOneWidget);
    expect(find.byKey(const Key('contact-call')), findsOneWidget);
    expect(find.byKey(const Key('contact-sms')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
  });

  testWidgets('each action uses the launcher with the number and message', (tester) async {
    await open(tester, phone: '0788123456');
    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    expect(launcher.calls, ['whatsapp 0788123456 Hello there']);
  });

  testWidgets('call and sms work the same way', (tester) async {
    await open(tester, phone: '0788123456');
    await tester.tap(find.byKey(const Key('contact-call')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contact-sms')));
    await tester.pumpAndSettle();

    expect(launcher.calls, ['call 0788123456', 'sms 0788123456 Hello there']);
  });

  testWidgets('without a saved number the actions are disabled and say why', (tester) async {
    await open(tester, phone: null);

    expect(find.text('No phone number saved'), findsNWidgets(3));
    await tester.tap(find.byKey(const Key('contact-call')));
    await tester.pumpAndSettle();
    expect(launcher.calls, isEmpty);
  });

  testWidgets('a number that cannot be dialled says so instead of failing later', (tester) async {
    await open(tester, phone: 'ask reception');

    expect(find.text("That number can't be dialled"), findsNWidgets(3));
  });

  testWidgets('when no app can open the link a specific message appears', (tester) async {
    launcher.succeeds = false;
    await open(tester, phone: '0788123456');
    await tester.tap(find.byKey(const Key('contact-whatsapp')));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't open that app. Is it installed?"), findsOneWidget);
  });
}
