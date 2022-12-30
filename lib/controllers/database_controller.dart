import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/movie.dart';

class DatabaseController {
  static DatabaseController? _databaseController;
  static Database? _database;
  String movieTable = 'movie_table';
  String colId = 'id';
  String colAdult = 'adult';
  String colBackdropPath = 'backdrop_path';
  String colTitle = 'title';
  String colOriginalLanguage = 'original_language';
  String colOriginalTitle = 'original_title';
  String colOverview = 'overview';
  String colPopularity = 'popularity';
  String colReleaseDate = 'release_date';
  String colVideo = 'video';
  String colVoteAverage = 'vote_average';
  String colVoteCount = 'vote_count';
  String colGenre = 'genre';
  String colPosterPath = 'poster_path';
  DatabaseController._createInstance();

  factory DatabaseController() {
    _databaseController ??= DatabaseController._createInstance();
    return _databaseController!;
  }
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}movies.db';
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $movieTable($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colAdult INTEGER, $colOriginalTitle TEXT, $colOriginalLanguage TEXT, $colOverview TEXT, $colReleaseDate TEXT, $colPopularity TEXT, $colBackdropPath TEXT, $colVideo INTEGER, $colVoteAverage TEXT, $colVoteCount TEXT, $colGenre TEXT, $colPosterPath TEXT,)');
  }

  //this function will return all the movies in the database.
  Future<List<Map<String, dynamic>>> getMovieMapList() async {
    Database db = await database;
    var result = await db.query(movieTable, orderBy: '$colId ASC');
    return result;
  }

  // this method will be used to insert movies in the database.
  Future<int> insertMovie(Movie movie) async {
    Database db = await database;
    var result = await db.insert(movieTable, movie.toMap());
    return result;
  }

  // this method will delete a movie
  Future<int> deleteMovie(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $movieTable WHERE $colId = $id');
    return result;
  }

  // Get number of Movie objects in database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $movieTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Movie List' [ List<Movie> ]
  Future<List<Movie>> getMovieList() async {
    var movieMapList = await getMovieMapList(); // Get 'Map List' from database
    int count =
        movieMapList.length; // Count the number of map entries in db table
    List<Movie> movieList = <Movie>[];
    // For loop to create a 'Movie List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      movieList.add(Movie.fromMapObject(movieMapList[i]));
    }
    return movieList;
  }

  // this function will check if a movies exists in the database.
  Future<bool> contain(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> x = await db
        .rawQuery('SELECT COUNT (*) from $movieTable WHERE $colId = $id');
    int result = Sqflite.firstIntValue(x)!;
    if (result == 0) return false;
    return true;
  }
}
