import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/storage/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        switch (call.method) {
          case 'write':
            store[call.arguments['key'] as String] = call.arguments['value'] as String;
            return null;
          case 'read':
            return store[call.arguments['key'] as String];
          case 'delete':
            store.remove(call.arguments['key'] as String);
            return null;
          default:
            return null;
        }
      },
    );
  });

  test('writes then reads back a value', () async {
    final storage = SecureStorage();
    await storage.write('lastActiveBusinessId', 'biz_123');
    expect(await storage.read('lastActiveBusinessId'), 'biz_123');
  });

  test('delete removes the value', () async {
    final storage = SecureStorage();
    await storage.write('k', 'v');
    await storage.delete('k');
    expect(await storage.read('k'), isNull);
  });

  test('reading a missing key returns null', () async {
    final storage = SecureStorage();
    expect(await storage.read('missing'), isNull);
  });
}
