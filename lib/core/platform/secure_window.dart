import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marks the app window as secure: hidden in the recent apps list and
/// protected from screenshots and screen recording.
abstract class SecureWindow {
  Future<void> setSecure(bool secure);
}

class MethodChannelSecureWindow implements SecureWindow {
  MethodChannelSecureWindow([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('billa/secure_window');

  final MethodChannel _channel;

  @override
  Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', {'secure': secure});
    } on MissingPluginException {
      // Platforms without the native side simply have no such protection.
    }
  }
}

final secureWindowProvider = Provider<SecureWindow>((ref) => MethodChannelSecureWindow());
