import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/formatting/file_size.dart';

void main() {
  test('small files are in bytes', () => expect(formatFileSize(512), '512 B'));

  test('thousands of bytes are in KB, rounded to the nearest', () {
    expect(formatFileSize(1024), '1 KB');
    expect(formatFileSize(340 * 1024), '340 KB');
  });

  test('a megabyte or more shows one decimal', () {
    expect(formatFileSize(1024 * 1024), '1.0 MB');
    expect(formatFileSize((2.4 * 1024 * 1024).round()), '2.4 MB');
  });
}
