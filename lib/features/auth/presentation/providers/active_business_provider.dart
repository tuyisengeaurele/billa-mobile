import 'package:flutter_riverpod/flutter_riverpod.dart';
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
