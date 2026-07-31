import 'package:shared_preferences/shared_preferences.dart';

/// Persists a small, most-recent-first list of queries for TV remotes.
class TvSearchHistoryController {
  TvSearchHistoryController(this._preferences);

  static const preferenceKey = 'tv_recent_searches';
  static const maxEntries = 8;

  final SharedPreferences _preferences;

  List<String> load() {
    final stored = _preferences.getStringList(preferenceKey);
    if (stored == null) return const <String>[];

    final searches = <String>[];
    for (final value in stored) {
      final normalized = normalize(value);
      if (normalized.isEmpty ||
          searches.any(
            (search) => search.toLowerCase() == normalized.toLowerCase(),
          )) {
        continue;
      }
      searches.add(normalized);
      if (searches.length == maxEntries) break;
    }
    return searches;
  }

  Future<List<String>> remember(String query) async {
    final normalized = normalize(query);
    if (normalized.isEmpty) return load();

    final searches = load()
        .where((search) => search.toLowerCase() != normalized.toLowerCase())
        .toList();
    searches.insert(0, normalized);
    final updated = searches.take(maxEntries).toList(growable: false);
    await _preferences.setStringList(preferenceKey, updated);
    return updated;
  }

  Future<List<String>> remove(String query) async {
    final normalized = normalize(query).toLowerCase();
    final updated = load()
        .where((search) => search.toLowerCase() != normalized)
        .toList(growable: false);
    await _preferences.setStringList(preferenceKey, updated);
    return updated;
  }

  Future<void> clear() => _preferences.remove(preferenceKey);

  static String normalize(String query) =>
      query.trim().replaceAll(RegExp(r'\s+'), ' ');
}
