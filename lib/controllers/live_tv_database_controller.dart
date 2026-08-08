import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/live_tv.dart';

class LiveTVDatabaseController {
  static const _channelsKey = 'daddylive_channels_v3';
  static const _updatedKey = 'daddylive_channels_updated_v3';
  static const _favoritesKey = 'daddylive_favorites_v2';
  static const _recentKey = 'daddylive_recent_v2';
  static const _epgKey = 'daddylive_epg_v3';
  static const _epgUpdatedKey = 'daddylive_epg_updated_v3';

  Future<void> cacheChannels(List<Channel> channels) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _channelsKey,
      jsonEncode(channels.map((channel) => channel.toJson()).toList()),
    );
    await preferences.setInt(
      _updatedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> cacheEpg(DaddyLiveEpg epg) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_epgKey, jsonEncode(epg.toJson()));
    await preferences.setInt(
      _epgUpdatedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<DaddyLiveEpg?> getCachedEpg() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_epgKey);
    if (value == null) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      return DaddyLiveEpg.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<bool> isEpgCacheValid({int maxAgeHours = 6}) async {
    final preferences = await SharedPreferences.getInstance();
    final updated = preferences.getInt(_epgUpdatedKey);
    if (updated == null) return false;
    return DateTime.now().millisecondsSinceEpoch - updated <
        Duration(hours: maxAgeHours).inMilliseconds;
  }

  Future<List<Channel>> getCachedChannels() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_channelsKey);
    if (value == null) return const <Channel>[];
    try {
      return (jsonDecode(value) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Channel.fromJson)
          .toList(growable: false);
    } on FormatException {
      return const <Channel>[];
    }
  }

  Future<Map<String, dynamic>?> getCacheMetadata() async {
    final preferences = await SharedPreferences.getInstance();
    final updated = preferences.getInt(_updatedKey);
    if (updated == null) return null;
    return <String, dynamic>{'last_updated': updated};
  }

  Future<bool> isCacheValid({int maxAgeHours = 6}) async {
    final metadata = await getCacheMetadata();
    if (metadata == null) return false;
    return DateTime.now().millisecondsSinceEpoch -
            (metadata['last_updated'] as int) <
        Duration(hours: maxAgeHours).inMilliseconds;
  }

  Future<void> clearCache() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_channelsKey);
    await preferences.remove(_updatedKey);
    await preferences.remove(_epgKey);
    await preferences.remove(_epgUpdatedKey);
  }

  Future<Set<String>> getFavoriteIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_favoritesKey) ?? const <String>[])
        .toSet();
  }

  Future<bool> toggleFavorite(String channelId) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites =
        (preferences.getStringList(_favoritesKey) ?? const <String>[]).toSet();
    final isFavorite = favorites.contains(channelId);
    if (isFavorite) {
      favorites.remove(channelId);
    } else {
      favorites.add(channelId);
    }
    await preferences.setStringList(_favoritesKey, favorites.toList());
    return !isFavorite;
  }

  Future<List<String>> getRecentIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_recentKey) ?? const <String>[];
  }

  Future<void> addRecent(String channelId) async {
    final preferences = await SharedPreferences.getInstance();
    final recent =
        (preferences.getStringList(_recentKey) ?? const <String>[]).toList();
    recent
      ..remove(channelId)
      ..insert(0, channelId);
    await preferences.setStringList(_recentKey, recent.take(20).toList());
  }
}
