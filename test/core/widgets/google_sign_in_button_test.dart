import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/google_sign_in_button.dart';

void main() {
  Widget host({required VoidCallback onPressed, bool isLoading = false}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: GoogleSignInButton(onPressed: onPressed, isLoading: isLoading)),
      );

  testWidgets('shows the Google logo next to the label and reports taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(onPressed: () => taps++));

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    expect(taps, 1);
  });

  testWidgets('cannot be tapped while a sign-in is already running', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(onPressed: () => taps++, isLoading: true));

    await tester.tap(find.byType(OutlinedButton), warnIfMissed: false);

    expect(taps, 0);
    expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
  });
}
