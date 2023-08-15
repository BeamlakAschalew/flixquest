import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/recently_watched.dart';

class RecentlyWatchedMoviesController {
  static RecentlyWatchedMoviesController? _recentlyWatchedMoviesController;
  Database? _database;
  String tableName = 'recently_watched_movies_table';
  String colId = 'id';
  String colTitle = 'title';
  String colReleaseYear = 'release_year';
  String elapsedCol = 'elapsed';
  String remainingCol = 'remaining';
  String dateTimeCol = 'date_watched';
  String posterPathCol = 'poster_path';

  RecentlyWatchedMoviesController._createInstance();

  factory RecentlyWatchedMoviesController() {
    _recentlyWatchedMoviesController ??=
        RecentlyWatchedMoviesController._createInstance();
    return _recentlyWatchedMoviesController!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}recent_movies.db';
    var recentMoviesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return recentMoviesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colTitle TEXT, $posterPathCol TEXT, $colReleaseYear INTEGER, $elapsedCol NUMERIC, $remainingCol NUMERIC, $dateTimeCol TEXT)');
  }

  Future<List<Map<String, dynamic>>> getMovieMapList() async {
    Database db = await database;
    var result = await db.query(tableName, orderBy: '$dateTimeCol DESC');
    return result;
  }

  Future<int> insertMovie(RecentMovie rMovie) async {
    Database db = await database;
    var result = await db.insert(tableName, rMovie.toMap());
    return result;
  }

  Future<int> updateMovie(RecentMovie rMovie, int id) async {
    var db = await database;
    var result =
        await db.update(tableName, rMovie.toMap(), where: '$colId = $id');
    return result;
  }

  Future<int> deleteMovie(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<RecentMovie>> getRecentMovieList() async {
    var movieMapList = await getMovieMapList();
    int count = movieMapList.length;
    List<RecentMovie> movieList = <RecentMovie>[];

    for (int i = 0; i < count; i++) {
      movieList.add(RecentMovie.fromMapObject(movieMapList[i]));
    }
    return movieList;
  }

  Future<bool> contain(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db
        .rawQuery('SELECT COUNT (*) from $tableName WHERE $colId = $id');
    int result = Sqflite.firstIntValue(x)!;
    if (result == 0) return false;
    return true;
  }
}

class RecentlyWatchedTVShows {}
