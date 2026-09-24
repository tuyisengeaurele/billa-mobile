/// Accepts either the emailed link or a bare token; the token is always the
/// last non-empty path segment, so a trailing slash or query string is harmless.
String? extractInviteToken(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  final segments = (uri != null && uri.pathSegments.isNotEmpty) ? uri.pathSegments : [trimmed];
  return segments.where((segment) => segment.isNotEmpty).lastOrNull;
}
