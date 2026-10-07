import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/privacy/privacy_mode.dart';
import 'package:billa_mobile/core/privacy/privacy_settings.dart';

void main() {
  late ProviderContainer container;

  Future<void> withRef(WidgetTester tester, void Function(WidgetRef ref) action) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Consumer(
          builder: (context, ref, _) => GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => action(ref), child: const SizedBox(width: 50, height: 50)),
        ),
      ),
    ));
    await tester.tap(find.byType(GestureDetector));
  }

  setUp(() {
    container = ProviderContainer(overrides: [privacySettingsStoreProvider.overrideWithValue(InMemoryPrivacySettingsStore())]);
    addTearDown(container.dispose);
  });

  test('amounts are visible until privacy mode is on', () {
    expect(container.read(amountsHiddenProvider), isFalse);

    container.read(privacySettingsProvider.notifier).setHideAmounts(true);

    expect(container.read(amountsHiddenProvider), isTrue);
  });

  test('revealing shows them again for the session only', () {
    container.read(privacySettingsProvider.notifier).setHideAmounts(true);

    container.read(amountsRevealedProvider.notifier).state = true;

    expect(container.read(amountsHiddenProvider), isFalse);
    expect(container.read(privacySettingsProvider).hideAmounts, isTrue);
  });

  testWidgets('the eye turns privacy mode on the first time', (tester) async {
    await withRef(tester, togglePrivacyEye);

    expect(container.read(privacySettingsProvider).hideAmounts, isTrue);
    expect(container.read(amountsHiddenProvider), isTrue);
  });

  testWidgets('the eye then reveals and hides without changing the saved choice', (tester) async {
    container.read(privacySettingsProvider.notifier).setHideAmounts(true);

    await withRef(tester, togglePrivacyEye);
    expect(container.read(amountsHiddenProvider), isFalse);

    await withRef(tester, togglePrivacyEye);
    expect(container.read(amountsHiddenProvider), isTrue);
    expect(container.read(privacySettingsProvider).hideAmounts, isTrue);
  });
}
