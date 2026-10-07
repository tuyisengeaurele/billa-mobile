import 'api_client.dart';

/// The backend stores uploads as relative paths, so anything not already
/// absolute needs the API origin in front before an image widget can load it.
String resolveAssetUrl(String url, {String base = apiBaseUrl}) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final origin = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  return url.startsWith('/') ? '$origin$url' : '$origin/$url';
}
