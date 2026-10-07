import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/search/domain/search_repository.dart';
import 'package:billa_mobile/features/search/domain/search_result.dart';
import 'package:billa_mobile/features/search/presentation/providers/search_repository_provider.dart';
import 'package:billa_mobile/features/search/presentation/screens/search_screen.dart';

class _MockSearchRepository extends Mock implements SearchRepository {}

const _results = [
  SearchResult(type: SearchResultType.customer, id: 'c1', label: 'Acme Ltd', sublabel: '0788'),
  SearchResult(type: SearchResultType.item, id: 'i1', label: 'Acme widget', sublabel: 'RWF 500'),
  SearchResult(type: SearchResultType.document, id: 'd1', label: 'INV-0001', sublabel: 'Acme Ltd'),
];

void main() {
  late _MockSearchRepository repository;

  setUp(() {
    repository = _MockSearchRepository();
  });

  Widget buildApp() {
    final router = GoRouter(initialLocation: '/search', routes: [
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/customers/:id', builder: (context, state) => Scaffold(body: Text('customer ${state.pathParameters['id']}'))),
      GoRoute(path: '/items', builder: (context, state) => const Scaffold(body: Text('items list'))),
      GoRoute(path: '/documents/:id', builder: (context, state) => Scaffold(body: Text('document ${state.pathParameters['id']}'))),
    ]);
    return ProviderScope(
      overrides: [searchRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('search-field')), text);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('under two characters shows the hint and searches nothing', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await type(tester, 'a');

    expect(find.textContaining('Type at least 2 characters'), findsOneWidget);
    verifyNever(() => repository.search(any()));
  });

  testWidgets('a query shows results grouped by type', (tester) async {
    when(() => repository.search('acme')).thenAnswer((_) async => _results);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await type(tester, 'acme');

    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('INV-0001'), findsOneWidget);
  });

  testWidgets('each result opens its own screen', (tester) async {
    when(() => repository.search('acme')).thenAnswer((_) async => _results);

    for (final (id, marker) in [('c1', 'customer c1'), ('i1', 'items list'), ('d1', 'document d1')]) {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await type(tester, 'acme');
      await tester.tap(find.byKey(Key('search-result-$id')));
      await tester.pumpAndSettle();

      expect(find.text(marker), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('no matches says so and suggests what to try', (tester) async {
    when(() => repository.search('zzz')).thenAnswer((_) async => []);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await type(tester, 'zzz');

    expect(find.textContaining('No matches for "zzz"'), findsOneWidget);
  });

  testWidgets('a failure shows a message and Retry re-runs the same query', (tester) async {
    var failing = true;
    when(() => repository.search('acme')).thenAnswer((_) async {
      if (failing) {
        throw DioException(
          requestOptions: RequestOptions(path: '/search'),
          response: Response(requestOptions: RequestOptions(path: '/search'), data: {'error': 'subscription_required'}),
        );
      }
      return _results;
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await type(tester, 'acme');
    expect(find.text('An active subscription is required to do that'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-result-c1')), findsOneWidget);
    verify(() => repository.search('acme')).called(2);
  });

  testWidgets('fast typing fires a single request', (tester) async {
    when(() => repository.search('acme')).thenAnswer((_) async => _results);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    for (final partial in ['ac', 'acm', 'acme']) {
      await tester.enterText(find.byKey(const Key('search-field')), partial);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    verify(() => repository.search('acme')).called(1);
    verifyNever(() => repository.search('ac'));
    verifyNever(() => repository.search('acm'));
  });
}
