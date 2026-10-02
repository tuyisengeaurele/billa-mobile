import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/network/api_client.dart';

void main() {
  test('every request names the phone so the devices list can tell phones apart', () {
    final options = buildApiOptions(deviceName: 'TECNO CC7, Android 9');

    expect(options.headers['X-Billa-Device'], 'TECNO CC7, Android 9');
    expect(options.baseUrl, apiBaseUrl);
  });
}
