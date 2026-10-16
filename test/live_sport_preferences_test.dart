import 'dart:convert';
import 'dart:io';

import 'package:flixquest/controllers/live_tv_database_controller.dart';
import 'package:flixquest/functions/live_schedule_sports.dart';
import 'package:flixquest/functions/live_sport_preferences.dart';
import 'package:flixquest/models/live_tv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

LiveSportSection _section(String name, [String emoji = '']) =>
    LiveSportSection(name: name, emoji: emoji, events: const []);

String? _sportOf(String name, [String emoji = '']) =>
    liveSportOf(_section(name, emoji))?.id;

void main() {
  test('sports are recognised by the section emoji first', () {
    expect(_sportOf('Soccer', '⚽'), 'soccer');
    expect(_sportOf('Motorsport', '🏎️'), 'motorsport');
    expect(_sportOf('MMA', '🥋'), 'combat');
    expect(_sportOf('Boxing', '🥊'), 'combat');
    expect(_sportOf('Ice Hockey', '🏒'), 'ice_hockey');
    // The emoji outranks a misleading name.
    expect(_sportOf('Football', '🏈'), 'american_football');
  });

  test('sections without a known emoji fall back to whole words', () {
    expect(_sportOf('Am. Football'), 'american_football');
    expect(_sportOf('NFL Preseason'), 'american_football');
    expect(_sportOf('College Football'), 'american_football');
    expect(_sportOf('Football'), 'soccer');
    expect(_sportOf('College Soccer'), 'soccer');
    expect(_sportOf('Table Tennis'), isNull);
    expect(_sportOf('Field Hockey'), isNull);
    expect(_sportOf('Aussie Rules Football'), isNull);
    expect(_sportOf('ATP Tour'), 'tennis');
    // Words, not substrings: "Liverpool" is not pool.
    expect(_sportOf('Liverpool TV'), isNull);
    expect(_sportOf('Big Brother'), isNull);
  });

  test('preferred sports lead and every other section follows in order', () {
    final sections = <LiveSportSection>[
      _section('Soccer', '⚽'),
      _section('Tennis', '🎾'),
      _section('Big Brother'),
      _section('Basketball', '🏀'),
      _section('Cricket', '🏏'),
    ];
    final names = prioritizeSportSections(
      sections,
      <String>{'cricket', 'tennis'},
    ).map((section) => section.name);
    expect(names, <String>[
      'Tennis',
      'Cricket',
      'Soccer',
      'Big Brother',
      'Basketball',
    ]);
  });

  test('no preference, or none on the day, keeps the schedule as it is', () {
    final sections = <LiveSportSection>[
      _section('Soccer', '⚽'),
      _section('Tennis', '🎾'),
    ];
    expect(prioritizeSportSections(sections, const <String>{}), same(sections));
    expect(
      prioritizeSportSections(sections, <String>{'golf'}),
      same(sections),
    );
  });

  test('works on sections grouped from a real schedule day', () {
    final day =
        DaddyLiveEpgDay(label: 'Sat', categories: <DaddyLiveEpgCategory>[
      DaddyLiveEpgCategory(
          name: 'All Soccer Events ⚽',
          events: <DaddyLiveEpgEvent>[
            DaddyLiveEpgEvent(
                time: '12:00', title: '⚽ A vs B', channels: const <Channel>[]),
          ]),
      DaddyLiveEpgCategory(
          name: 'Motorsport 🏎️🏁',
          events: <DaddyLiveEpgEvent>[
            DaddyLiveEpgEvent(
                time: '13:00',
                title: '🏎️ Formula 1 Grand Prix',
                channels: const <Channel>[]),
          ]),
    ]);
    final grouped = groupScheduleBySport(day);
    final ordered = prioritizeSportSections(grouped, <String>{'motorsport'});
    expect(ordered.map((section) => section.label),
        <String>['🏎️ Motorsport', '⚽ Soccer']);
    // The cached grouping is left untouched.
    expect(groupScheduleBySport(day).map((section) => section.name),
        <String>['Soccer', 'Motorsport']);
  });

  test('sport ids are unique and every name is translated', () {
    final ids = liveSports.map((sport) => sport.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    for (final file in Directory('assets/translations')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))) {
      final catalog =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final sport in liveSports) {
        expect(catalog[sport.labelKey], isA<String>(),
            reason: '${file.path} is missing ${sport.labelKey}');
      }
    }
  });

  group('stored preference', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('is null until asked, then survives a cache clear', () async {
      final database = LiveTVDatabaseController();
      expect(await database.getPreferredSports(), isNull);

      await database.setPreferredSports(const <String>{});
      expect(await database.getPreferredSports(), isEmpty);

      await database.setPreferredSports(<String>{'soccer', 'tennis'});
      await database.clearCache();
      expect(await database.getPreferredSports(), <String>{'soccer', 'tennis'});
    });
  });
}
