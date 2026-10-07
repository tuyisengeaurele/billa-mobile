import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'response_cache.dart';

bool _online(List<ConnectivityResult> results) => results.any((r) => r != ConnectivityResult.none);

/// Whether the phone reports any network at all. A connected phone can still
/// have no internet, which is why the saved-data flag below also matters.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_online);
});

/// True while the screens are showing a saved copy because a request failed.
final staleDataProvider = Provider<bool>((ref) {
  final notifier = ref.watch(cacheScopeProvider).stale;
  void onChange() => ref.invalidateSelf();
  notifier.addListener(onChange);
  ref.onDispose(() => notifier.removeListener(onChange));
  return notifier.value;
});

enum ConnectionNotice { none, offline, saved }

final connectionNoticeProvider = Provider<ConnectionNotice>((ref) {
  // While the first reading is pending or failed, assume online: a wrong
  // banner is worse than a missing one.
  final online = ref.watch(connectivityProvider).valueOrNull ?? true;
  if (!online) return ConnectionNotice.offline;
  return ref.watch(staleDataProvider) ? ConnectionNotice.saved : ConnectionNotice.none;
});
