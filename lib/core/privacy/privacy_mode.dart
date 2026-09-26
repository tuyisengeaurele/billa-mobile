import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'privacy_settings.dart';

/// Amounts the person has chosen to look at for now. It is not saved: every
/// launch starts hidden again when privacy mode is on.
final amountsRevealedProvider = StateProvider<bool>((ref) => false);

final amountsHiddenProvider = Provider<bool>((ref) {
  return ref.watch(privacySettingsProvider.select((s) => s.hideAmounts)) && !ref.watch(amountsRevealedProvider);
});

/// The eye on Home: turns privacy mode on if it was off, otherwise reveals or
/// hides amounts for this session.
void togglePrivacyEye(WidgetRef ref) {
  final settings = ref.read(privacySettingsProvider);
  if (!settings.hideAmounts) {
    ref.read(privacySettingsProvider.notifier).setHideAmounts(true);
    ref.read(amountsRevealedProvider.notifier).state = false;
    return;
  }
  ref.read(amountsRevealedProvider.notifier).update((revealed) => !revealed);
}
