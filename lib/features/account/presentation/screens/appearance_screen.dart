import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_mode_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  static const _choices = [
    (ThemeMode.system, 'System default'),
    (ThemeMode.light, 'Light'),
    (ThemeMode.dark, 'Dark'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (mode, label) in _choices)
            ListTile(
              key: Key('appearance-${mode.name}'),
              title: Text(label),
              trailing: mode == current ? const Icon(Icons.check) : null,
              onTap: () => ref.read(themeModeProvider.notifier).set(mode),
            ),
        ],
      ),
    );
  }
}
