import 'package:flixquest/models/occasional_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OccasionalTheme', () {
    test('uses built-in Christmas palette and effect type', () {
      final theme = OccasionalTheme.fromJson(<String, dynamic>{
        'enabled': true,
        'id': 'christmas',
        'logo_url': 'https://example.com/christmas.png',
        'effect': <String, dynamic>{'enabled': true},
      });

      expect(theme.enabled, isTrue);
      expect(theme.displayName, 'Christmas');
      expect(theme.primaryColor, const Color(0xFFC62828));
      expect(theme.secondaryColor, const Color(0xFF2E7D32));
      expect(theme.effect.type, OccasionalEffectType.snow);
      expect(theme.effect.enabled, isTrue);
    });

    test('uses Ethiopian New Year preset and palette overrides', () {
      final theme = OccasionalTheme.fromJson(<String, dynamic>{
        'enabled': true,
        'id': 'ethiopian_new_year',
        'primary_color': '#123456',
        'dark_background_color': '#FF010203',
      });

      expect(theme.primaryColor, const Color(0xFF123456));
      expect(theme.secondaryColor, const Color(0xFF2E7D32));
      expect(theme.tertiaryColor, const Color(0xFFC62828));
      expect(theme.darkBackgroundColor, const Color(0xFF010203));
      expect(theme.effect.type, OccasionalEffectType.petals);
    });

    test('honors activation windows and rejects invalid windows', () {
      final theme = OccasionalTheme.fromJson(<String, dynamic>{
        'enabled': true,
        'id': 'christmas',
        'starts_at': '2026-12-01T00:00:00Z',
        'ends_at': '2027-01-07T23:59:59Z',
      });

      expect(theme.isActiveAt(DateTime.utc(2026, 11, 30)), isFalse);
      expect(theme.isActiveAt(DateTime.utc(2026, 12, 25)), isTrue);
      expect(theme.isActiveAt(DateTime.utc(2027, 1, 8)), isFalse);
      expect(
        OccasionalTheme.fromJson(<String, dynamic>{
          'enabled': true,
          'id': 'broken',
          'starts_at': 'not-a-date',
        }).enabled,
        isFalse,
      );
      expect(
        OccasionalTheme.fromJson(<String, dynamic>{
          'enabled': true,
          'id': 'reversed',
          'starts_at': '2027-01-01T00:00:00Z',
          'ends_at': '2026-01-01T00:00:00Z',
        }).enabled,
        isFalse,
      );
    });

    test('clamps effect cost and accepts custom colors', () {
      final theme = OccasionalTheme.fromJson(<String, dynamic>{
        'enabled': true,
        'id': 'custom',
        'effect': <String, dynamic>{
          'enabled': true,
          'type': 'sparkles',
          'density': 10000,
          'speed': 20,
          'opacity': -1,
          'colors': <String>['#112233', '#445566'],
        },
      });

      expect(theme.effect.type, OccasionalEffectType.sparkles);
      expect(theme.effect.density, 80);
      expect(theme.effect.speed, 3);
      expect(theme.effect.opacity, .1);
      expect(theme.effect.colors, const <Color>[
        Color(0xFF112233),
        Color(0xFF445566),
      ]);
    });
  });

  group('OccasionalThemeCatalog', () {
    const overlappingCatalog = '''
      {
        "schema_version": 2,
        "enabled": true,
        "allow_user_selection": true,
        "effects_enabled": true,
        "default_theme_id": "",
        "themes": [
          {
            "id": "christmas",
            "enabled": true,
            "priority": 50,
            "starts_at": "2026-12-01T00:00:00Z",
            "ends_at": "2027-01-07T23:59:59Z"
          },
          {
            "id": "new_year",
            "enabled": true,
            "priority": 100,
            "starts_at": "2026-12-28T00:00:00Z",
            "ends_at": "2027-01-03T23:59:59Z"
          }
        ]
      }
    ''';

    test('automatic mode resolves overlaps by highest priority', () {
      final catalog = OccasionalThemeCatalog.fromJsonString(overlappingCatalog);
      final resolved = catalog.resolve(
        selectedThemeId: 'automatic',
        now: DateTime.utc(2026, 12, 31),
      );

      expect(resolved?.id, 'new_year');
    });

    test('an explicit active user selection wins an overlap', () {
      final catalog = OccasionalThemeCatalog.fromJsonString(overlappingCatalog);
      final resolved = catalog.resolve(
        selectedThemeId: 'christmas',
        now: DateTime.utc(2026, 12, 31),
      );

      expect(resolved?.id, 'christmas');
    });

    test('unavailable selection falls back to automatic', () {
      final catalog = OccasionalThemeCatalog.fromJsonString(overlappingCatalog);
      final resolved = catalog.resolve(
        selectedThemeId: 'new_year',
        now: DateTime.utc(2026, 12, 20),
      );

      expect(resolved?.id, 'christmas');
    });

    test('default theme ID wins before priority', () {
      final catalog = OccasionalThemeCatalog.fromJsonString(
        overlappingCatalog.replaceFirst(
          '"default_theme_id": ""',
          '"default_theme_id": "christmas"',
        ),
      );

      expect(
        catalog
            .resolve(
              selectedThemeId: 'automatic',
              now: DateTime.utc(2026, 12, 31),
            )
            ?.id,
        'christmas',
      );
    });

    test('migrates the legacy single-theme JSON', () {
      final catalog = OccasionalThemeCatalog.fromJsonString('''
        {
          "enabled": true,
          "id": "christmas",
          "logo_url": "https://example.com/logo.png"
        }
      ''');

      expect(catalog.schemaVersion, 1);
      expect(catalog.enabled, isTrue);
      expect(catalog.allowUserSelection, isFalse);
      expect(catalog.activeThemes.single.id, 'christmas');
    });

    test('round trips persisted schema and rejects malformed JSON', () {
      final original =
          OccasionalThemeCatalog.fromJsonString(overlappingCatalog);
      final restored = OccasionalThemeCatalog.fromJsonString(
        original.toJsonString(),
      );

      expect(restored.enabled, original.enabled);
      expect(restored.allowUserSelection, original.allowUserSelection);
      expect(restored.themes.map((theme) => theme.id),
          original.themes.map((theme) => theme.id));
      expect(
        OccasionalThemeCatalog.fromJsonString('not-json').enabled,
        isFalse,
      );
    });
  });
}
