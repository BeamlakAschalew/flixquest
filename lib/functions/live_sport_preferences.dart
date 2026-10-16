import 'live_schedule_sports.dart';

/// A sport a viewer can follow. Schedule sections are named from upstream
/// data, so a sport recognises its sections by their emoji first and by
/// words in their name after that.
class LiveSport {
  const LiveSport({
    required this.id,
    required this.emoji,
    required this.markers,
    required this.keywords,
    this.excludes = const <String>[],
  });

  /// Stored in preferences; never change one.
  final String id;

  /// Shown on the picker.
  final String emoji;

  /// Section emoji (without the variation selector) that mean this sport.
  final Set<String> markers;

  /// Whole words or phrases in a section name that mean this sport.
  final List<String> keywords;

  /// Phrases that rule a name out even when a keyword matches ("Table
  /// Tennis" is not tennis).
  final List<String> excludes;

  /// The translation key of the sport's name.
  String get labelKey => 'live_sport_$id';

  bool _matchesName(String words) =>
      keywords.any((keyword) => _hasPhrase(words, keyword)) &&
      !excludes.any((phrase) => _hasPhrase(words, phrase));
}

/// The sports offered on the picker, in the order shown.
const List<LiveSport> liveSports = <LiveSport>[
  LiveSport(
    id: 'soccer',
    emoji: '⚽',
    markers: <String>{'⚽'},
    keywords: <String>['soccer', 'football', 'futsal'],
    excludes: <String>[
      'american football',
      'am football',
      'college football',
      'aussie',
      'australian',
      'gaelic',
    ],
  ),
  LiveSport(
    id: 'basketball',
    emoji: '🏀',
    markers: <String>{'🏀'},
    keywords: <String>['basketball', 'nba', 'wnba', 'ncaab', 'euroleague'],
  ),
  LiveSport(
    id: 'tennis',
    emoji: '🎾',
    markers: <String>{'🎾'},
    keywords: <String>['tennis', 'atp', 'wta'],
    excludes: <String>['table tennis'],
  ),
  LiveSport(
    id: 'cricket',
    emoji: '🏏',
    markers: <String>{'🏏'},
    keywords: <String>['cricket', 'ipl', 't20'],
  ),
  LiveSport(
    id: 'american_football',
    emoji: '🏈',
    markers: <String>{'🏈'},
    keywords: <String>[
      'american football',
      'am football',
      'college football',
      'nfl',
      'ncaaf',
      'cfl',
    ],
  ),
  LiveSport(
    id: 'combat',
    emoji: '🥊',
    markers: <String>{'🥊', '🥋', '👊', '🤼'},
    keywords: <String>[
      'boxing',
      'kickboxing',
      'mma',
      'ufc',
      'wrestling',
      'wwe',
      'aew',
    ],
  ),
  LiveSport(
    id: 'motorsport',
    emoji: '🏎️',
    markers: <String>{'🏎', '🏍', '🏁'},
    keywords: <String>[
      'motorsport',
      'motorsports',
      'formula',
      'f1',
      'nascar',
      'motogp',
      'indycar',
      'rally',
    ],
  ),
  LiveSport(
    id: 'ice_hockey',
    emoji: '🏒',
    markers: <String>{'🏒'},
    keywords: <String>['hockey', 'nhl', 'khl', 'ahl', 'ohl'],
    excludes: <String>['field hockey'],
  ),
  LiveSport(
    id: 'baseball',
    emoji: '⚾',
    markers: <String>{'⚾'},
    keywords: <String>['baseball', 'mlb', 'kbo', 'npb'],
  ),
  LiveSport(
    id: 'rugby',
    emoji: '🏉',
    markers: <String>{'🏉'},
    keywords: <String>['rugby', 'nrl'],
  ),
  LiveSport(
    id: 'golf',
    emoji: '⛳',
    markers: <String>{'⛳', '🏌'},
    keywords: <String>['golf', 'pga', 'lpga'],
  ),
  LiveSport(
    id: 'cycling',
    emoji: '🚴',
    markers: <String>{'🚴', '🚲'},
    keywords: <String>['cycling'],
  ),
  LiveSport(
    id: 'darts',
    emoji: '🎯',
    markers: <String>{'🎯'},
    keywords: <String>['darts'],
  ),
  LiveSport(
    id: 'snooker',
    emoji: '🎱',
    markers: <String>{'🎱'},
    keywords: <String>['snooker', 'billiards', 'pool'],
  ),
  LiveSport(
    id: 'volleyball',
    emoji: '🏐',
    markers: <String>{'🏐'},
    keywords: <String>['volleyball'],
  ),
  LiveSport(
    id: 'handball',
    emoji: '🤾',
    markers: <String>{'🤾'},
    keywords: <String>['handball'],
  ),
  LiveSport(
    id: 'horse_racing',
    emoji: '🏇',
    markers: <String>{'🏇'},
    keywords: <String>['horse racing', 'horse'],
  ),
];

/// The sport a schedule section shows, or null when none on the picker does.
/// The section's emoji decides when it names a sport; otherwise its name.
LiveSport? liveSportOf(LiveSportSection section) {
  final marker = section.emoji.replaceAll('️', '');
  if (marker.isNotEmpty) {
    for (final sport in liveSports) {
      if (sport.markers.contains(marker)) return sport;
    }
  }
  final words = _words(section.name);
  for (final sport in liveSports) {
    if (sport._matchesName(words)) return sport;
  }
  return null;
}

/// [sections] with the ones showing a sport in [preferred] (by id) moved to
/// the top. Both groups keep the order they came in, so the schedule reads
/// as before under the viewer's sports and nothing is hidden.
List<LiveSportSection> prioritizeSportSections(
  List<LiveSportSection> sections,
  Set<String> preferred,
) {
  if (preferred.isEmpty) return sections;
  final first = <LiveSportSection>[];
  final rest = <LiveSportSection>[];
  for (final section in sections) {
    final sport = liveSportOf(section);
    (sport != null && preferred.contains(sport.id) ? first : rest).add(section);
  }
  if (first.isEmpty) return sections;
  return <LiveSportSection>[...first, ...rest];
}

final RegExp _nonWord = RegExp(r'[^a-z0-9]+');

/// "Am. Football (NFL)" -> " am football nfl ", padded so a phrase only
/// matches whole words.
String _words(String text) =>
    ' ${text.toLowerCase().replaceAll(_nonWord, ' ').trim()} ';

bool _hasPhrase(String words, String phrase) => words.contains(' $phrase ');
