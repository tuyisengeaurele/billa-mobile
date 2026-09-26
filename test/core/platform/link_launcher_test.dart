import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/platform/link_launcher.dart';

void main() {
  late List<Uri> launched;
  late bool succeeds;
  late UrlLinkLauncher launcher;

  setUp(() {
    launched = [];
    succeeds = true;
    launcher = UrlLinkLauncher((uri) async {
      launched.add(uri);
      return succeeds;
    });
  });

  test('call opens the dialer with an international number', () async {
    expect(await launcher.call('0788 123 456'), isTrue);

    expect(launched.single.toString(), 'tel:+250788123456');
  });

  test('sms opens the messages app with the text encoded', () async {
    expect(await launcher.sms('0788123456', body: 'Hello & thanks'), isTrue);

    expect(launched.single.scheme, 'sms');
    expect(launched.single.path, '+250788123456');
    expect(launched.single.queryParameters['body'], 'Hello & thanks');
  });

  test('whatsapp opens a wa.me link with digits only and the text encoded', () async {
    expect(await launcher.whatsapp('+250 788 123 456', 'Invoice INV-1: RWF 5,000'), isTrue);

    final uri = launched.single;
    expect(uri.host, 'wa.me');
    expect(uri.path, '/250788123456');
    expect(uri.queryParameters['text'], 'Invoice INV-1: RWF 5,000');
  });

  test('a number that cannot be dialled opens nothing and reports failure', () async {
    expect(await launcher.call('not a number'), isFalse);
    expect(await launcher.whatsapp('', 'hi'), isFalse);

    expect(launched, isEmpty);
  });

  test('reports failure when nothing on the phone can handle the link', () async {
    succeeds = false;

    expect(await launcher.call('0788123456'), isFalse);
  });

  test('reports failure instead of throwing when the platform errors', () async {
    final throwing = UrlLinkLauncher((uri) async => throw Exception('no handler'));

    expect(await throwing.call('0788123456'), isFalse);
  });
}
