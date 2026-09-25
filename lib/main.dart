import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/router.dart';
import 'app/theme/theme_preference_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_client_provider.dart';
import 'core/platform/glass_support.dart';
import 'features/auth/data/session_snapshot_store.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final apiClient = await ApiClient.create();
  final preferences = await SharedPreferences.getInstance();
  final glassBlur = await detectGlassBlurSupport();

  runApp(ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
      themePreferenceStoreProvider.overrideWithValue(SharedPreferencesThemePreferenceStore(preferences)),
      glassBlurEnabledProvider.overrideWithValue(glassBlur),
      splashDurationProvider.overrideWithValue(const Duration(seconds: 2)),
      sessionSnapshotStoreProvider.overrideWithValue(SharedPreferencesSessionSnapshotStore(preferences)),
    ],
    child: const App(),
  ));
}
