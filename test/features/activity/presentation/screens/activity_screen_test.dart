import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/core/widgets/loading_skeleton.dart';
import 'package:billa_mobile/features/activity/domain/activity_entry.dart';
import 'package:billa_mobile/features/activity/domain/activity_repository.dart';
import 'package:billa_mobile/features/activity/presentation/providers/activity_repository_provider.dart';
import 'package:billa_mobile/features/activity/presentation/screens/activity_screen.dart';

class _MockActivityRepository extends Mock implements ActivityRepository {}

ActivityEntry _entry(int n, {String action = 'MEMBER_JOINED', ActivityActor? actor, Map<String, dynamic>? metadata}) =>
    ActivityEntry(
      id: 'e$n',
      action: action,
      createdAt: '2020-01-02T10:00:00.000Z',
      actor: actor ?? ActivityActor(name: 'Person $n', email: 'p$n@example.com'),
      metadata: metadata,
    );

PaginatedResult<ActivityEntry> _page(List<ActivityEntry> entries, {int? total, int page = 1}) =>
    PaginatedResult(results: entries, total: total ?? entries.length, page: page, pageSize: 20);

void main() {
  late _MockActivityRepository repository;

  setUp(() => repository = _MockActivityRepository());

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ActivityScreen()),
      GoRoute(path: '/documents/new', builder: (context, state) => const Scaffold(body: Text('new document screen'))),
    ]);
    return ProviderScope(
      overrides: [activityRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows a skeleton while the first page loads', (tester) async {
    final pending = Completer<PaginatedResult<ActivityEntry>>();
    when(() => repository.list(page: 1, pageSize: 20)).thenAnswer((_) => pending.future);

    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(LoadingSkeleton), findsWidgets);
  });

  testWidgets('each row says who did what and when', (tester) async {
    when(() => repository.list(page: 1, pageSize: 20)).thenAnswer(
      (_) async => _page([
        _entry(1, action: 'DOCUMENT_FINALIZED', metadata: {'number': 'INV-0001'}),
        _entry(2, action: 'CUSTOMER_CREATED', metadata: {'name': 'Acme'}, actor: const ActivityActor(name: '', email: 'b@x.com')),
        _entry(3, action: 'MEMBER_JOINED', actor: null),
      ]),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Person 1 finalized INV-0001'), findsOneWidget);
    expect(find.text('b@x.com added customer Acme'), findsOneWidget);
    expect(find.text('Person 3 joined the team'), findsOneWidget);
    expect(find.text('2020-01-02'), findsWidgets);
  });

  testWidgets('an empty feed says what will appear and offers the first step', (tester) async {
    when(() => repository.list(page: 1, pageSize: 20)).thenAnswer((_) async => _page([]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Nothing has happened yet. Creating, finalizing and sharing documents shows up here.'), findsOneWidget);

    await tester.tap(find.text('Create a document'));
    await tester.pumpAndSettle();

    expect(find.text('new document screen'), findsOneWidget);
  });

  testWidgets('a failed load says so and Retry loads it', (tester) async {
    var failing = true;
    when(() => repository.list(page: 1, pageSize: 20)).thenAnswer((_) async {
      if (failing) throw Exception('offline');
      return _page([_entry(1)]);
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load the activity"), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Person 1 joined the team'), findsOneWidget);
  });

  testWidgets('scrolling to the end loads the next page', (tester) async {
    when(() => repository.list(page: 1, pageSize: 20)).thenAnswer(
      (_) async => _page([for (var i = 1; i <= 20; i++) _entry(i)], total: 22),
    );
    when(() => repository.list(page: 2, pageSize: 20)).thenAnswer(
      (_) async => _page([_entry(21), _entry(22)], total: 22, page: 2),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    verifyNever(() => repository.list(page: 2, pageSize: 20));

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    verify(() => repository.list(page: 2, pageSize: 20)).called(1);
    await tester.scrollUntilVisible(find.text('Person 22 joined the team'), 300);
    expect(find.text('Person 22 joined the team'), findsOneWidget);
  });
}
