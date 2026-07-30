import '../../api/endpoints.dart';
import '../../functions/network.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../models/tv_media_item.dart';

class TvHomeData {
  const TvHomeData({
    required this.popularMovies,
    required this.trendingMovies,
    required this.popularSeries,
    required this.trendingSeries,
  });

  final List<TvMediaItem> popularMovies;
  final List<TvMediaItem> trendingMovies;
  final List<TvMediaItem> popularSeries;
  final List<TvMediaItem> trendingSeries;

  TvMediaItem? get hero {
    if (trendingMovies.isNotEmpty) return trendingMovies.first;
    if (trendingSeries.isNotEmpty) return trendingSeries.first;
    if (popularMovies.isNotEmpty) return popularMovies.first;
    if (popularSeries.isNotEmpty) return popularSeries.first;
    return null;
  }

  bool get isEmpty =>
      popularMovies.isEmpty &&
      trendingMovies.isEmpty &&
      popularSeries.isEmpty &&
      trendingSeries.isEmpty;
}

class TvHomeController {
  const TvHomeController();

  Future<TvHomeData> load({
    required SettingsProvider settings,
    required AppDependencyProvider dependencies,
  }) async {
    final language = settings.appLanguage;
    final popularMoviesFuture = fetchMovies(
      Endpoints.popularMoviesUrl(language),
      settings.enableProxy,
      dependencies.tmdbProxy,
    );
    final trendingMoviesFuture = fetchMovies(
      Endpoints.trendingMoviesUrl(language),
      settings.enableProxy,
      dependencies.tmdbProxy,
    );
    final popularSeriesFuture = fetchTV(
      Endpoints.popularTVUrl(language),
      settings.enableProxy,
      dependencies.tmdbProxy,
    );
    final trendingSeriesFuture = fetchTV(
      Endpoints.trendingTVUrl(language),
      settings.enableProxy,
      dependencies.tmdbProxy,
    );

    final popularMovies = await popularMoviesFuture;
    final trendingMovies = await trendingMoviesFuture;
    final popularSeries = await popularSeriesFuture;
    final trendingSeries = await trendingSeriesFuture;

    return TvHomeData(
      popularMovies:
          popularMovies.map(TvMediaItem.fromMovie).toList(growable: false),
      trendingMovies:
          trendingMovies.map(TvMediaItem.fromMovie).toList(growable: false),
      popularSeries:
          popularSeries.map(TvMediaItem.fromSeries).toList(growable: false),
      trendingSeries:
          trendingSeries.map(TvMediaItem.fromSeries).toList(growable: false),
    );
  }
}
