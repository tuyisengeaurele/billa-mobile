import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billa_mobile/app/app.dart';
import 'package:billa_mobile/features/auth/domain/auth_status.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('an unauthenticated boot lands on the login screen', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => _FakeAuthController(const AuthStatus.unauthenticated())),
      ],
      child: const App(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Log in'), findsWidgets);
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._status);
  final AuthStatus _status;

  @override
  Future<AuthStatus> build() async => _status;
}
