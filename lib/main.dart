import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/network/api_client_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final apiClient = await ApiClient.create();

  runApp(ProviderScope(
    overrides: [apiClientProvider.overrideWithValue(apiClient)],
    child: const App(),
  ));
}
