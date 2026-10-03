import 'dart:async';
import 'package:dio/dio.dart';

final _inFlight = Expando<Completer<bool>>('refresh in flight');

/// The refresh token rotates on every use and the server ends the whole session
/// if a rotated token is presented twice, so everything that can notice an
/// expired access token (a request that got a 401, the startup check, coming
/// back to the app) must share one refresh call, never start its own.
///
/// True when the session was renewed, false when the server rejected the token,
/// and a [DioException] for anything else (offline, server down), which says
/// nothing about whether the session is still good.
Future<bool> refreshOnce(Dio dio) {
  final running = _inFlight[dio];
  if (running != null) return running.future;

  final completer = Completer<bool>();
  _inFlight[dio] = completer;
  dio.post<void>('/auth/refresh').then((_) {
    completer.complete(true);
  }).catchError((Object error) {
    if (error is DioException && error.response?.statusCode == 401) {
      completer.complete(false);
    } else {
      completer.completeError(error);
    }
  }).whenComplete(() {
    _inFlight[dio] = null;
  });
  return completer.future;
}
