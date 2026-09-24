import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_status.dart';
import '../../../auth/domain/auth_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

/// The signed-in user, or null while signed out. Reads with `valueOrNull`
/// because `.value` throws when the auth provider is in an error state.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final status = ref.watch(authControllerProvider).valueOrNull;
  return status is Authenticated ? status.user : null;
});
