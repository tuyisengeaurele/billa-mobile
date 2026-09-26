import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/platform/contact_picker.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_form_screen.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _FakePicker implements ContactPicker {
  _FakePicker(this.result, {this.error});

  final PickedContact? result;
  final Object? error;

  @override
  Future<PickedContact?> pick() async {
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  late _MockCustomerRepository repository;
  _FakePicker? picker;

  setUp(() {
    repository = _MockCustomerRepository();
    picker = null;
  });

  Widget buildApp(Widget home) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => home),
    ]);
    return ProviderScope(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        if (picker != null) contactPickerProvider.overrideWithValue(picker!),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('create sends only the filled-in fields', (tester) async {
    when(() => repository.create(name: 'Acme', tin: null, address: null, phone: null, email: null)).thenAnswer(
      (_) async => const Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z'),
    );

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme');
    await tester.tap(find.byKey(const Key('customer-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.create(name: 'Acme', tin: null, address: null, phone: null, email: null)).called(1);
  });

  testWidgets('edit pre-fills the existing customer and calls update with its id', (tester) async {
    const existing = Customer(id: 'c1', name: 'Acme', phone: '0788000000', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
    when(() => repository.update('c1', name: 'Acme Ltd', tin: null, address: null, phone: '0788000000', email: null)).thenAnswer(
      (_) async => existing,
    );

    await tester.pumpWidget(buildApp(const CustomerFormScreen(existing: existing)));
    expect(find.text('0788000000'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme Ltd');
    await tester.tap(find.byKey(const Key('customer-form-save')));
    await tester.pumpAndSettle();

    verify(() => repository.update('c1', name: 'Acme Ltd', tin: null, address: null, phone: '0788000000', email: null)).called(1);
  });

  testWidgets('a failed save keeps what was typed, says why, and Retry saves it', (tester) async {
    var failing = true;
    when(() => repository.create(name: 'Acme', tin: null, address: null, phone: '0788000000', email: null)).thenAnswer((_) async {
      if (failing) throw DioException(requestOptions: RequestOptions(path: '/customers'), type: DioExceptionType.connectionError);
      return const Customer(id: 'c1', name: 'Acme', isActive: true, createdAt: '2026-01-01T00:00:00.000Z');
    });

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme');
    await tester.enterText(find.widgetWithText(TextField, 'Phone (optional)'), '0788000000');
    await tester.tap(find.byKey(const Key('customer-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('0788000000'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => repository.create(name: 'Acme', tin: null, address: null, phone: '0788000000', email: null)).called(2);
  });

  testWidgets('From contacts fills the name and number of the chosen person', (tester) async {
    picker = _FakePicker(const PickedContact(name: 'Ada Lovelace', phone: '0788 123 456'));

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.tap(find.byKey(const Key('customer-form-import')));
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('0788 123 456'), findsOneWidget);
  });

  testWidgets('choosing a contact keeps a name that was already typed and fills the number', (tester) async {
    picker = _FakePicker(const PickedContact(name: 'Ada Lovelace', phone: '0788123456'));

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme Ltd');
    await tester.tap(find.byKey(const Key('customer-form-import')));
    await tester.pumpAndSettle();

    expect(find.text('Acme Ltd'), findsOneWidget);
    expect(find.text('0788123456'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsNothing);
  });

  testWidgets('backing out of the picker changes nothing', (tester) async {
    picker = _FakePicker(null);

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.enterText(find.byKey(const Key('customer-form-name')), 'Acme Ltd');
    await tester.tap(find.byKey(const Key('customer-form-import')));
    await tester.pumpAndSettle();

    expect(find.text('Acme Ltd'), findsOneWidget);
  });

  testWidgets('a phone with no contacts app says so', (tester) async {
    picker = _FakePicker(null, error: const ContactPickerUnavailable());

    await tester.pumpWidget(buildApp(const CustomerFormScreen()));
    await tester.tap(find.byKey(const Key('customer-form-import')));
    await tester.pumpAndSettle();

    expect(find.text("This phone has no contacts app. Type the details instead"), findsOneWidget);
  });
}
