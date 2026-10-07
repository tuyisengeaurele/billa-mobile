import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/search_picker_sheet.dart';

void main() {
  testWidgets('shows fetched results and returns the tapped item', (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            selected = await showSearchPickerSheet<String>(
              context: context,
              title: 'Pick one',
              fetch: (search) async =>
                  ['Acme', 'Beta'].where((s) => s.toLowerCase().contains(search.toLowerCase())).toList(),
              itemBuilder: (item) => ListTile(title: Text(item)),
            );
          },
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    await tester.tap(find.text('Acme'));
    await tester.pumpAndSettle();

    expect(selected, 'Acme');
  });

  testWidgets('debounces search input to a single fetch per pause', (tester) async {
    var fetchCount = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showSearchPickerSheet<String>(
            context: context,
            title: 'Pick one',
            fetch: (search) async {
              fetchCount++;
              return ['Acme'];
            },
            itemBuilder: (item) => ListTile(title: Text(item)),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(fetchCount, 1);

    await tester.enterText(find.byKey(const Key('search-picker-field')), 'ac');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(fetchCount, 2);
  });

  testWidgets('a failed fetch shows a message and Retry loads the results', (tester) async {
    var failing = true;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showSearchPickerSheet<String>(
            context: context,
            title: 'Pick one',
            fetch: (search) async {
              if (failing) {
                throw DioException(requestOptions: RequestOptions(path: '/x'), type: DioExceptionType.connectionError);
              }
              return ['Acme'];
            },
            itemBuilder: (item) => ListTile(title: Text(item)),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Acme'), findsOneWidget);
  });
}
