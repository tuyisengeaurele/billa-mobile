import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

Future<PersistCookieJar> createCookieJar() async {
  final dir = await getApplicationSupportDirectory();
  return PersistCookieJar(storage: FileStorage('${dir.path}/cookies'));
}
