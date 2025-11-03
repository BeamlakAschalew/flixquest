import 'package:flixquest/models/live_tv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LiveTVDatabaseController {
  static Database? _database;
  static const String tableName = 'live_tv_channels';
  static const String cacheMetaTable = 'cache_metadata';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'live_tv_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        stream_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        stream_icon TEXT,
        direct_source TEXT NOT NULL,
        video_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cacheMetaTable (
        id INTEGER PRIMARY KEY,
        last_updated INTEGER NOT NULL,
        channel_count INTEGER NOT NULL
      )
    ''');
  }

  // Cache channels to database
  Future<void> cacheChannels(List<Channel> channels) async {
    final db = await database;

    // Clear existing data
    await db.delete(tableName);
    await db.delete(cacheMetaTable);

    // Insert channels in batches for better performance
    Batch batch = db.batch();
    for (final channel in channels) {
      batch.insert(
        tableName,
        channel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    // Update metadata
    await db.insert(cacheMetaTable, {
      'id': 1,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
      'channel_count': channels.length,
    });
  }

  // Get all cached channels
  Future<List<Channel>> getCachedChannels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Channel.fromMap(maps[i]);
    });
  }

  // Search channels by name (efficient database query)
  Future<List<Channel>> searchChannels(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Channel.fromMap(maps[i]);
    });
  }

  // Get cache metadata
  Future<Map<String, dynamic>?> getCacheMetadata() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      cacheMetaTable,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  // Check if cache exists and is valid
  Future<bool> isCacheValid({int maxAgeHours = 24}) async {
    final metadata = await getCacheMetadata();
    if (metadata == null) return false;

    final lastUpdated = metadata['last_updated'] as int;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
    final maxAge =
        maxAgeHours * 60 * 60 * 1000; // Convert hours to milliseconds

    return cacheAge < maxAge;
  }

  // Clear all cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(tableName);
    await db.delete(cacheMetaTable);
  }

  // Get channel count
  Future<int> getChannelCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
