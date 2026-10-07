import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/theme_mode_provider.dart';
import 'package:billa_mobile/app/theme/theme_preference_store.dart';

ProviderContainer _container(ThemePreferenceStore store) {
  final container = ProviderContainer(overrides: [themePreferenceStoreProvider.overrideWithValue(store)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('follows the system by default', () {
    expect(_container(InMemoryThemePreferenceStore()).read(themeModeProvider), ThemeMode.system);
  });

  test('restores a stored choice', () async {
    final store = InMemoryThemePreferenceStore();
    await store.write('dark');

    expect(_container(store).read(themeModeProvider), ThemeMode.dark);
  });

  test('set updates the state and persists the choice', () async {
    final store = InMemoryThemePreferenceStore();
    final container = _container(store);

    await container.read(themeModeProvider.notifier).set(ThemeMode.light);

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(store.read(), 'light');
  });

  test('an unrecognised stored value falls back to the system', () async {
    final store = InMemoryThemePreferenceStore();
    await store.write('sepia');

    expect(_container(store).read(themeModeProvider), ThemeMode.system);
  });
}
