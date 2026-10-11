import 'package:better_player_plus/better_player_plus.dart';
import 'package:flixquest/functions/subtitle_options.dart';
import 'package:flutter_test/flutter_test.dart';

BetterPlayerSubtitlesSource _network(String name, String url) =>
    BetterPlayerSubtitlesSource(
      type: BetterPlayerSubtitlesSourceType.network,
      urls: [url],
      name: name,
    );

BetterPlayerSubtitlesSource _file(String name, String path) =>
    BetterPlayerSubtitlesSource(
      type: BetterPlayerSubtitlesSourceType.file,
      urls: [path],
      name: name,
    );

const _wyzie = 'https://scraper.test/api/v2/subtitles/wyzie';
const _natsuki = 'https://scraper.test/api/v2/subtitles/natsuki';

void main() {
  group('buildSubtitleOptions', () {
    test('keeps every distinct track as its own row and numbers them', () {
      final first = _network('English', '$_wyzie/1.vtt');
      final second = _network('English', '$_wyzie/2.vtt');
      final third = _network('English', '$_wyzie/3.vtt');

      final options = buildSubtitleOptions([first, second, third]);

      expect(options, hasLength(3));
      expect(options.map((option) => option.number), [1, 2, 3]);
      expect(
        options.map((option) => option.name),
        ['English', 'English', 'English'],
      );
      expect(options.first.source, same(first));
      expect(options[1].source, same(second));
    });

    test('a language with a single track is not numbered', () {
      final options = buildSubtitleOptions([
        _network('English', '$_wyzie/1.vtt'),
        _network('German', '$_wyzie/2.vtt'),
      ]);

      expect(options.map((option) => option.number), [null, null]);
    });

    test('does not number a name that already carries one', () {
      final options = buildSubtitleOptions([
        _network('English #1', '$_wyzie/1.vtt'),
        _network('English #2 (HI)', '$_wyzie/2.vtt'),
        _network('English #2', '$_wyzie/3.vtt'),
      ]);

      expect(options.map((option) => option.number), [null, null, null]);
      // The `#2` marker is a sequence number, so `English #1` and `English #2`
      // are the same language and fall through to each other.
      expect(options.first.fallbacks, hasLength(1));
      expect(options.first.fallbacks.single.name, 'English #2');
      // `(HI)` is a different track, not a numbered duplicate.
      expect(options[1].fallbacks, isEmpty);
    });

    test('drops a repeated url but keeps different urls', () {
      final first = _network('English', '$_wyzie/1.vtt');
      final repeat = _network('English', '$_wyzie/1.vtt');
      final other = _network('English', '$_wyzie/2.vtt');

      final options = buildSubtitleOptions([first, repeat, other]);

      expect(options, hasLength(2));
      expect(options.first.source, same(first));
      expect(options[1].source, same(other));
    });

    test('falls back within the language, own provider first', () {
      final wyzieOne = _network('English', '$_wyzie/1.vtt');
      final natsuki = _network('English', '$_natsuki/2.vtt');
      final wyzieTwo = _network('English', '$_wyzie/3.vtt');
      final german = _network('German', '$_wyzie/4.vtt');

      final options = buildSubtitleOptions([
        wyzieOne,
        natsuki,
        wyzieTwo,
        german,
      ]);

      expect(options.first.provider, 'wyzie');
      expect(options.first.fallbacks, [same(wyzieTwo), same(natsuki)]);
      expect(options[1].fallbacks, [same(wyzieOne), same(wyzieTwo)]);
      expect(options.last.fallbacks, isEmpty);
    });

    test('caps how many fallbacks one row chases', () {
      final sources = List.generate(
        maxSubtitleFallbacks + 3,
        (index) => _network('English', '$_wyzie/$index.vtt'),
      );

      final options = buildSubtitleOptions(sources);

      expect(options, hasLength(maxSubtitleFallbacks + 3));
      expect(options.first.fallbacks, hasLength(maxSubtitleFallbacks));
      expect(options.first.sources, hasLength(maxSubtitleFallbacks + 1));
    });

    test('preserves the incoming order, which carries the preference', () {
      final options = buildSubtitleOptions([
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.none,
          name: null,
        ),
        _network('English', '$_wyzie/1.vtt'),
        _network('German', '$_wyzie/2.vtt'),
      ]);

      expect(options.map((option) => option.name), [null, 'English', 'German']);
      expect(options.first.isOff, isTrue);
      expect(options.first.fallbacks, isEmpty);
      expect(options.first.sources, hasLength(1));
    });

    test('never substitutes a subtitle file the user added', () {
      final options = buildSubtitleOptions([
        _file('English', '/tmp/one.srt'),
        _file('English', '/tmp/two.srt'),
        _network('English', '$_wyzie/1.vtt'),
      ]);

      expect(options, hasLength(3));
      expect(options.first.fallbacks, isEmpty);
      expect(options[1].fallbacks, isEmpty);
      expect(options.last.fallbacks, isEmpty);
    });
  });
}
