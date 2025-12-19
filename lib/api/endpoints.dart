// ignore_for_file: non_constant_identifier_names

import '/constants/api_constants.dart';

class Endpoints {
  static String discoverMoviesUrl(int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=$l&sort_by=popularity'
        '.desc&include_video=false&page'
        '=$page';
  }

  static String nowPlayingMoviesUrl(int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/now_playing?api_key='
        '$TMDB_API_KEY'
        '&page=$page&language=$l';
  }

  static String getCreditsUrl(int id, String l) {
    return '$TMDB_API_BASE_URL/movie/$id/credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static String topRatedUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/top_rated?api_key='
        '$TMDB_API_KEY'
        '&region=US&language=$l';
  }

  static String popularMoviesUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/popular?api_key='
        '$TMDB_API_KEY'
        '&language=$l';
  }

  static String trendingMoviesUrl(bool includeAdult, String l) {
    return '$TMDB_API_BASE_URL'
        '/trending/movie/week?api_key='
        '$TMDB_API_KEY'
        '&include_adult=$includeAdult&language=$l';
  }

  static String upcomingMoviesUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/upcoming?api_key='
        '$TMDB_API_KEY'
        '&language=$l';
  }

  static String movieDetailsUrl(int movieId, String l) {
    return '$TMDB_API_BASE_URL/movie/$movieId?api_key=$TMDB_API_KEY&language=$l';
  }

  static String movieGenresUrl(String l) {
    return '$TMDB_API_BASE_URL/genre/movie/list?api_key=$TMDB_API_KEY&language=$l';
  }

  static String tvGenresUrl(String l) {
    return '$TMDB_API_BASE_URL/genre/tv/list?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getMoviesForGenre(int genreId, int page, String l) {
    return '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
        '&sort_by=popularity.desc'
        '&include_video=false'
        '&page=$page'
        '&with_genres=$genreId&language=$l';
  }

  static String movieReviewsUrl(int movieId, int page, String l) {
    return '$TMDB_API_BASE_URL/movie/$movieId/reviews?api_key=$TMDB_API_KEY'
        '&language=$l&page=$page';
  }

  static String movieSearchUrl(String query, bool includeAdult, String l) {
    return '$TMDB_API_BASE_URL/search/movie?query=$query&include_adult=$includeAdult&language=$l&api_key=$TMDB_API_KEY';
  }

  static String personSearchUrl(String query, bool includeAdult, String l) {
    return '$TMDB_API_BASE_URL/search/person?query=$query&include_adult=$includeAdult&language=$l&api_key=$TMDB_API_KEY';
  }

  static String tvSearchUrl(String query, bool includeAdult, String l) {
    return '$TMDB_API_BASE_URL/search/tv?query=$query&include_adult=$includeAdult&language=$l&api_key=$TMDB_API_KEY';
  }

  static getPerson(int personId, String l) {
    return '$TMDB_API_BASE_URL/person/$personId?api_key=$TMDB_API_KEY&language=$l&append_to_response=movie_credits';
  }

  static watchProvidersMovies(int providerId, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=$l&sort_by=popularity'
        '.desc&include_video=false&page=$page'
        '&with_watch_providers=$providerId'
        '&watch_region=US';
  }

  static watchProvidersTVShows(int providerId, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/discover/tv?api_key='
        '$TMDB_API_KEY'
        '&language=$l&sort_by=popularity'
        '.desc&include_adult=false&include_video=false&page=$page'
        '&with_watch_providers=$providerId'
        '&watch_region=US';
  }

  static String getImages(int id) {
    return '$TMDB_API_BASE_URL/movie/$id/images?api_key=$TMDB_API_KEY';
  }

  static String getVideos(int id) {
    return '$TMDB_API_BASE_URL/movie/$id/videos?api_key=$TMDB_API_KEY';
  }

  static String getMovieRecommendations(int id, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/recommendations?api_key=$TMDB_API_KEY&language=$l&page=$page';
  }

  static String getExternalLinksForMovie(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/external_ids?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getSimilarMovies(int id, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/similar?api_key=$TMDB_API_KEY&language=$l&page=$page';
  }

  static String getMovieCreditsForPerson(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/movie_credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static getPersonDetails(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/person/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static getPersonImages(int id) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/images?api_key=$TMDB_API_KEY';
  }

  static getMovieWatchProviders(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/watch/providers?api_key=$TMDB_API_KEY&language=$l';
  }

  static discoverTVUrl(int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/discover/tv?api_key=$TMDB_API_KEY&language=$l&sort_by=popularity.desc&page=$page';
  }

  static popularTVUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/popular?api_key=$TMDB_API_KEY&language=$l';
  }

  static trendingTVUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/trending/tv/week?api_key=$TMDB_API_KEY&language=$l';
  }

  static topRatedTVUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/top_rated?api_key=$TMDB_API_KEY&language=$l';
  }

  static airingTodayUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/airing_today?api_key=$TMDB_API_KEY&language=$l';
  }

  static onTheAirUrl(String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/on_the_air?api_key=$TMDB_API_KEY&language=$l';
  }

  static getFullTVCreditsUrl(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/aggregate_credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static getTVCreditsUrl(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static getTVSeasonCreditsUrl(int id, int seasonNumber, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static getFullTVSeasonCreditsUrl(int id, int seasonNumber, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/aggregate_credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static getTVSeasonImagesUrl(int id, int seasonNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/images?api_key=$TMDB_API_KEY';
  }

  static getTVEpisodeImagesUrl(int id, int seasonNumber, int episodeNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/episode/$episodeNumber/images?api_key=$TMDB_API_KEY';
  }

  static getTVEpisodeVideosUrl(int id, int seasonNumber, int episodeNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/episode/$episodeNumber/videos?api_key=$TMDB_API_KEY';
  }

  static getTVSeasonVideosUrl(int id, int seasonNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/videos?api_key=$TMDB_API_KEY';
  }

  static String tvDetailsUrl(int id, String l) {
    return '$TMDB_API_BASE_URL/tv/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getTVImages(int id) {
    return '$TMDB_API_BASE_URL/tv/$id/images?api_key=$TMDB_API_KEY';
  }

  static String getTVVideos(int id) {
    return '$TMDB_API_BASE_URL/tv/$id/videos?api_key=$TMDB_API_KEY';
  }

  static String getTVRecommendations(int id, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/recommendations?api_key=$TMDB_API_KEY&language=$l&page=$page';
  }

  static String getSimilarTV(int id, int page, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/similar?api_key=$TMDB_API_KEY&language=$l&page=$page';
  }

  static String getTVShowsForGenre(int genreId, int page, String l) {
    return '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
        '&language=$l'
        '&sort_by=popularity.desc'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String getTVCreditsForPerson(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/tv_credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getExternalLinksForPerson(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/external_ids?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getExternalLinksForTV(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/external_ids?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getTVSeasons(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getSeasonDetails(int id, int seasonNum, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNum?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getCollectionDetails(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/collection/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getEpisodeCredits(
      int id, int seasonNumber, int episodeNumber, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/episode/$episodeNumber/credits?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getTVWatchProviders(int id, String l) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/watch/providers?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getMovieDetails(int id, String l) {
    return '$TMDB_API_BASE_URL' '/movie/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static String getTVDetails(int id, String l) {
    return '$TMDB_API_BASE_URL' '/tv/$id?api_key=$TMDB_API_KEY&language=$l';
  }

  static String searchMovieTVForStreamFlixHQ(String titleName, String baseUrl) {
    return '$baseUrl' 'movies/flixhq/$titleName';
  }

  static String getMovieTVStreamInfoFlixHQ(
      String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/flixhq/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksFlixHQ(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/flixhq/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server';
  }

  /// Goku provider endpoints
  static String searchMovieTVForStreamGoku(String titleName, String baseUrl) {
    return '$baseUrl' 'movies/goku/$titleName';
  }

  static String getMovieTVStreamInfoGoku(String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/goku/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksGoku(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/goku/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server';
  }

  /// Sflix provider endpoints
  static String searchMovieTVForStreamSflix(String titleName, String baseUrl) {
    return '$baseUrl' 'movies/sflix/$titleName';
  }

  static String getMovieTVStreamInfoSflix(
      String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/sflix/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksSflix(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/sflix/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server';
  }

  /// Himovies provider endpoints
  static String searchMovieTVForStreamHimovies(
      String titleName, String baseUrl) {
    return '$baseUrl' 'movies/himovies/$titleName';
  }

  static String getMovieTVStreamInfoHimovies(
      String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/himovies/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksHimovies(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/himovies/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server';
  }

  /// Movie/TV TMDB route endpoints

  static String getMovieTVStreamInfoTMDB(
      String id, String media, String baseUrl) {
    return '$baseUrl' 'meta/tmdb/info/' '$id' '?type=$media';
  }

  static String getMovieTVStreamLinksTMDB(
      String baseUrl, String episodeId, String mediaId, String server) {
    return '$baseUrl'
        'meta/tmdb/watch/'
        '$episodeId'
        '?id=$mediaId&server=$server';
  }

  static String searchExternalMovieSubtitles(String imdbId, String language) {
    return '$opensubtitlesBaseUrl'
        '/subtitles?imdb_id=$imdbId&languages=$language&ai_translated=exclude';
  }

  static String searchExternalEpisodeSubtitles(
      String imdbId, int episodeNum, int seasonNum, String language) {
    return '$opensubtitlesBaseUrl'
        '/subtitles?imdb_id=$imdbId&languages=$language&ai_translated=exclude&season_number=$seasonNum&episode_number=$episodeNum';
  }

  static String externalSubtitleDownload() {
    return '$opensubtitlesBaseUrl' '/download';
  }

  static String tmaGetMovieSource(String baseUrl, int id) {
    return '$baseUrl' 'v3/movie/sources/' '$id';
  }

  static String tmaGetEpisodeSource(
      String baseUrl, int id, int episodeNum, int seasonNum) {
    return '$baseUrl' 'v3/tv/sources/' '$id/' '$seasonNum/' '$episodeNum';
  }

  static String searchMovieTVForStreamDramacool(
      String titleName, String baseUrl) {
    return '$baseUrl' 'movies/dramacool/$titleName';
  }

  static String getMovieTVStreamInfoDramacool(
      String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/dramacool/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksDramacool(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/dramacool/watch?episodeId=$episodeId&mediaId=$mediaId&server=$server';
  }

  static String searchMovieTVForStreamViewasian(
      String titleName, String baseUrl) {
    return '$baseUrl' 'movies/viewasian/$titleName';
  }

  static String getMovieTVStreamInfoViewasian(
      String titleStreamId, String baseUrl) {
    return '$baseUrl' 'movies/viewasian/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksViewasian(
      String episodeId, String mediaId, String baseUrl, String server) {
    return '$baseUrl'
        'movies/viewasian/watch?episodeId=$episodeId&mediaId=$mediaId';
  }

  static String searchZoroMoviesTV(String baseUrl, String title) {
    return '$baseUrl' 'anime/zoro/$title';
  }

  static String getMovieTVInfoZoro(String baseUrl, String titleStreamId) {
    return '$baseUrl' 'anime/zoro/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinksZoro(
      String baseUrl, String episodeId, String server) {
    return '$baseUrl' 'anime/zoro/watch?episodeId=$episodeId&server=$server';
  }

  static String getMovieEndpointFlixQuestAPI(
      String baseUrl, int tmdbId, String provider, String server) {
    return '$baseUrl' '$provider/watch-movie?tmdbId=$tmdbId&server=$server';
  }

  static String getTVEndpointFlixQuestAPI(String baseUrl, int episode,
      int season, int tmdbId, String provider, String server) {
    return '$baseUrl'
        '$provider/watch-tv?tmdbId=$tmdbId&season=$season&episode=$episode&server=$server';
  }

  static String getIPTVEndpoint(String baseUrl) {
    return 'https://flixquest.beamlak.dev/live/generate_live_playlist.php';
  }

  static String getMovieStreamLinkFlixhqNew(
      String baseUrl, int movieId, String server) {
    return '$baseUrl' '/movie/' '$movieId/' '$server';
  }

  static String getTVStreamLinkFlixhqNew(
      String baseUrl, int tmdbId, int episodeId, int seasonId, String server) {
    return '$baseUrl' '/tv/' '$tmdbId/' '$seasonId/' '$episodeId/' '$server';
  }

  static String getMovieStreamLinkFlixAPI(String baseUrl, int movieId) {
    return '$baseUrl' '/stream-movie?tmdbId=$movieId';
  }

  static String getTVStreamLinkFlixAPI(
      String baseUrl, int tmdbId, int episodeId, int seasonId) {
    return '$baseUrl'
        '/stream-tv?tmdbId=$tmdbId&season=$seasonId&episode=$episodeId';
  }
}
