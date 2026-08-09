import 'package:flixquest/functions/video_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoUtils.videoQualityHeight', () {
    test('parses provider labels with codec and audio metadata', () {
      expect(VideoUtils.videoQualityHeight('480p AAC'), 480);
      expect(VideoUtils.videoQualityHeight('480 AAC'), 480);
      expect(VideoUtils.videoQualityHeight('1080P (HEVC/AAC)'), 1080);
    });

    test('parses dimensions and ignores audio bitrates', () {
      expect(VideoUtils.videoQualityHeight('1920x1080 • AAC 128'), 1080);
      expect(VideoUtils.videoQualityHeight('AAC 320 kbps'), isNull);
      expect(VideoUtils.videoQualityHeight('Auto'), isNull);
    });
  });

  group('VideoUtils.preferredVideoSource', () {
    final sources = <String, String>{
      '1080p HEVC': 'high',
      '480p AAC': 'medium',
      '360 AAC': 'low',
    };

    test('matches an exact parsed height', () {
      expect(VideoUtils.preferredVideoSource(sources, 1080)?.key, '1080p HEVC');
    });

    test('uses the highest source below a missing preferred height', () {
      expect(VideoUtils.preferredVideoSource(sources, 720)?.key, '480p AAC');
    });

    test('uses the smallest source when all exceed the preference', () {
      expect(VideoUtils.preferredVideoSource(sources, 240)?.key, '360 AAC');
    });

    test('prefers an explicitly automatic source for auto', () {
      final withAuto = {'1080p': 'high', 'Auto AAC': 'master'};
      expect(VideoUtils.preferredVideoSource(withAuto, 0)?.key, 'Auto AAC');
    });

    test('uses a safe measured quality when auto has no master playlist', () {
      final cinebyStyleSources = {
        'Voesx': 'alternate-host',
        'playhq': 'another-host',
        '480p': 'medium',
        '720p': 'balanced',
        '1080p': 'high',
        '2160p': 'ultra',
      };

      expect(
        VideoUtils.preferredVideoSource(cinebyStyleSources, 0)?.key,
        '720p',
      );
    });

    test('uses the closest lower quality for automatic fallback', () {
      final sourcesWithout720p = {
        'Provider fallback': 'alternate-host',
        '480p': 'medium',
        '1080p': 'high',
      };

      expect(
        VideoUtils.preferredVideoSource(sourcesWithout720p, 0)?.key,
        '480p',
      );
    });
  });

  group('VideoUtils.reverseVideoQualityMap', () {
    test('sorts measured qualities and leaves host labels at the end', () {
      final ordered = VideoUtils.reverseVideoQualityMap({
        '480p': 'medium',
        'Voesx': 'alternate-1',
        '2160p': 'ultra',
        'playhq': 'alternate-2',
        '1080p': 'high',
        '720p': 'balanced',
      });

      expect(
        ordered.keys,
        ['2160p', '1080p', '720p', '480p', 'Voesx', 'playhq'],
      );
    });
  });
}
