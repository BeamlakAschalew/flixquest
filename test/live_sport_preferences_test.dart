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

  group('section names without a known emoji', () {
    // Spellings the upstream schedule's English categories come in, and the
    // traps around them. null: not a sport on the picker.
    const cases = <String, String?>{
      // Case, punctuation, spacing and plurals.
      'SOCCER': 'soccer',
      'soccer': 'soccer',
      'Am. Football': 'american_football',
      'Am.Football': 'american_football',
      'Amer. Football': 'american_football',
      'AmericanFootball': 'american_football',
      'American-Football': 'american_football',
      'Ice-Hockey': 'ice_hockey',
      'IceHockey': 'ice_hockey',
      'Motorsports': 'motorsport',
      'Motor Sport': 'motorsport',
      'Formula1': 'motorsport',
      'Formula 1': 'motorsport',
      'F1 Grand Prix': 'motorsport',
      'MotoGP': 'motorsport',
      'Moto GP': 'motorsport',
      'NASCAR Cup Series': 'motorsport',
      'Horse Racing': 'horse_racing',
      'Horse Races': 'horse_racing',
      'HorseRacing': 'horse_racing',
      'Darts': 'darts',
      'PDC Darts': 'darts',
      'Snooker': 'snooker',
      '9-Ball': 'snooker',
      'Kick Boxing': 'combat',
      'Kickboxing': 'combat',
      'UFC Fight Night': 'combat',
      'WWE': 'combat',
      'Rugby Union': 'rugby',
      'Rugby League': 'rugby',
      'NRL': 'rugby',
      'Beach Volleyball': 'volleyball',
      'Cycling': 'cycling',
      "Giro d'Italia": 'cycling',
      'Golf': 'golf',
      'PGA Tour': 'golf',
      'Handball': 'handball',
      'Baseball': 'baseball',
      'MLB': 'baseball',
      'Basketball': 'basketball',
      'NBA': 'basketball',
      'Cricket': 'cricket',
      'T20 Blast': 'cricket',
      'T-20': 'cricket',
      'ATP Tour': 'tennis',
      'WTA': 'tennis',
      'Tennis': 'tennis',
      'NHL': 'ice_hockey',
      'OHL': 'ice_hockey',
      'Fútbol': 'soccer',
      'Futsal': 'soccer',
      // "Football" alone is soccer; the American game says so.
      'Football': 'soccer',
      'College Football': 'american_football',
      'Canadian Football (CFL)': 'american_football',
      'NFL Preseason': 'american_football',
      'College Soccer': 'soccer',
      // Competitions count only when no sport is named.
      'Premier League': 'soccer',
      'UEFA Champions League': 'soccer',
      'Premier League Darts': 'darts',
      'Champions League T20': 'cricket',
      'Volleyball Serie A': 'volleyball',
      'Copa del Rey Basketball': 'basketball',
      // Look-alikes that are not the sport.
      'Table Tennis': null,
      'Padel Tennis': null,
      'Field Hockey': null,
      'Roller Hockey': null,
      'Gaelic Football': null,
      'Aussie Rules Football': null,
      'Australian Football': null,
      'Disc Golf': null,
      'Notre Dame Fighting Irish': null,
      // Whole words only.
      'Liverpool TV': null,
      'Pool': null,
      'Atpase': null,
      'Bigolf': null,
      'Draft': null,
      // Not sports at all.
      'Big Brother': null,
      'PPV Events': null,
      'TV Shows': null,
      'Athletics': null,
      '': null,
      '🏆': null,
    };
    for (final entry in cases.entries) {
      test('"${entry.key}" -> ${entry.value}', () {
        expect(_sportOf(entry.key), entry.value);
      });
    }
  });

  group('category names from the live EPG, without their emoji', () {
    // Every category /api/v2/dlhd/epg served on 2026-10-16, emoji removed,
    // so the names alone are known to file correctly.
    const cases = <String, String?>{
      'AHL Ice Hockey': 'ice_hockey',
      'All Soccer Events': 'soccer',
      'Am. Football (CFL)': 'american_football',
      'Am. Football (NCAAF)': 'american_football',
      'Aussie rules (AFL)': null,
      'Badminton': null,
      'Baseball (MLB)': 'baseball',
      'Baseball': 'baseball',
      'Basketball': 'basketball',
      'Boxing': 'combat',
      'Cricket': 'cricket',
      'Curling': null,
      'Cycling': 'cycling',
      'Darts': 'darts',
      'ECHL Ice Hockey': 'ice_hockey',
      'Euroleague Basketball': 'basketball',
      'Field Hockey': null,
      'Futsal': 'soccer',
      'Golf': 'golf',
      'Handball': 'handball',
      'High School Football': 'american_football',
      'Horse Racing': 'horse_racing',
      'Ice Hockey': 'ice_hockey',
      'KHL Ice Hockey': 'ice_hockey',
      'MMA': 'combat',
      "Men's College Basketball": 'basketball',
      "Men's College Hockey": 'ice_hockey',
      "Men's College Soccer": 'soccer',
      'Motorsport': 'motorsport',
      'NBA': 'basketball',
      'NHL Ice Hockey': 'ice_hockey',
      'NWSL Soccer': 'soccer',
      'OHL Ice Hockey': 'ice_hockey',
      'PPV Events': null,
      'QMJHL Ice Hockey': 'ice_hockey',
      'Rugby League': 'rugby',
      'Rugby Union': 'rugby',
      'Sailing / Boating': null,
      'Ski Jumping': null,
      'Snooker': 'snooker',
      'Socca Champions League': 'soccer',
      'Soccer': 'soccer',
      'Squash': null,
      'Padel': null,
      'Pickleball': null,
      'Aussie Rules': null,
      'Hurling': null,
      'TV Shows': null,
      'Tennis': 'tennis',
      'Tennis ATP - Doubles: Shanghai (China)': 'tennis',
      'Tennis Challenger Women - Singles: Mallorca (Spain)': 'tennis',
      'Tennis Nottingham, Great Britain': 'tennis',
      'Tennis WTA - Singles: Wuhan (China)': 'tennis',
      'USL Super League': 'soccer',
      'Upcoming Events': null,
      'Volleyball': 'volleyball',
      'WHL Ice Hockey': 'ice_hockey',
      'Water Sports': null,
      "Women's College Hockey": 'ice_hockey',
      "Women's College Soccer": 'soccer',
      "Women's College Volleyball": 'volleyball',
      'Wrestling (SmackDown)': 'combat',
    };
    for (final entry in cases.entries) {
      test('"${entry.key}" -> ${entry.value}', () {
        expect(_sportOf(entry.key), entry.value);
      });
    }
  });

  test('emoji with or without a variation selector are the same marker', () {
    expect(_sportOf('Racing', '🏎'), 'motorsport');
    expect(_sportOf('Racing', '🏎️'), 'motorsport');
    expect(_sportOf('Horse Racing', '🐎'), 'horse_racing');
    // An emoji that names no sport leaves it to the name.
    expect(_sportOf('Golf', '🏆'), 'golf');
    expect(_sportOf('Big Brother', '👁️'), isNull);
  });

  test('raw upstream categories file under the right sport once grouped', () {
    DaddyLiveEpgCategory category(String name, String title) =>
        DaddyLiveEpgCategory(name: name, events: <DaddyLiveEpgEvent>[
          DaddyLiveEpgEvent(
              time: '12:00', title: title, channels: const <Channel>[]),
        ]);
    final day =
        DaddyLiveEpgDay(label: 'Sat', categories: <DaddyLiveEpgCategory>[
      category('All Soccer Events ⚽', '⚽ 🇪🇸 La Liga : A vs B'),
      category('Am. Football', 'NFL : Bears vs Packers'),
      category('Ice Hockey (NHL) 🏒', '🏒 🇺🇸 NHL : C vs D'),
      category('MMA 🥊👊', '🥋 🇧🇷 UFC Fight Night Prelims'),
      category('Motorsport 🏎️🏁', '🏎️🇦🇿 Formula 1 Grand Prix Baku – Race'),
      category('Tennis 🎾 ATP - Singles: Chengdu (China)', '🎾 ATP : E vs F'),
      category('Table Tennis', 'WTT Champions'),
      category('Horse Racing', 'Ascot'),
      category('Big Brother 👁️ 28 LIVE CAMERA FEEDS', 'Live feed'),
      category('PPV Events', 'Main card'),
    ]);
    expect(
      <String, String?>{
        for (final section in groupScheduleBySport(day))
          section.name: liveSportOf(section)?.id,
      },
      <String, String?>{
        'Soccer': 'soccer',
        'Am. Football': 'american_football',
        'Ice Hockey': 'ice_hockey',
        'MMA': 'combat',
        'Motorsport': 'motorsport',
        'Tennis': 'tennis',
        'Table Tennis': null,
        'Horse Racing': 'horse_racing',
        'Big Brother': null,
        'PPV Events': null,
      },
    );
  });

  test('normalizeSportText folds case, accents and punctuation', () {
    expect(normalizeSportText('  Am. Football (NFL) '), 'am football nfl');
    expect(normalizeSportText('Fútbol—Copa Améric@'), 'futbol copa americ');
    expect(normalizeSportText('⚽ 🇪🇸 La Liga'), 'la liga');
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
