import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/theme/theme_preference_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_client_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final apiClient = await ApiClient.create();
  final preferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
      themePreferenceStoreProvider.overrideWithValue(SharedPreferencesThemePreferenceStore(preferences)),
    ],
    child: const App(),
  ));
}
