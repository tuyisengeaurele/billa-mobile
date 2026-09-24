import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/presentation/widgets/password_requirements_list.dart';

void main() {
  testWidgets('shows all five requirement labels', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: PasswordRequirementsList(password: '')),
    ));

    expect(find.text('At least 8 characters'), findsOneWidget);
    expect(find.text('One lowercase letter'), findsOneWidget);
    expect(find.text('One uppercase letter'), findsOneWidget);
    expect(find.text('One number'), findsOneWidget);
    expect(find.text('One special character'), findsOneWidget);
  });

  testWidgets('marks a met requirement with a check icon', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: PasswordRequirementsList(password: 'Abcdef1!')),
    ));

    expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
  });

  testWidgets('leaves unmet requirements unchecked', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: PasswordRequirementsList(password: '')),
    ));

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(5));
  });
}
