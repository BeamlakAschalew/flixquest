import 'package:flutter/material.dart';

import '../controllers/bookmark_database_controller.dart';
import '../models/movie.dart';
import '../models/tv.dart';
import '../services/bookmark_sync_service.dart';

class BookmarkProvider extends ChangeNotifier {
  BookmarkProvider() {
    BookmarkSyncService.instance.statusNotifier
        .addListener(_onSyncStatusChanged);
  }

  final MovieDatabaseController _movieDb = MovieDatabaseController();
  final TVDatabaseController _tvDb = TVDatabaseController();

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  List<TV> _tvShows = [];
  List<TV> get tvShows => _tvShows;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _onSyncStatusChanged() {
    final status = BookmarkSyncService.instance.statusNotifier.value;
    if (status == SyncStatus.success) {
      fetchBookmarks();
    }
  }

  Future<void> fetchBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _movies = await _movieDb.getMovieList();
      _tvShows = await _tvDb.getTVList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie(Movie movie) async {
    await _movieDb.insertMovie(movie);
    await fetchBookmarks();
    BookmarkSyncService.instance.onBookmarkChanged();
  }

  Future<void> removeMovie(int id) async {
    await _movieDb.deleteMovie(id);
    await fetchBookmarks();
    await BookmarkSyncService.instance.deleteMovieFromCloud(id);
    BookmarkSyncService.instance.onBookmarkChanged();
  }

  Future<void> addTV(TV tv) async {
    await _tvDb.insertTV(tv);
    await fetchBookmarks();
    BookmarkSyncService.instance.onBookmarkChanged();
  }

  Future<void> removeTV(int id) async {
    await _tvDb.deleteTV(id);
    await fetchBookmarks();
    await BookmarkSyncService.instance.deleteTVFromCloud(id);
    BookmarkSyncService.instance.onBookmarkChanged();
  }

  bool isMovieBookmarked(int id) {
    return _movies.any((m) => m.id == id);
  }

  bool isTVBookmarked(int id) {
    return _tvShows.any((t) => t.id == id);
  }

  @override
  void dispose() {
    BookmarkSyncService.instance.statusNotifier
        .removeListener(_onSyncStatusChanged);
    super.dispose();
  }
}
