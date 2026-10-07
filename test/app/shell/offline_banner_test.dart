import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/shell/offline_banner.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/network/connectivity_provider.dart';
import 'package:billa_mobile/core/network/response_cache.dart';

void main() {
  late StreamController<bool> connectivity;
  late CacheScope scope;

  setUp(() {
    connectivity = StreamController<bool>.broadcast();
    scope = CacheScope();
    addTearDown(connectivity.close);
  });

  Widget host({VoidCallback? onRefresh}) => ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => connectivity.stream),
          cacheScopeProvider.overrideWithValue(scope),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: Column(children: [OfflineBanner(onRefresh: onRefresh ?? () {}), const Text('content')])),
        ),
      );

  testWidgets('shows nothing while online with fresh data', (tester) async {
    await tester.pumpWidget(host());
    connectivity.add(true);
    await tester.pumpAndSettle();

    expect(find.textContaining('saved data'), findsNothing);
  });

  testWidgets('says the phone is offline and that saved data is shown', (tester) async {
    await tester.pumpWidget(host());
    connectivity.add(false);
    await tester.pumpAndSettle();

    expect(find.text("You're offline. Showing saved data."), findsOneWidget);
    expect(find.text('Refresh'), findsNothing);
  });

  testWidgets('when online but a saved copy was served it says so and offers Refresh', (tester) async {
    var refreshed = 0;
    await tester.pumpWidget(host(onRefresh: () => refreshed++));
    connectivity.add(true);
    scope.stale.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Showing saved data'), findsOneWidget);
    await tester.tap(find.text('Refresh'));
    expect(refreshed, 1);
  });

  testWidgets('disappears when the connection returns and data is fresh', (tester) async {
    await tester.pumpWidget(host());
    connectivity.add(false);
    await tester.pumpAndSettle();
    expect(find.textContaining('offline'), findsOneWidget);

    connectivity.add(true);
    await tester.pumpAndSettle();

    expect(find.textContaining('offline'), findsNothing);
  });
}
