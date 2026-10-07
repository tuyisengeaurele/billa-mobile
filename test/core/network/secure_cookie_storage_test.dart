import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/network/secure_cookie_storage.dart';
import 'package:billa_mobile/core/storage/secure_storage.dart';

class _FakeSecureStorage extends SecureStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.of(values);
}

void main() {
  late _FakeSecureStorage backing;
  late SecureCookieStorage storage;

  setUp(() {
    backing = _FakeSecureStorage();
    storage = SecureCookieStorage(backing);
  });

  test('writes then reads a value back', () async {
    await storage.write('k', 'v');

    expect(await storage.read('k'), 'v');
    expect(await storage.read('missing'), isNull);
  });

  test('keeps cookie entries apart from anything else in secure storage', () async {
    await backing.write('unrelated', 'keep');
    await storage.write('k', 'v');

    expect(backing.values.keys, containsAll(['unrelated', 'cookie:k']));
  });

  test('delete removes one entry', () async {
    await storage.write('a', '1');
    await storage.write('b', '2');

    await storage.delete('a');

    expect(await storage.read('a'), isNull);
    expect(await storage.read('b'), '2');
  });

  test('deleteAll clears every cookie entry and leaves other secrets alone', () async {
    await backing.write('unrelated', 'keep');
    await storage.write('a', '1');
    await storage.write('b', '2');

    await storage.deleteAll(['a']);

    expect(await storage.read('a'), isNull);
    expect(await storage.read('b'), isNull);
    expect(backing.values['unrelated'], 'keep');
  });

  test('a cookie saved by one jar is found by the next one', () async {
    final uri = Uri.parse('https://api.example.com/');
    final first = PersistCookieJar(storage: storage);
    await first.saveFromResponse(uri, [Cookie('refresh', 'token-1')..expires = DateTime.now().add(const Duration(days: 30))]);

    final second = PersistCookieJar(storage: SecureCookieStorage(backing));
    final cookies = await second.loadForRequest(uri);

    expect(cookies.map((c) => '${c.name}=${c.value}'), ['refresh=token-1']);
  });
}
