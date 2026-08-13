import 'package:flutter/foundation.dart';

/// Provides a conservative fallback for platforms which reach the end of a
/// stream without emitting a native completion event.
///
/// An exact end position completes immediately. A slightly inaccurate end
/// position must remain stable while the player still reports that it is
/// playing, which avoids treating an ordinary pause or seek as completion.
class PlayerCompletionDetector {
  PlayerCompletionDetector({
    this.endTolerance = const Duration(milliseconds: 250),
    this.stalledEndTolerance = const Duration(seconds: 2),
    this.stablePositionTolerance = const Duration(milliseconds: 120),
    this.requiredStableSamples = 2,
  });

  final Duration endTolerance;
  final Duration stalledEndTolerance;
  final Duration stablePositionTolerance;
  final int requiredStableSamples;

  Duration? _lastPosition;
  int _stableNearEndSamples = 0;
  bool _hasPlayed = false;
  bool _completed = false;

  @visibleForTesting
  bool get completed => _completed;

  void reset() {
    _lastPosition = null;
    _stableNearEndSamples = 0;
    _hasPlayed = false;
    _completed = false;
  }

  bool observe({
    required Duration position,
    required Duration duration,
    required bool isPlaying,
    required bool isBuffering,
  }) {
    if (_completed || duration <= Duration.zero) return false;
    if (isPlaying) _hasPlayed = true;

    final remaining = duration - position;
    if (_hasPlayed && remaining <= endTolerance) {
      _completed = true;
      return true;
    }

    final nearEnd = remaining <= stalledEndTolerance;
    final previous = _lastPosition;
    final isStable = previous != null &&
        (position - previous).abs() <= stablePositionTolerance;
    _lastPosition = position;

    if (!nearEnd || !isPlaying || isBuffering || !isStable) {
      _stableNearEndSamples = 0;
      return false;
    }

    _stableNearEndSamples++;
    if (_stableNearEndSamples < requiredStableSamples) return false;

    _completed = true;
    return true;
  }
}
