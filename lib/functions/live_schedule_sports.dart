import '../models/live_tv.dart';

/// A sport group derived from one schedule day. Groups come from the sport
/// emoji the upstream schedule puts on every event, and names from the
/// upstream category names inside each group. The one fixed list is
/// [_borrowedEmojiSports], for sports upstream marks with another's emoji.
class LiveSportSection {
  const LiveSportSection({
    required this.name,
    required this.emoji,
    required this.events,
  });

  final String name;

  /// Empty when the group is an upstream category kept as-is.
  final String emoji;
  final List<DaddyLiveEpgEvent> events;

  String get label => emoji.isEmpty ? name : '$emoji $name';
}

final Expando<List<LiveSportSection>> _cache =
    Expando<List<LiveSportSection>>();

/// Regroups [day] by sport, in the order sports first appear upstream. Events
/// inside a sport are merged across leagues, de-duplicated, and ordered by
/// start time. The result is cached per day instance.
List<LiveSportSection> groupScheduleBySport(DaddyLiveEpgDay day) =>
    _cache[day] ??= _group(day);

typedef _Entry = ({int index, String category, DaddyLiveEpgEvent event});

List<LiveSportSection> _group(DaddyLiveEpgDay day) {
  // Pass 1: bucket events by sport marker. The title's leading emoji is the
  // most specific (MMA events carry 🥋 inside a 🥊👊 category); the category
  // emoji covers titles without one.
  final byMarker = <String, ({String emoji, List<_Entry> entries})>{};
  final unmarked = <_Entry>[];
  final borrowed = <String, List<_Entry>>{};
  var index = 0;
  for (final category in day.categories) {
    for (final event in category.events) {
      final entry = (index: index++, category: category.name, event: event);
      final marker = _leadingEmoji(event.title) ?? _firstEmoji(category.name);
      // Squash under 🎾 is not tennis: a sport named by the title, or else
      // the category, wearing an emoji it borrows keeps its own section.
      final sport = marker == null
          ? null
          : _borrowedSport(marker.key, event.title) ??
              _borrowedSport(marker.key, category.name);
      if (sport != null) {
        (borrowed[sport] ??= <_Entry>[]).add(entry);
      } else if (marker == null) {
        unmarked.add(entry);
      } else {
        (byMarker[marker.key] ??= (emoji: marker.display, entries: []))
            .entries
            .add(entry);
      }
    }
  }

  // Pass 2: name each marker group from its categories. A group whose
  // categories never name a sport (a lone 🏋️ inside "PPV Events"), and every
  // unmarked event, stays under its upstream category instead.
  final sections =
      <String, ({String name, String emoji, List<_Entry> entries})>{};
  void add(String name, String emoji, Iterable<_Entry> entries) {
    final section = sections[name.toLowerCase()] ??=
        (name: name, emoji: emoji, entries: []);
    section.entries.addAll(entries);
  }

  for (final group in byMarker.values) {
    final weights = <String, int>{};
    for (final entry in group.entries) {
      weights.update(entry.category, (n) => n + 1, ifAbsent: () => 1);
    }
    final name = _sharedName(weights);
    if (name == null) {
      unmarked.addAll(group.entries);
    } else {
      add(name, group.emoji, group.entries);
    }
  }
  for (final entry in unmarked) {
    final name = _cleanCategoryName(entry.category);
    add(name.isEmpty ? entry.category : name, '', <_Entry>[entry]);
  }
  // The emoji they came with belongs to another sport, so they show none.
  for (final entry in borrowed.entries) {
    add(entry.key, '', entry.value);
  }

  int firstIndex(List<_Entry> entries) => entries.fold(
      entries.first.index, (min, e) => e.index < min ? e.index : min);
  final ordered = sections.values.toList()
    ..sort((a, b) => firstIndex(a.entries).compareTo(firstIndex(b.entries)));
  return <LiveSportSection>[
    for (final section in ordered)
      LiveSportSection(
        name: section.name,
        emoji: section.emoji,
        events: _byStartTime(_unique(section.entries)),
      ),
  ];
}

/// Sports the upstream schedule files under another sport's emoji: squash
/// and padel wear 🎾, Australian rules 🏉. Each is named by its own words in
/// an event title or category name, and split out only while it wears an
/// emoji in [borrows]; under an emoji of its own (🏓 table tennis) it groups
/// as any sport does.
final List<({String name, Set<String> borrows, RegExp pattern})>
    _borrowedEmojiSports =
    <({String name, Set<String> borrows, RegExp pattern})>[
  (name: 'Squash', borrows: {'🎾', '🏸'}, pattern: _words(r'squash')),
  (
    name: 'Padel',
    borrows: {'🎾', '🏸'},
    pattern: _words(r'padel|paddle tennis'),
  ),
  (
    name: 'Pickleball',
    borrows: {'🎾', '🏓'},
    pattern: _words(r'pickleball'),
  ),
  (
    name: 'Table Tennis',
    borrows: {'🎾'},
    pattern: _words(r'table tennis|ping pong'),
  ),
  (
    name: 'Aussie Rules',
    borrows: {'🏉', '🏈', '⚽'},
    pattern: _words(r'aussie rules|australian (?:rules )?football|aflw?'),
  ),
  (
    name: 'Gaelic Football',
    borrows: {'🏉', '🏈', '⚽'},
    pattern: _words(r'gaelic football'),
  ),
  (
    name: 'Hurling',
    borrows: {'🏑', '🏒'},
    pattern: _words(r'hurling|camogie'),
  ),
];

RegExp _words(String alternatives) =>
    RegExp('(?<![A-Za-z0-9])(?:$alternatives)(?![A-Za-z0-9])',
        caseSensitive: false);

/// The sport [text] names among those that borrow the emoji [marker].
String? _borrowedSport(String marker, String text) {
  for (final sport in _borrowedEmojiSports) {
    if (sport.borrows.contains(marker) && sport.pattern.hasMatch(text)) {
      return sport.name;
    }
  }
  return null;
}

List<DaddyLiveEpgEvent> _unique(List<_Entry> entries) {
  final seen = <String>{};
  return <DaddyLiveEpgEvent>[
    for (final entry in entries..sort((a, b) => a.index.compareTo(b.index)))
      if (seen.add('${entry.event.time}|${entry.event.title}')) entry.event,
  ];
}

/// Words that describe a bucket rather than a sport. A candidate name may not
/// start or end with one.
const Set<String> _bucketWords = <String>{
  'all',
  'and',
  'camera',
  'cameras',
  'event',
  'events',
  'feeds',
  'live',
  'of',
  'ppv',
  'the',
  'upcoming',
};

final RegExp _parenthetical = RegExp(r'\([^)]*\)');
final RegExp _separators = RegExp(r'[\s\-:/|,]+');
final RegExp _letter = RegExp(r'[A-Za-z]');

/// Picks the phrase shared by the most events across the group's category
/// names: "NWSL Soccer", "College Soccer" and "All Soccer Events" -> "Soccer";
/// "Ice Hockey (NHL)" and "OHL Ice Hockey" -> "Ice Hockey". Ties go to the
/// longer phrase, then the one seen first. Null when only bucket names
/// ("PPV Events", "Upcoming Events") contributed.
String? _sharedName(Map<String, int> categories) {
  final weightByName = <String, int>{};
  for (final entry in categories.entries) {
    final cleaned = _cleanCategoryName(entry.key);
    if (cleaned.isEmpty) continue;
    weightByName.update(cleaned, (n) => n + entry.value,
        ifAbsent: () => entry.value);
  }

  final scores = <String, ({String phrase, int score, int words})>{};
  for (final entry in weightByName.entries) {
    final words = entry.key
        .split(_separators)
        .where(_letter.hasMatch)
        .toList(growable: false);
    final phrasesInName = <String>{};
    for (var start = 0; start < words.length; start++) {
      for (var length = 1; length <= 3; length++) {
        final end = start + length;
        if (end > words.length) break;
        final phrase = words.sublist(start, end);
        if (_bucketWords.contains(phrase.first.toLowerCase()) ||
            _bucketWords.contains(phrase.last.toLowerCase())) {
          continue;
        }
        final text = phrase.join(' ');
        if (!phrasesInName.add(text.toLowerCase())) continue;
        final current = scores[text.toLowerCase()];
        scores[text.toLowerCase()] = (
          phrase: current?.phrase ?? text,
          score: (current?.score ?? 0) + entry.value,
          words: length,
        );
      }
    }
  }

  ({String phrase, int score, int words})? best;
  for (final candidate in scores.values) {
    if (best == null ||
        candidate.score > best.score ||
        (candidate.score == best.score && candidate.words > best.words)) {
      best = candidate;
    }
  }
  return best?.phrase;
}

/// "Tennis 🎾 ATP - Singles: Chengdu (China)" -> "Tennis";
/// "Big Brother 👁️ 28 LIVE CAMERA FEEDS" -> "Big Brother".
String _cleanCategoryName(String name) {
  final runes = name.runes.toList(growable: false);
  final emojiAt = runes.indexWhere(_isSportMarker);
  var text = emojiAt > 0 ? String.fromCharCodes(runes.take(emojiAt)) : name;
  if (text.trim().isEmpty) {
    text = String.fromCharCodes(runes.where((rune) => !_isEmojiPart(rune)));
  }
  return text.replaceAll(_parenthetical, ' ').split(_separators).where((w) {
    return w.isNotEmpty;
  }).join(' ');
}

// List.sort is not stable, so ties fall back to upstream order. Without a
// start time on every event there is no total order; keep upstream order.
List<DaddyLiveEpgEvent> _byStartTime(List<DaddyLiveEpgEvent> events) {
  if (events.any((event) => event.startsAt == null)) return events;
  final indexed = events.indexed.toList()
    ..sort((a, b) {
      final byTime = a.$2.startsAt!.compareTo(b.$2.startsAt!);
      return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
    });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}

typedef _Marker = ({String key, String display});

const int _variationSelector = 0xFE0F;

bool _isRegionalIndicator(int rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF;

/// Pictographic emoji that can mark a sport. Flags, variation selectors,
/// joiners and skin tones are excluded.
bool _isSportMarker(int rune) =>
    (rune >= 0x1F300 &&
        rune <= 0x1FAFF &&
        !(rune >= 0x1F3FB && rune <= 0x1F3FF)) ||
    (rune >= 0x2600 && rune <= 0x27BF);

bool _isEmojiPart(int rune) =>
    _isSportMarker(rune) ||
    _isRegionalIndicator(rune) ||
    rune == _variationSelector ||
    rune == 0x200D ||
    (rune >= 0x1F3FB && rune <= 0x1F3FF);

_Marker _marker(List<int> runes, int index) {
  final rune = runes[index];
  final hasSelector =
      index + 1 < runes.length && runes[index + 1] == _variationSelector;
  return (
    key: String.fromCharCode(rune),
    display: String.fromCharCodes(
      hasSelector ? <int>[rune, _variationSelector] : <int>[rune],
    ),
  );
}

/// The sport emoji a title opens with, skipping leading flags:
/// "⚽ 🇺🇿 Football ..." and "🏎️🇦🇿 Formula 1 ..." both qualify.
_Marker? _leadingEmoji(String text) {
  final runes = text.runes.toList(growable: false);
  for (var i = 0; i < runes.length; i++) {
    final rune = runes[i];
    if (rune == 0x20 || rune == _variationSelector) continue;
    if (_isRegionalIndicator(rune)) continue;
    return _isSportMarker(rune) ? _marker(runes, i) : null;
  }
  return null;
}

/// The first sport emoji anywhere in a category name ("Motorsport 🏎️🏁").
_Marker? _firstEmoji(String text) {
  final runes = text.runes.toList(growable: false);
  final index = runes.indexWhere(_isSportMarker);
  return index < 0 ? null : _marker(runes, index);
}
