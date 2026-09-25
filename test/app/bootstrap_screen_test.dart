import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/app/theme/bootstrap_screen.dart';
import 'package:billa_mobile/core/widgets/animated_brand_mark.dart';
import 'package:billa_mobile/features/auth/domain/auth_repository.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows the animated logo over a static wordmark, tagline, and the reason for waiting', (tester) async {
    final repository = _MockAuthRepository();
    // Never completes: the screen is shown while the session check is running.
    final pending = Completer<AuthStatus>();
    when(() => repository.me()).thenAnswer((_) => pending.future);

    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const BootstrapScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(AnimatedBrandMark), findsOneWidget);
    expect(find.text('Billa'), findsOneWidget);
    expect(find.text('Invoices, quotes and receipts for your business'), findsOneWidget);
    expect(find.text('Checking your session…'), findsOneWidget);

  });
}
