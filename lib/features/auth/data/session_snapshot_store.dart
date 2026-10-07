import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class SharedPreferencesSessionSnapshotStore implements SessionSnapshotStore {
  SharedPreferencesSessionSnapshotStore(this._preferences);

  static const _key = 'session_snapshot';

  final SharedPreferences _preferences;

  @override
  Authenticated? read() {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
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
  Future<void> write(Authenticated status) {
    return _preferences.setString(_key, jsonEncode({'user': status.user.toJson(), 'business': status.business.toJson()}));
  }

  @override
  Future<void> clear() => _preferences.remove(_key);
}

final sessionSnapshotStoreProvider = Provider<SessionSnapshotStore>((ref) => InMemorySessionSnapshotStore());
