import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// System-following by default; Phase 7's settings screen will expose the
// manual override this provider already has somewhere to plug into.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
