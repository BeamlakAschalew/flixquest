import 'package:flixquest/screens/common/player/player_completion_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerCompletionDetector', () {
    test('completes when playback reaches the exact end', () {
      final detector = PlayerCompletionDetector();

      detector.observe(
        position: const Duration(seconds: 30),
        duration: const Duration(seconds: 100),
        isPlaying: true,
        isBuffering: false,
      );

      expect(
        detector.observe(
          position: const Duration(seconds: 100),
          duration: const Duration(seconds: 100),
          isPlaying: false,
          isBuffering: false,
        ),
        isTrue,
      );
    });

    test('completes when a playing stream stalls just before its end', () {
      final detector = PlayerCompletionDetector();

      for (var index = 0; index < 2; index++) {
        expect(
          detector.observe(
            position: const Duration(milliseconds: 99200),
            duration: const Duration(seconds: 100),
            isPlaying: true,
            isBuffering: false,
          ),
          isFalse,
        );
      }

      expect(
        detector.observe(
          position: const Duration(milliseconds: 99200),
          duration: const Duration(seconds: 100),
          isPlaying: true,
          isBuffering: false,
        ),
        isTrue,
      );
    });

    test('does not treat a pause or buffering near the end as completion', () {
      final detector = PlayerCompletionDetector();

      for (var index = 0; index < 4; index++) {
        expect(
          detector.observe(
            position: const Duration(milliseconds: 99000),
            duration: const Duration(seconds: 100),
            isPlaying: index.isOdd,
            isBuffering: index.isOdd,
          ),
          isFalse,
        );
      }
    });

    test('reports completion once and can be reset for another source', () {
      final detector = PlayerCompletionDetector();

      bool reachEnd() => detector.observe(
            position: const Duration(seconds: 100),
            duration: const Duration(seconds: 100),
            isPlaying: true,
            isBuffering: false,
          );

      expect(reachEnd(), isTrue);
      expect(reachEnd(), isFalse);
      detector.reset();
      expect(reachEnd(), isTrue);
    });
  });
}
