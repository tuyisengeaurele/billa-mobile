import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/onboarding/domain/business.dart';

const testUser = AuthUser(id: 'u1', email: 'ada@example.com', name: 'Ada', phone: '0788', totpEnabled: false, isAdmin: false);
const testBusiness = Business(id: 'b1', name: 'Acme');

class FakeAuthController extends AuthController {
  FakeAuthController([this._user = testUser]);

  final AuthUser _user;
  bool loggedOut = false;

  @override
  Future<AuthStatus> build() async => AuthStatus.authenticated(_user, testBusiness);

  @override
  Future<void> logout() async => loggedOut = true;
}

DioException apiError(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

/// Hosts [screen] at [path] inside a router that also answers the account
/// sub-routes with a labelled stub, so a tap can be asserted by its label.
Widget accountApp({
  required Widget screen,
  required String path,
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: path,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('home'))),
      GoRoute(path: path, builder: (context, state) => screen),
      for (final stub in const [
        '/settings/profile',
        '/settings/security',
        '/settings/notifications',
        '/settings/appearance',
        '/settings/security/two-factor',
        '/settings/security/sessions',
        '/settings/business',
      ])
        if (stub != path) GoRoute(path: stub, builder: (context, state) => Scaffold(body: Text('stub $stub'))),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}
