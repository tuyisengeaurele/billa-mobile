import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/router.dart';
import 'app/theme/theme_preference_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_client_provider.dart';
import 'core/platform/glass_support.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/session_snapshot_store.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The fonts ship inside the app; a download on slow data would only delay text.
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final apiClient = await ApiClient.create();
  final preferences = await SharedPreferences.getInstance();
  final glassBlur = await detectGlassBlurSupport();
  final sessionSnapshot = await SecureSessionSnapshotStore.load(SecureStorage(), preferences);

  runApp(ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
      themePreferenceStoreProvider.overrideWithValue(SharedPreferencesThemePreferenceStore(preferences)),
      glassBlurEnabledProvider.overrideWithValue(glassBlur),
      splashDurationProvider.overrideWithValue(const Duration(seconds: 2)),
      sessionSnapshotStoreProvider.overrideWithValue(sessionSnapshot),
    ],
    child: const App(),
  ));
}
