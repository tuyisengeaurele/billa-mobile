import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether glass surfaces may blur what is behind them. True by default so
/// tests and previews see the full effect; `main` overrides it with the
/// result of [detectGlassBlurSupport].
final glassBlurEnabledProvider = Provider<bool>((ref) => true);

/// A live blur redraws everything behind it every frame, which a low-end
/// phone cannot afford. Android 10 and up on a device that is not flagged as
/// low-RAM is the line; anything else gets the same tint without the blur.
Future<bool> detectGlassBlurSupport({DeviceInfoPlugin? plugin}) async {
  if (!Platform.isAndroid) return true;
  final info = await (plugin ?? DeviceInfoPlugin()).androidInfo;
  return info.version.sdkInt >= 29 && !info.isLowRamDevice;
}
