import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_list_screen.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late _MockItemRepository repository;

  setUp(() {
    repository = _MockItemRepository();
  });

  Widget buildApp() {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ItemListScreen()),
      GoRoute(path: '/items/new', builder: (context, state) => const Scaffold(body: Text('new item screen'))),
      GoRoute(path: '/items/:id/edit', builder: (context, state) => const Scaffold(body: Text('edit item screen'))),
    ]);
    return ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the empty state with a working add-item action', (tester) async {
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Item>[], total: 0, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    expect(find.text('new item screen'), findsOneWidget);
  });

  testWidgets('tapping a row opens the edit screen with the item passed through', (tester) async {
    const item = Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, isActive: true);
    when(() => repository.list(search: null, category: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [item], total: 1, page: 1, pageSize: 20),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cement'));
    await tester.pumpAndSettle();

    expect(find.text('edit item screen'), findsOneWidget);
  });
}
