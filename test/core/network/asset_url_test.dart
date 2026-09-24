import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/network/asset_url.dart';

void main() {
  test('prefixes a relative upload path with the API origin', () {
    expect(resolveAssetUrl('/uploads/a.png', base: 'http://h:4000'), 'http://h:4000/uploads/a.png');
  });

  test('leaves an absolute URL alone', () {
    expect(resolveAssetUrl('https://cdn.example.com/a.png', base: 'http://h:4000'), 'https://cdn.example.com/a.png');
  });

  test('does not double the slash when the base ends with one', () {
    expect(resolveAssetUrl('/uploads/a.png', base: 'http://h:4000/'), 'http://h:4000/uploads/a.png');
  });
}
