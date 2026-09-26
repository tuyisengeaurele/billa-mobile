import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/platform/secure_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('billa/secure_window');

  test('asks the platform to secure and to unsecure the window', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    await MethodChannelSecureWindow().setSecure(true);
    await MethodChannelSecureWindow().setSecure(false);

    expect(calls.map((c) => c.method), ['setSecure', 'setSecure']);
    expect(calls.map((c) => (c.arguments as Map)['secure']), [true, false]);
  });

  test('does nothing where the platform has no such protection', () async {
    await MethodChannelSecureWindow().setSecure(true);
  });
}
