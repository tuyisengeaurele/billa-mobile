import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_preference_store.dart';

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.read(themePreferenceStoreProvider).read();
    // An unrecognised stored value (from a newer or older build) falls back
    // to following the system rather than failing to start.
    return ThemeMode.values.where((mode) => mode.name == stored).firstOrNull ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(themePreferenceStoreProvider).write(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
