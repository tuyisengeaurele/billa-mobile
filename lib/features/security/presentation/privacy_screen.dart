import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/privacy/privacy_settings.dart';
import '../../../core/security/app_lock.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  String? _lockMessage;

  Future<void> _setLock(bool enable) async {
    final settings = ref.read(privacySettingsProvider.notifier);
    if (!enable) {
      setState(() => _lockMessage = null);
      settings.setAppLock(false);
      return;
    }
    final lock = ref.read(appLockProvider.notifier);
    // Turning the lock on with no way to unlock it would lock the owner out of
    // their own business, so the phone must have one and the person must pass it.
    if (!await lock.canEnable()) {
      if (mounted) setState(() => _lockMessage = 'Set up a screen lock, fingerprint or face on this phone first');
      return;
    }
    final proven = await lock.unlock();
    if (!mounted) return;
    if (proven) {
      setState(() => _lockMessage = null);
      settings.setAppLock(true);
    } else {
      setState(() => _lockMessage = "Couldn't confirm it's you, so the lock stays off");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            key: const Key('privacy-lock'),
            title: const Text('Lock the app'),
            subtitle: const Text('Ask for your fingerprint, face or screen lock when you open Billa'),
            value: settings.appLock,
            onChanged: _setLock,
          ),
          if (_lockMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(_lockMessage!, style: TextStyle(color: colors.error)),
            ),
          if (settings.appLock) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Lock again'),
            ),
            RadioGroup<LockDelay>(
              groupValue: settings.lockDelay,
              onChanged: (value) {
                if (value != null) notifier.setLockDelay(value);
              },
              child: Column(
                children: [
                  for (final delay in LockDelay.values)
                    RadioListTile<LockDelay>(
                      key: Key('privacy-delay-${delay.name}'),
                      title: Text(delay.label),
                      value: delay,
                    ),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          SwitchListTile(
            key: const Key('privacy-hide-amounts'),
            title: const Text('Hide amounts'),
            subtitle: const Text('Show dots instead of money until you tap the eye on Home'),
            value: settings.hideAmounts,
            onChanged: notifier.setHideAmounts,
          ),
          SwitchListTile(
            key: const Key('privacy-secure-window'),
            title: const Text('Hide Billa in recent apps'),
            subtitle: const Text('Also blocks screenshots and screen recording'),
            value: settings.secureWindow,
            onChanged: notifier.setSecureWindow,
          ),
        ],
      ),
    );
  }
}
