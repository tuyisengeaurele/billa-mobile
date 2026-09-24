import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// System-following by default; nothing sets a manual override yet, but this
// provider is the one place a settings screen would plug one in.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
