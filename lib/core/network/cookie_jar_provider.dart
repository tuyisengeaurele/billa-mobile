import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../storage/secure_storage.dart';
import 'secure_cookie_storage.dart';

Future<PersistCookieJar> createCookieJar() async {
  await _removeLegacyCookieFiles();
  return PersistCookieJar(storage: SecureCookieStorage(SecureStorage()));
}

/// Earlier builds kept cookies in a plain file. Leaving it behind would keep
/// the credential readable and backed up, so it is deleted; the one-time cost
/// is that those installs sign in again.
Future<void> _removeLegacyCookieFiles() async {
  try {
    final dir = await getApplicationSupportDirectory();
    final legacy = Directory('${dir.path}/cookies');
    if (await legacy.exists()) await legacy.delete(recursive: true);
  } catch (_) {
    // A leftover directory is not worth blocking the launch.
  }
}
