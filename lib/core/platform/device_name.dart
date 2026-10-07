import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

const _fallbackName = 'Billa app';
// The server keeps at most this many characters of the name.
const _maxLength = 60;

/// An HTTP header only carries printable ASCII, and one bad character would fail every request, so
/// anything else is dropped rather than risked.
String sanitizeDeviceName(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
  if (cleaned.isEmpty) return _fallbackName;
  return cleaned.length > _maxLength ? cleaned.substring(0, _maxLength).trim() : cleaned;
}

/// "TECNO CC7, Android 9": what the signed-in devices list shows for this phone. Never throws, because
/// a name is not worth failing a launch for.
Future<String> detectDeviceName({DeviceInfoPlugin? plugin}) async {
  try {
    final info = plugin ?? DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return sanitizeDeviceName('${android.model}, Android ${android.version.release}');
    }
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return sanitizeDeviceName('${ios.model}, iOS ${ios.systemVersion}');
    }
  } catch (_) {
    // Fall through to the generic name.
  }
  return _fallbackName;
}
