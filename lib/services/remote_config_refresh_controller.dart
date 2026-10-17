import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bounds failed startup fetches while allowing an offline session to recover
/// when its network returns. Successful sessions rely on real-time updates.
class RemoteConfigRefreshController {
  RemoteConfigRefreshController({
    required Future<bool> Function() fetch,
    required DateTime Function() lastFetchTime,
    required Stream<bool> connectivityChanges,
    required Future<bool> Function() checkConnectivity,
    DateTime Function()? now,
  })  : _fetch = fetch,
        _lastFetchTime = lastFetchTime,
        _checkConnectivity = checkConnectivity,
        _now = now ?? DateTime.now {
    _connectivitySubscription = connectivityChanges.distinct().listen(
      _onConnectivityChanged,
      onError: (Object error) {
        debugPrint('[RemoteConfig] connectivity listener failed: $error');
      },
    );
  }

  static const minimumFetchInterval = Duration(minutes: 30);
  static const _retryDelays = [
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
  ];
  static const _recoveryCooldown = Duration(minutes: 1);

  final Future<bool> Function() _fetch;
  final DateTime Function() _lastFetchTime;
  final Future<bool> Function() _checkConnectivity;
  final DateTime Function() _now;
  late final StreamSubscription<bool> _connectivitySubscription;
  Timer? _retry;
  DateTime? _lastAttempt;
  bool? _online;
  bool _active = true;
  bool _disposed = false;
  bool _fetching = false;
  bool _failed = false;
  int _retries = 0;

  Future<void> refresh() async {
    if (_disposed || !_active || _fetching) return;
    _retry?.cancel();
    _fetching = true;
    _lastAttempt = _now();
    var fetched = false;
    try {
      fetched = await _fetch();
    } catch (error) {
      debugPrint('[RemoteConfig] refresh failed: $error');
    } finally {
      _fetching = false;
    }
    if (_disposed) return;
    _failed = !fetched;
    if (fetched) {
      _retries = 0;
      return;
    }
    // A disconnected device waits for a network event. A connection type is
    // only a hint: captive portals and server failures still need a few retries.
    if (!_active || _online == false || _retries >= _retryDelays.length) return;
    _retry = Timer(_retryDelays[_retries++], () => unawaited(refresh()));
  }

  void _onConnectivityChanged(bool online) {
    final recovered = _online != true && online;
    _online = online;
    if (!online) {
      _retry?.cancel();
    } else if (recovered && _failed) {
      _recover();
    }
  }

  /// Rate-limit resume/reconnection events, including platforms that emit
  /// several connectivity events for one network change.
  void _recover() {
    if (_disposed || !_active || _fetching || _online == false) return;
    _retry?.cancel();
    _retries = 0;
    final elapsed = _lastAttempt == null
        ? _recoveryCooldown
        : _now().difference(_lastAttempt!);
    final delay = _recoveryCooldown - elapsed;
    if (delay > Duration.zero) {
      _retry = Timer(delay, () => unawaited(refresh()));
    } else {
      unawaited(refresh());
    }
  }

  void pause() {
    _active = false;
    _retry?.cancel();
  }

  Future<void> resume() async {
    if (_disposed) return;
    _active = true;
    // Android does not deliver connectivity changes in the background.
    try {
      final online = await _checkConnectivity();
      if (_disposed || !_active) return;
      _online = online;
    } catch (error) {
      debugPrint('[RemoteConfig] connectivity check failed: $error');
    }
    if (_failed ||
        _now().difference(_lastFetchTime()) >= minimumFetchInterval) {
      _recover();
    }
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
    unawaited(_connectivitySubscription.cancel());
  }
}
