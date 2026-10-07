import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_form_screen.dart';

class _MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late _MockItemRepository repository;

  setUp(() {
    repository = _MockItemRepository();
  });

  Widget buildApp(Widget home) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => home),
    ]);
    return ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('create parses numeric fields and defaults the tax rate', (tester) async {
    when(() => repository.create(description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: null)).thenAnswer(
      (_) async => const Item(id: 'i1', description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, isActive: true),
    );

    await tester.pumpWidget(buildApp(const ItemFormScreen()));
    await tester.enterText(find.byKey(const Key('item-form-description')), 'Cement');
    await tester.enterText(find.byKey(const Key('item-form-unit-price')), '13000');
    await tester.enterText(find.byKey(const Key('item-form-unit')), 'bag');
    await tester.tap(find.byKey(const Key('item-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(description: 'Cement', unitPrice: 13000, unit: 'bag', taxRate: 18, category: null)).called(1);
  });

  testWidgets('rejects a zero unit price instead of submitting', (tester) async {
    await tester.pumpWidget(buildApp(const ItemFormScreen()));
    await tester.enterText(find.byKey(const Key('item-form-description')), 'Cement');
    await tester.enterText(find.byKey(const Key('item-form-unit-price')), '0');
    await tester.enterText(find.byKey(const Key('item-form-unit')), 'bag');
    await tester.tap(find.byKey(const Key('item-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Check the highlighted fields'), findsOneWidget);
    verifyNever(() => repository.create(description: any(named: 'description'), unitPrice: any(named: 'unitPrice'), unit: any(named: 'unit')));
  });
}
