import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/platform/contact_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('billa/contact_picker');

  void reply(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler);
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
  }

  test('returns the name and number of the contact that was picked', () async {
    reply((call) async {
      expect(call.method, 'pickPhone');
      return {'name': 'Ada', 'phone': '0788 123 456'};
    });

    final picked = await MethodChannelContactPicker().pick();

    expect(picked?.name, 'Ada');
    expect(picked?.phone, '0788 123 456');
  });

  test('returns null when the user backs out', () async {
    reply((call) async => null);

    expect(await MethodChannelContactPicker().pick(), isNull);
  });

  test('reports that the phone has no contacts app', () async {
    reply((call) async => throw PlatformException(code: 'unavailable'));

    expect(() => MethodChannelContactPicker().pick(), throwsA(isA<ContactPickerUnavailable>()));
  });

  test('reports unavailable where the platform code does not exist', () async {
    expect(() => MethodChannelContactPicker().pick(), throwsA(isA<ContactPickerUnavailable>()));
  });
}
