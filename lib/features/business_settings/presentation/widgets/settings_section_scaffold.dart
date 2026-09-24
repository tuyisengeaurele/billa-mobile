import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/business_settings.dart';
import '../providers/business_settings_provider.dart';

/// Empty fields are sent as null: the backend rejects empty strings, and
/// null is how it clears a nullable field.
String? nullIfBlank(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Hosts a settings section once the business settings are loaded. Built on
/// `valueOrNull` so a reload after saving keeps the form (and whatever is
/// typed into it) on screen instead of flashing a skeleton.
class SettingsSectionScaffold extends ConsumerWidget {
  const SettingsSectionScaffold({super.key, required this.title, required this.builder});

  final String title;
  final Widget Function(BusinessSettings settings) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(businessSettingsProvider);
    final value = settings.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: value != null
          ? builder(value)
          : settings.hasError
              ? ErrorState(
                  message: "Couldn't load your business settings",
                  onRetry: () => ref.invalidate(businessSettingsProvider),
                )
              : const Padding(padding: EdgeInsets.all(16), child: LoadingSkeleton(height: 220)),
    );
  }
}
