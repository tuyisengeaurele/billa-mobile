import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/platform/device_name.dart';

void main() {
  test('keeps a normal name as it is', () {
    expect(sanitizeDeviceName('TECNO CC7, Android 9'), 'TECNO CC7, Android 9');
  });

  test('removes characters an HTTP header cannot carry', () {
    expect(sanitizeDeviceName('Redmi Note 12 \u2013 5G\n'), 'Redmi Note 12  5G');
    expect(sanitizeDeviceName('T\u00e9l\u00e9phone'), 'Tlphone');
  });

  test('falls back to the app name when nothing usable is left', () {
    expect(sanitizeDeviceName(''), 'Billa app');
    expect(sanitizeDeviceName('   '), 'Billa app');
    expect(sanitizeDeviceName('\u2013\u2013'), 'Billa app');
  });

  test('stays within the length the server keeps', () {
    expect(sanitizeDeviceName('A' * 100).length, 60);
  });
}
