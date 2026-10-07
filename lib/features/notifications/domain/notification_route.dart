final _documentPath = RegExp(r'^/documents/[^/]+$');

/// Maps the backend's web paths to mobile routes. Null means the
/// notification has nowhere to go here (admin-only pages), so the inbox marks
/// it read without offering a tap that would lead nowhere.
String? notificationRoute(String? link) {
  if (link == null) return null;
  if (_documentPath.hasMatch(link)) return link;
  // On the web a joined member is announced on the business settings page,
  // where the team lives; on mobile that is its own screen.
  if (link == '/settings') return '/team';
  return null;
}
