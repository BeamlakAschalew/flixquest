import '../../api/endpoints.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../functions/network.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../models/tv_media_item.dart';

class TvCatalogController {
  const TvCatalogController();

  Future<List<TvMediaItem>> loadMovies({
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    final movies = await Future.wait([
      fetchMovies(
        Endpoints.discoverMoviesUrl(1, settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
      fetchMovies(
        Endpoints.topRatedUrl(settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
      fetchMovies(
        Endpoints.upcomingMoviesUrl(settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
    ]);
    return _unique(
      movies.expand((items) => items).map(TvMediaItem.fromMovie),
    );
  }

  Future<List<TvMediaItem>> loadSeries({
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    final series = await Future.wait([
      fetchTV(
        Endpoints.discoverTVUrl(1, settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
      fetchTV(
        Endpoints.topRatedTVUrl(settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
      fetchTV(
        Endpoints.onTheAirUrl(settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
    ]);
    return _unique(
      series.expand((items) => items).map(TvMediaItem.fromSeries),
    );
  }

  Future<List<TvMediaItem>> search({
    required String query,
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query.trim());
    final results = await Future.wait<List<TvMediaItem>>([
      fetchMovies(
        Endpoints.movieSearchUrl(
          encodedQuery,
          settings.isAdult,
          settings.appLanguage,
        ),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ).then(
        (items) => items.map(TvMediaItem.fromMovie).toList(growable: false),
      ),
      fetchTV(
        Endpoints.tvSearchUrl(
          encodedQuery,
          settings.isAdult,
          settings.appLanguage,
        ),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ).then(
        (items) => items.map(TvMediaItem.fromSeries).toList(growable: false),
      ),
    ]);
    return _unique(results.expand((items) => items));
  }

  Future<List<TvMediaItem>> loadLibrary() async {
    final results = await Future.wait<List<TvMediaItem>>([
      MovieDatabaseController().getMovieList().then(
            (items) => items.map(TvMediaItem.fromMovie).toList(growable: false),
          ),
      TVDatabaseController().getTVList().then(
            (items) =>
                items.map(TvMediaItem.fromSeries).toList(growable: false),
          ),
    ]);
    return results.expand((items) => items).toList(growable: false);
  }

  List<TvMediaItem> _unique(Iterable<TvMediaItem> items) {
    final found = <String>{};
    return items
        .where((item) => item.id >= 0 && found.add(item.stableId))
        .toList(growable: false);
  }
}
