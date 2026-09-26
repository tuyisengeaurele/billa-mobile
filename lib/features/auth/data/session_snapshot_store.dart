import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/secure_storage.dart';
import '../../onboarding/domain/business.dart';
import '../domain/auth_status.dart';
import '../domain/auth_user.dart';

/// The last signed-in user and business, kept so the app can open straight
/// into itself instead of waiting on the network to prove who is signed in.
/// It holds no credentials: the login itself lives in the cookie jar, and the
/// server still has the final say once the app has opened.
abstract class SessionSnapshotStore {
  Authenticated? read();
  Future<void> write(Authenticated status);
  Future<void> clear();
}

class InMemorySessionSnapshotStore implements SessionSnapshotStore {
  Authenticated? _value;

  @override
  Authenticated? read() => _value;

  @override
  Future<void> write(Authenticated status) async => _value = status;

  @override
  Future<void> clear() async => _value = null;
}

class SecureSessionSnapshotStore implements SessionSnapshotStore {
  SecureSessionSnapshotStore._(this._secure, this._value);

  static const _key = 'session_snapshot';

  final SecureStorage _secure;
  Authenticated? _value;

  /// Reads the stored snapshot once, so `read()` can stay synchronous for the
  /// auth controller's first build. Earlier builds kept it in plain
  /// preferences, which are deleted here.
  static Future<SecureSessionSnapshotStore> load(SecureStorage secure, SharedPreferences legacy) async {
    await legacy.remove(_key);
    final raw = await secure.read(_key);
    return SecureSessionSnapshotStore._(secure, raw == null ? null : _decode(raw));
  }

  static Authenticated? _decode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Authenticated(
        AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        Business.fromJson(json['business'] as Map<String, dynamic>),
      );
    } catch (_) {
      // A snapshot from an older shape of the data is worth nothing, and
      // falling back to the network check is always safe.
      return null;
    }
  }

  @override
  Authenticated? read() => _value;

  @override
  Future<void> write(Authenticated status) {
    _value = status;
    return _secure.write(_key, jsonEncode({'user': status.user.toJson(), 'business': status.business.toJson()}));
  }

  @override
  Future<void> clear() {
    _value = null;
    return _secure.delete(_key);
  }
}

final sessionSnapshotStoreProvider = Provider<SessionSnapshotStore>((ref) => InMemorySessionSnapshotStore());
