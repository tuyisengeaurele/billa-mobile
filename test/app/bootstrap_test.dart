import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/router.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('an unreachable server at launch shows a connection message and Retry recovers', (tester) async {
    final repository = _MockAuthRepository();
    var offline = true;
    when(() => repository.me()).thenAnswer((_) async {
      if (offline) {
        throw DioException(requestOptions: RequestOptions(path: '/auth/me'), type: DioExceptionType.connectionError);
      }
      return const AuthStatus.unauthenticated();
    });
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: container.read(appRouterProvider)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);

    offline = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsNothing);
    expect(find.text('Log in'), findsWidgets);
  });
}
