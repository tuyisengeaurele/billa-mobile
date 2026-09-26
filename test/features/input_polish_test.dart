import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_form_screen.dart';
import 'package:billa_mobile/features/items/domain/item_repository.dart';
import 'package:billa_mobile/features/items/presentation/providers/item_repository_provider.dart';
import 'package:billa_mobile/features/items/presentation/screens/item_form_screen.dart';
import '../support/tall_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockItemRepository extends Mock implements ItemRepository {}

TextField _field(WidgetTester tester, Key key) => tester.widget<TextField>(find.byKey(key));

void main() {
  Future<void> pump(WidgetTester tester, Widget screen, List<Override> overrides) async {
    useTallScreen(tester);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (context, state) => screen)]);
    await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  group('customer form', () {
    testWidgets('uses the keyboard that fits each field', (tester) async {
      await pump(tester, const CustomerFormScreen(), [customerRepositoryProvider.overrideWithValue(_MockCustomerRepository())]);

      expect(_field(tester, const Key('customer-form-phone')).keyboardType, TextInputType.phone);
      expect(_field(tester, const Key('customer-form-email')).keyboardType, TextInputType.emailAddress);
      expect(_field(tester, const Key('customer-form-name')).textCapitalization, TextCapitalization.words);
    });

    testWidgets('offers phone and email autofill and moves between fields', (tester) async {
      await pump(tester, const CustomerFormScreen(), [customerRepositoryProvider.overrideWithValue(_MockCustomerRepository())]);

      expect(_field(tester, const Key('customer-form-phone')).autofillHints, contains(AutofillHints.telephoneNumber));
      expect(_field(tester, const Key('customer-form-email')).autofillHints, contains(AutofillHints.email));
      expect(_field(tester, const Key('customer-form-name')).textInputAction, TextInputAction.next);
      expect(_field(tester, const Key('customer-form-email')).textInputAction, TextInputAction.done);
    });
  });

  group('item form', () {
    testWidgets('the tax rate allows a decimal point and the unit price takes digits only', (tester) async {
      await pump(tester, const ItemFormScreen(), [itemRepositoryProvider.overrideWithValue(_MockItemRepository())]);

      expect(_field(tester, const Key('item-form-tax-rate')).keyboardType, const TextInputType.numberWithOptions(decimal: true));

      await tester.enterText(find.byKey(const Key('item-form-unit-price')), '1,2a50');
      expect(_field(tester, const Key('item-form-unit-price')).controller!.text, '1250');
    });
  });
}
