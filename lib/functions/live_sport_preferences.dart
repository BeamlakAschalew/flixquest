import 'live_schedule_sports.dart';

/// A sport a viewer can follow. Schedule sections are named from the
/// upstream schedule's English category names, which vary in spelling
/// ("Am. Football", "Ice-Hockey", "Motorsports", "Formula1"), so a sport
/// recognises its sections by their emoji first and by its names after that.
class LiveSport {
  LiveSport({
    required this.id,
    required this.emoji,
    required this.markers,
    required List<String> names,
    List<String> competitions = const <String>[],
    List<String> excludes = const <String>[],
  })  : _names = _phrasePattern(names),
        _competitions =
            competitions.isEmpty ? null : _phrasePattern(competitions),
        _excludes = excludes.isEmpty ? null : _phrasePattern(excludes);

  /// Stored in preferences; never change one.
  final String id;

  /// Shown on the picker.
  final String emoji;

  /// Section emoji (first code point, no variation selector) that mean this
  /// sport.
  final Set<String> markers;

  /// The sport's own names and abbreviations nothing else uses: "soccer",
  /// "nhl".
  final RegExp _names;

  /// Competition names that usually, not always, mean this sport ("Premier
  /// League" is also darts). Consulted only when no section name matched.
  final RegExp? _competitions;

  /// Phrases that rule a match inside them out: the "football" in "Gaelic
  /// Football" is not soccer.
  final RegExp? _excludes;

  /// The translation key of the sport's name.
  String get labelKey => 'live_sport_$id';
}

/// The sports offered on the picker, in the order shown.
final List<LiveSport> liveSports = <LiveSport>[
  LiveSport(
    id: 'soccer',
    emoji: '⚽',
    markers: <String>{'⚽'},
    names: <String>[
      'soccer',
      'football',
      'futbol',
      'futsal',
      'fifa',
      'uefa',
      'mls',
    ],
    competitions: <String>[
      'premier league',
      'champions league',
      'europa league',
      'conference league',
      'la liga',
      'bundesliga',
      'serie a',
      'ligue 1',
      'eredivisie',
      'copa',
      'nwsl',
      'usl',
      'epl',
      'efl',
    ],
    excludes: <String>[
      'american football',
      'am football',
      'amer football',
      'college football',
      'high school football',
      'canadian football',
      'arena football',
      'flag football',
      'gaelic football',
      'australian football',
      'aussie rules football',
      'australian rules football',
    ],
  ),
  LiveSport(
    id: 'basketball',
    emoji: '🏀',
    markers: <String>{'🏀'},
    names: <String>[
      'basketball',
      'nba',
      'wnba',
      'ncaab',
      'euroleague',
      'eurocup',
    ],
  ),
  LiveSport(
    id: 'tennis',
    emoji: '🎾',
    markers: <String>{'🎾'},
    names: <String>['tennis', 'atp', 'wta', 'itf', 'davis cup'],
    excludes: <String>['table tennis', 'padel tennis', 'paddle tennis'],
  ),
  LiveSport(
    id: 'cricket',
    emoji: '🏏',
    markers: <String>{'🏏'},
    names: <String>['cricket', 'ipl', 't20', 't20i', 'odi'],
  ),
  LiveSport(
    id: 'american_football',
    emoji: '🏈',
    markers: <String>{'🏈'},
    names: <String>[
      'american football',
      'am football',
      'amer football',
      'college football',
      'high school football',
      'canadian football',
      'arena football',
      'flag football',
      'gridiron',
      'super bowl',
      'nfl',
      'ncaaf',
      'cfl',
      'xfl',
      'ufl',
    ],
  ),
  LiveSport(
    id: 'combat',
    emoji: '🥊',
    markers: <String>{'🥊', '🥋', '👊', '🤼'},
    names: <String>[
      'boxing',
      'kick boxing',
      'mma',
      'ufc',
      'bellator',
      'pfl',
      'bkfc',
      'muay thai',
      'fight night',
      'fighting',
      'wrestling',
      'wwe',
      'aew',
    ],
    excludes: <String>['fighting irish'],
  ),
  LiveSport(
    id: 'motorsport',
    emoji: '🏎️',
    markers: <String>{'🏎', '🏍', '🏁'},
    names: <String>[
      'motorsport',
      'motor sport',
      'motor racing',
      'auto racing',
      'formula',
      'formula 1',
      'formula 2',
      'formula 3',
      'formula e',
      'formula one',
      'f1',
      'f2',
      'f3',
      'nascar',
      'indycar',
      'moto gp',
      'moto 2',
      'moto 3',
      'superbike',
      'wsbk',
      'supercars',
      'motocross',
      'supercross',
      'rally',
      'wrc',
      'wec',
      'dtm',
    ],
  ),
  LiveSport(
    id: 'ice_hockey',
    emoji: '🏒',
    markers: <String>{'🏒'},
    names: <String>[
      'hockey',
      'ice hockey',
      'nhl',
      'echl',
      'khl',
      'ahl',
      'ohl',
      'whl',
      'qmjhl',
      'shl',
    ],
    excludes: <String>[
      'field hockey',
      'roller hockey',
      'inline hockey',
      'street hockey',
      'floor hockey',
      'air hockey',
    ],
  ),
  LiveSport(
    id: 'baseball',
    emoji: '⚾',
    markers: <String>{'⚾'},
    names: <String>['baseball', 'mlb', 'kbo', 'npb'],
  ),
  LiveSport(
    id: 'rugby',
    emoji: '🏉',
    markers: <String>{'🏉'},
    names: <String>['rugby', 'nrl', 'six nations'],
  ),
  LiveSport(
    id: 'golf',
    emoji: '⛳',
    markers: <String>{'⛳', '🏌'},
    names: <String>[
      'golf',
      'pga',
      'lpga',
      'dp world tour',
      'ryder cup',
      'solheim cup',
    ],
    excludes: <String>['mini golf', 'disc golf', 'frisbee golf', 'crazy golf'],
  ),
  LiveSport(
    id: 'cycling',
    emoji: '🚴',
    markers: <String>{'🚴', '🚵', '🚲'},
    names: <String>[
      'cycling',
      'uci',
      'tour de france',
      'giro d italia',
      'vuelta',
    ],
  ),
  LiveSport(
    id: 'darts',
    emoji: '🎯',
    markers: <String>{'🎯'},
    names: <String>['darts', 'pdc', 'bdo'],
  ),
  LiveSport(
    id: 'snooker',
    emoji: '🎱',
    markers: <String>{'🎱'},
    names: <String>[
      'snooker',
      'billiard',
      'billiards',
      '8 ball',
      '9 ball',
      'eight ball',
      'nine ball',
    ],
  ),
  LiveSport(
    id: 'volleyball',
    emoji: '🏐',
    markers: <String>{'🏐'},
    names: <String>['volleyball', 'vnl'],
  ),
  LiveSport(
    id: 'handball',
    emoji: '🤾',
    markers: <String>{'🤾'},
    names: <String>['handball', 'ehf'],
  ),
  LiveSport(
    id: 'horse_racing',
    emoji: '🏇',
    markers: <String>{'🏇', '🐎'},
    names: <String>[
      'horse racing',
      'horse race',
      'harness racing',
      'thoroughbred',
    ],
  ),
];

final Expando<Object> _sportCache = Expando<Object>();
const Object _noSport = Object();

/// The sport a schedule section shows, or null when none on the picker does.
/// The section's emoji decides when it names a sport; otherwise its name.
/// Cached per section, since the schedule asks on every build.
LiveSport? liveSportOf(LiveSportSection section) {
  final cached = _sportCache[section];
  if (cached != null) return cached is LiveSport ? cached : null;
  final sport = _classify(section);
  _sportCache[section] = sport ?? _noSport;
  return sport;
}

LiveSport? _classify(LiveSportSection section) {
  final marker = _markerOf(section.emoji);
  if (marker != null) {
    for (final sport in liveSports) {
      if (sport.markers.contains(marker)) return sport;
    }
  }
  final text = normalizeSportText(section.name);
  if (text.isEmpty) return null;
  return _bestMatch(text, (sport) => sport._names) ??
      _bestMatch(text, (sport) => sport._competitions);
}

/// The sport whose [pattern] matches [text] at the longest stretch (so
/// "American Football" beats the "football" of soccer), then the earliest,
/// then the first on [liveSports]. Matches inside an excluded phrase do not
/// count.
LiveSport? _bestMatch(String text, RegExp? Function(LiveSport) pattern) {
  LiveSport? best;
  var bestLength = 0;
  var bestStart = 0;
  for (final sport in liveSports) {
    final regex = pattern(sport);
    if (regex == null) continue;
    final excluded =
        sport._excludes?.allMatches(text).toList(growable: false) ??
            const <RegExpMatch>[];
    for (final match in regex.allMatches(text)) {
      if (excluded.any((e) => e.start <= match.start && match.end <= e.end)) {
        continue;
      }
      final length = match.end - match.start;
      if (length > bestLength ||
          (length == bestLength && match.start < bestStart)) {
        best = sport;
        bestLength = length;
        bestStart = match.start;
      }
    }
  }
  return best;
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

const Map<String, String> _accents = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
  'ý': 'y', 'ÿ': 'y',
};

final RegExp _accented = RegExp('[${_accents.keys.join()}]');
final RegExp _nonWord = RegExp(r'[^a-z0-9]+');

/// A category name as the patterns read it: lower case, accents folded,
/// and every run of punctuation, emoji or spacing one space.
/// "Am. Football (NFL)" -> "am football nfl"; "Ice-Hockey" -> "ice hockey".
String normalizeSportText(String text) => text
    .toLowerCase()
    .replaceAllMapped(_accented, (m) => _accents[m[0]]!)
    .replaceAll(_nonWord, ' ')
    .trim();

/// Where letters meet digits inside a word: "t|20", "formula|1".
final RegExp _letterDigit = RegExp(r'(?<=[a-z])(?=[0-9])|(?<=[0-9])(?=[a-z])');

/// One pattern for a list of phrases over [normalizeSportText] output. A
/// phrase matches whole words only ("pool" is not in "liverpool"), with or
/// without the spaces between its words or between letters and digits
/// ("icehockey", "formula1", "t 20"), and with a plural ending
/// ("motorsports", "horse races"). Longer phrases are tried first so a match
/// takes as much as it can.
RegExp _phrasePattern(List<String> phrases) {
  final alternatives = (phrases.toList()
        ..sort((a, b) => b.length.compareTo(a.length)))
      .map((phrase) => normalizeSportText(phrase)
          .split(' ')
          .map(
              (word) => word.split(_letterDigit).map(RegExp.escape).join(r' ?'))
          .join(r' ?'))
      .join('|');
  return RegExp('(?<![a-z0-9])(?:$alternatives)(?:e?s)?(?![a-z0-9])');
}

/// The first code point of a section's emoji, which is what
/// [LiveSport.markers] holds: "🏎️" (with its variation selector) -> "🏎".
String? _markerOf(String emoji) {
  final runes = emoji.runes.where((rune) => rune != 0xFE0F);
  return runes.isEmpty ? null : String.fromCharCode(runes.first);
}
