import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../onboarding/domain/business.dart';
import '../../domain/auth_status.dart';
import 'auth_controller.dart';

/// Just the id, selected out of the auth state so dependents rebuild when the
/// business changes, not on every unrelated auth update. Reads with
/// `valueOrNull` because `.value` throws on an errored auth provider, which is
/// the normal state in tests that never override auth.
final activeBusinessIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider.select((auth) {
    return switch (auth.valueOrNull) {
      Authenticated(:final business) => business.id,
      _ => null,
    };
  }));
});

/// The whole business the session points at, for screens that need its name
/// or want to write a changed copy back after an edit.
final currentBusinessProvider = Provider<Business?>((ref) {
  final auth = ref.watch(authControllerProvider).valueOrNull;
  return auth is Authenticated ? auth.business : null;
});
