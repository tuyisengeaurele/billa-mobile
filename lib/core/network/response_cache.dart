import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedResponse {
  const CachedResponse({required this.statusCode, required this.data, required this.savedAt});

  final int statusCode;
  final Object? data;
  final DateTime savedAt;

  Map<String, Object?> toJson() => {'statusCode': statusCode, 'data': data, 'savedAt': savedAt.toIso8601String()};

  factory CachedResponse.fromJson(Map<String, dynamic> json) => CachedResponse(
        statusCode: json['statusCode'] as int,
        data: json['data'],
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

abstract class ResponseCache {
  Future<CachedResponse?> read(String key);
  Future<void> write(String key, CachedResponse value);
  Future<void> clear();
}

class InMemoryResponseCache implements ResponseCache {
  final _entries = <String, CachedResponse>{};

  @override
  Future<CachedResponse?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, CachedResponse value) async => _entries[key] = value;

  @override
  Future<void> clear() async => _entries.clear();
}

/// One small file per request, named by a hash of the key. The key is stored
/// inside the file too, so a hash collision reads as a miss instead of
/// returning another request's data.
class FileResponseCache implements ResponseCache {
  FileResponseCache(this._dir);

  final Directory _dir;

  File _file(String key) => File('${_dir.path}/${_hash(key)}.json');

  static String _hash(String key) {
    var hash = 0xcbf29ce484222325;
    for (final unit in utf8.encode(key)) {
      hash = ((hash ^ unit) * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }

  @override
  Future<CachedResponse?> read(String key) async {
    try {
      final file = _file(key);
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (json['key'] != key) return null;
      return CachedResponse.fromJson(json['entry'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, CachedResponse value) async {
    try {
      await _dir.create(recursive: true);
      await _file(key).writeAsString(jsonEncode({'key': key, 'entry': value.toJson()}), flush: true);
    } catch (_) {
      // Saving is a convenience; a full disk must not fail the request.
    }
  }

  @override
  Future<void> clear() async {
    try {
      if (await _dir.exists()) await _dir.delete(recursive: true);
    } catch (_) {
      // Nothing useful to do; the entries are per business and will be replaced.
    }
  }
}

/// Which business the cached data belongs to, and whether what the screens
/// are showing came from the saved copy.
class CacheScope {
  String businessId = '';
  final ValueNotifier<bool> stale = ValueNotifier(false);
}

final responseCacheProvider = Provider<ResponseCache>((ref) => InMemoryResponseCache());
final cacheScopeProvider = Provider<CacheScope>((ref) => CacheScope());
