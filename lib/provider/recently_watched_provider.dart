import 'package:flutter/material.dart';
import '../controllers/recently_watched_database_controller.dart';
import '../models/recently_watched.dart';

class RecentProvider extends ChangeNotifier {
  final RecentlyWatchedMoviesController _movieController =
      RecentlyWatchedMoviesController();
  final RecentlyWatchedEpisodeController _episodeController =
      RecentlyWatchedEpisodeController();

  List<RecentMovie> _movies = [];
  List<RecentMovie> get movies => _movies;

  List<RecentEpisode> _episodes = [];
  List<RecentEpisode> get episodes => _episodes;

  Future<void> fetchMovies() async {
    _movies = await _movieController.getRecentMovieList();
    notifyListeners();
  }

  Future<void> addMovie(RecentMovie movie) async {
    await _movieController.insertMovie(movie);
    await fetchMovies();
  }

  Future<void> updateMovie(RecentMovie movie, int id) async {
    await _movieController.updateMovie(movie, id);
    await fetchMovies();
  }

  Future<void> deleteMovie(int id) async {
    await _movieController.deleteMovie(id);
    await fetchMovies();
  }

  /// Episode

  Future<void> fetchEpisodes() async {
    _episodes = await _episodeController.getEpisodeList();
    notifyListeners();
  }

  Future<void> addEpisode(RecentEpisode episode) async {
    await _episodeController.insertTV(episode);
    await fetchEpisodes();
  }

  Future<void> updateEpisode(
      RecentEpisode episode, int id, int episodeNum, int seasonNum) async {
    await _episodeController.updateTV(episode, id, episodeNum, seasonNum);
    await fetchEpisodes();
  }

  Future<void> deleteEpisode(int id, int episodeNum, int seasonNum) async {
    await _episodeController.deleteTV(id, episodeNum, seasonNum);
    await fetchEpisodes();
  }
}
