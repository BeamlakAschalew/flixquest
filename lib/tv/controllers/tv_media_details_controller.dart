import '../../api/endpoints.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../functions/network.dart';
import '../../models/movie.dart';
import '../../models/tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../models/tv_media_item.dart';

class TvMediaDetailsData {
  const TvMediaDetailsData({
    required this.item,
    required this.recommendations,
    this.movieDetails,
    this.seriesDetails,
  });

  final TvMediaItem item;
  final MovieDetails? movieDetails;
  final TVDetails? seriesDetails;
  final List<TvMediaItem> recommendations;

  String? get tagline => movieDetails?.tagline ?? seriesDetails?.tagline;
  String? get status => movieDetails?.status ?? seriesDetails?.status;

  String get facts {
    final parts = <String>[
      if (item.year != null) item.year!,
      if (item.rating != null) '${item.rating!.toStringAsFixed(1)} / 10',
      if (movieDetails?.runtime case final runtime?) '$runtime min',
      if (seriesDetails?.numberOfSeasons case final seasons?)
        '$seasons season${seasons == 1 ? '' : 's'}',
      if (seriesDetails?.numberOfEpisodes case final episodes?)
        '$episodes episodes',
    ];
    return parts.join('  •  ');
  }
}

class TvMediaDetailsController {
  const TvMediaDetailsController();

  Future<TvMediaDetailsData> load({
    required TvMediaItem item,
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    if (item.kind == TvMediaKind.movie) {
      final results = await Future.wait<Object>([
        fetchMovieDetails(
          Endpoints.movieDetailsUrl(item.id, settings.appLanguage),
          settings.enableProxy,
          dependencies.tmdbProxy,
        ),
        fetchMovies(
          Endpoints.getMovieRecommendations(
            item.id,
            1,
            settings.appLanguage,
          ),
          settings.enableProxy,
          dependencies.tmdbProxy,
        ),
      ]);
      return TvMediaDetailsData(
        item: item,
        movieDetails: results[0] as MovieDetails,
        recommendations: (results[1] as List<Movie>)
            .map(TvMediaItem.fromMovie)
            .toList(growable: false),
      );
    }

    final results = await Future.wait<Object>([
      fetchTVDetails(
        Endpoints.tvDetailsUrl(item.id, settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
      fetchTV(
        Endpoints.getTVRecommendations(item.id, 1, settings.appLanguage),
        settings.enableProxy,
        dependencies.tmdbProxy,
      ),
    ]);
    return TvMediaDetailsData(
      item: item,
      seriesDetails: results[0] as TVDetails,
      recommendations: (results[1] as List<TV>)
          .map(TvMediaItem.fromSeries)
          .toList(growable: false),
    );
  }

  Future<List<EpisodeList>> loadSeason({
    required int seriesId,
    required int seasonNumber,
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    final details = await fetchTVDetails(
      Endpoints.getSeasonDetails(
        seriesId,
        seasonNumber,
        settings.appLanguage,
      ),
      settings.enableProxy,
      dependencies.tmdbProxy,
    );
    return details.episodes ?? const <EpisodeList>[];
  }

  Future<bool> isBookmarked(TvMediaItem item) {
    return item.kind == TvMediaKind.movie
        ? MovieDatabaseController().contain(item.id)
        : TVDatabaseController().contain(item.id);
  }

  Future<bool> toggleBookmark(TvMediaItem item, bool isBookmarked) async {
    if (item.kind == TvMediaKind.movie) {
      final database = MovieDatabaseController();
      if (isBookmarked) {
        await database.deleteMovie(item.id);
        return false;
      }
      final movie = item.movie;
      if (movie == null) return false;
      await database.insertMovie(movie);
      return true;
    }

    final database = TVDatabaseController();
    if (isBookmarked) {
      await database.deleteTV(item.id);
      return false;
    }
    final series = item.series;
    if (series == null) return false;
    await database.insertTV(series);
    return true;
  }
}
