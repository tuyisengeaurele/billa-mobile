import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/app/theme/theme_mode_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/appearance_screen.dart';

void main() {
  testWidgets('marks the current choice and switches on tap', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const AppearanceScreen()),
    ));

    expect(find.descendant(of: find.byKey(const Key('appearance-system')), matching: find.byIcon(Icons.check)), findsOneWidget);

    await tester.tap(find.byKey(const Key('appearance-dark')));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(find.descendant(of: find.byKey(const Key('appearance-dark')), matching: find.byIcon(Icons.check)), findsOneWidget);
  });
}
