import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedContact {
  const PickedContact({required this.name, required this.phone});

  final String name;
  final String phone;
}

/// Lets the user choose someone from the phone's contacts. Returns null when
/// they back out; throws [ContactPickerUnavailable] when the phone cannot do it.
abstract class ContactPicker {
  Future<PickedContact?> pick();
}

class ContactPickerUnavailable implements Exception {
  const ContactPickerUnavailable();
}

class MethodChannelContactPicker implements ContactPicker {
  MethodChannelContactPicker([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('billa/contact_picker');

  final MethodChannel _channel;

  @override
  Future<PickedContact?> pick() async {
    try {
      final result = await _channel.invokeMapMethod<String, String>('pickPhone');
      if (result == null) return null;
      return PickedContact(name: result['name'] ?? '', phone: result['phone'] ?? '');
    } on PlatformException catch (e) {
      if (e.code == 'unavailable') throw const ContactPickerUnavailable();
      rethrow;
    } on MissingPluginException {
      throw const ContactPickerUnavailable();
    }
  }
}

final contactPickerProvider = Provider<ContactPicker>((ref) => MethodChannelContactPicker());
