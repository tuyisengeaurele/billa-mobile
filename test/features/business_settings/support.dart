import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import '../account/support.dart';

export '../account/support.dart' show FakeAuthController, apiError, testUser, testBusiness;

const testSettings = BusinessSettings(id: 'b1', name: 'Acme');

const businessSettingsRoutes = [
  '/settings/business',
  '/settings/business/details',
  '/settings/business/payments',
  '/settings/business/documents',
  '/settings/business/numbering',
  '/settings/business/logo',
];

/// Hosts [screen] at [path]; every other settings route answers with a
/// labelled stub so a tap can be asserted by its label.
Widget businessSettingsApp({
  required Widget screen,
  required String path,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: path,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home'))),
      GoRoute(path: path, builder: (context, state) => screen),
      for (final stub in businessSettingsRoutes)
        if (stub != path) GoRoute(path: stub, builder: (context, state) => Scaffold(body: Text('stub $stub'))),
    ],
  );
  return ProviderScope(
    overrides: [authControllerProvider.overrideWith(FakeAuthController.new), ...overrides],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}
