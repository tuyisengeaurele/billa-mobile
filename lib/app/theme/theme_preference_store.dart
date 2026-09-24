import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemePreferenceStore {
  String? read();
  Future<void> write(String value);
}

class InMemoryThemePreferenceStore implements ThemePreferenceStore {
  String? _value;

  @override
  String? read() => _value;

  @override
  Future<void> write(String value) async => _value = value;
}

class SharedPreferencesThemePreferenceStore implements ThemePreferenceStore {
  SharedPreferencesThemePreferenceStore(this._preferences);

  static const _key = 'theme_mode';

  final SharedPreferences _preferences;

  @override
  String? read() => _preferences.getString(_key);

  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

// In-memory by default so tests and previews need no setup; main.dart swaps
// in the persistent store before the first frame.
final themePreferenceStoreProvider = Provider<ThemePreferenceStore>((ref) => InMemoryThemePreferenceStore());
