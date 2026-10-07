import 'package:cookie_jar/cookie_jar.dart';
import '../storage/secure_storage.dart';

/// Keeps the login cookies in the platform keystore rather than a plain file,
/// because the refresh cookie is the credential for a 30-day session.
class SecureCookieStorage implements Storage {
  SecureCookieStorage(this._secure);

  static const _prefix = 'cookie:';

  final SecureStorage _secure;

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) => _secure.read('$_prefix$key');

  @override
  Future<void> write(String key, String value) => _secure.write('$_prefix$key', value);

  @override
  Future<void> delete(String key) => _secure.delete('$_prefix$key');

  @override
  Future<void> deleteAll(List<String> keys) async {
    // The jar's own key list can miss entries after a crash, and a half-cleared
    // jar would leave a stale session behind, so everything under the prefix goes.
    final all = await _secure.readAll();
    for (final key in all.keys.where((key) => key.startsWith(_prefix))) {
      await _secure.delete(key);
    }
  }
}
