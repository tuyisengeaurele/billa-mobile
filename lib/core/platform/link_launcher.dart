import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../formatting/phone_number.dart';

/// Opens the phone's own apps for a number. Each method returns false when it
/// could not, so callers can say so instead of doing nothing.
abstract class LinkLauncher {
  Future<bool> call(String phone);
  Future<bool> sms(String phone, {String? body});
  Future<bool> whatsapp(String phone, String message);
}

class UrlLinkLauncher implements LinkLauncher {
  UrlLinkLauncher([Future<bool> Function(Uri uri)? launch]) : _launch = launch ?? _launchExternally;

  final Future<bool> Function(Uri uri) _launch;

  static Future<bool> _launchExternally(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  Future<bool> _open(Uri Function(String digits) build, String phone) async {
    final digits = normaliseRwandaNumber(phone);
    if (digits == null) return false;
    try {
      return await _launch(build(digits));
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> call(String phone) => _open((digits) => Uri(scheme: 'tel', path: '+$digits'), phone);

  @override
  Future<bool> sms(String phone, {String? body}) {
    return _open(
      (digits) => Uri(scheme: 'sms', path: '+$digits', queryParameters: body == null ? null : {'body': body}),
      phone,
    );
  }

  @override
  Future<bool> whatsapp(String phone, String message) {
    return _open((digits) => Uri.https('wa.me', '/$digits', {'text': message}), phone);
  }
}

final linkLauncherProvider = Provider<LinkLauncher>((ref) => UrlLinkLauncher());
