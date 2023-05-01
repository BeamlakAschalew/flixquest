// ignore_for_file: non_constant_identifier_names

import '/constants/api_constants.dart';

class Endpoints {
  static String discoverMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity'
        '.desc&include_video=false&page'
        '=$page';
  }

  static String nowPlayingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/now_playing?api_key='
        '$TMDB_API_KEY'
        '&page=$page';
  }

  static String getCreditsUrl(int id) {
    return '$TMDB_API_BASE_URL/movie/$id/credits?api_key=$TMDB_API_KEY';
  }

  static String topRatedUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/top_rated?api_key='
        '$TMDB_API_KEY'
        '&page=$page'
        '&region=US';
  }

  static String popularMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/popular?api_key='
        '$TMDB_API_KEY'
        '&page=$page';
  }

  static String trendingMoviesUrl(int page, bool includeAdult) {
    return '$TMDB_API_BASE_URL'
        '/trending/movie/week?api_key='
        '$TMDB_API_KEY'
        '&page=$page'
        '&include_adult=$includeAdult';
  }

  static String upcomingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/upcoming?api_key='
        '$TMDB_API_KEY'
        '&page=$page';
  }

  static String movieDetailsUrl(int movieId) {
    return '$TMDB_API_BASE_URL/movie/$movieId?api_key=$TMDB_API_KEY';
  }

  static String movieGenresUrl() {
    return '$TMDB_API_BASE_URL/genre/movie/list?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String tvGenresUrl() {
    return '$TMDB_API_BASE_URL/genre/tv/list?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getMoviesForGenre(int genreId, int page) {
    return '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
        '&language=en-US'
        '&sort_by=popularity.desc'
        '&include_video=false'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String movieReviewsUrl(int movieId, int page) {
    return '$TMDB_API_BASE_URL/movie/$movieId/reviews?api_key=$TMDB_API_KEY'
        '&language=en-US&page=$page';
  }

  static String movieSearchUrl(String query, bool includeAdult) {
    return "$TMDB_API_BASE_URL/search/movie?query=$query&include_adult=$includeAdult&api_key=$TMDB_API_KEY";
  }

  static String personSearchUrl(String query, bool includeAdult) {
    return "$TMDB_API_BASE_URL/search/person?query=$query&include_adult=$includeAdult&api_key=$TMDB_API_KEY";
  }

  static String tvSearchUrl(String query, bool includeAdult) {
    return "$TMDB_API_BASE_URL/search/tv?query=$query&include_adult=$includeAdult&api_key=$TMDB_API_KEY";
  }

  static getPerson(int personId) {
    return "$TMDB_API_BASE_URL/person/$personId?api_key=$TMDB_API_KEY&append_to_response=movie_credits";
  }

  static watchProvidersMovies(int providerId, int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity'
        '.desc&include_video=false&page=$page'
        '&with_watch_providers=$providerId'
        '&watch_region=US';
  }

  static watchProvidersTVShows(int providerId, int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/tv?api_key='
        '$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity'
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

  static String getMovieRecommendations(int id, int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/recommendations?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static String getExternalLinksForMovie(int id) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/external_ids?api_key=$TMDB_API_KEY';
  }

  static String getSimilarMovies(int id, int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/similar?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static String getMovieCreditsForPerson(int id) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/movie_credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static getPersonDetails(int id) {
    return '$TMDB_API_BASE_URL'
        '/person/$id?api_key=$TMDB_API_KEY&language=en-US';
  }

  static getPersonImages(int id) {
    return '$TMDB_API_BASE_URL' '/person/$id/images?api_key=$TMDB_API_KEY';
  }

  static getMovieWatchProviders(int id) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/watch/providers?api_key=$TMDB_API_KEY';
  }

  static discoverTVUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/tv?api_key=$TMDB_API_KEY&language=en-US&sort_by=popularity.desc&page=$page';
  }

  static popularTVUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/popular?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static trendingTVUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/trending/tv/week?api_key=$TMDB_API_KEY&page=$page';
  }

  static topRatedTVUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/top_rated?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static airingTodayUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/airing_today?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static onTheAirUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/on_the_air?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static getFullTVCreditsUrl(int id) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/aggregate_credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static getTVCreditsUrl(int id) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static getTVSeasonCreditsUrl(int id, int seasonNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static getFullTVSeasonCreditsUrl(int id, int seasonNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/aggregate_credits?api_key=$TMDB_API_KEY&language=en-US';
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

  static String tvDetailsUrl(int id) {
    return '$TMDB_API_BASE_URL/tv/$id?api_key=$TMDB_API_KEY';
  }

  static String getTVImages(int id) {
    return '$TMDB_API_BASE_URL/tv/$id/images?api_key=$TMDB_API_KEY';
  }

  static String getTVVideos(int id) {
    return '$TMDB_API_BASE_URL/tv/$id/videos?api_key=$TMDB_API_KEY';
  }

  static String getTVRecommendations(int id, int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/recommendations?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static String getSimilarTV(int id, int page) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/similar?api_key=$TMDB_API_KEY&language=en-US&page=$page';
  }

  static String getTVShowsForGenre(int genreId, int page) {
    return '$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
        '&language=en-US'
        '&sort_by=popularity.desc'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String getTVCreditsForPerson(int id) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/tv_credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getExternalLinksForPerson(int id) {
    return '$TMDB_API_BASE_URL'
        '/person/$id/external_ids?api_key=$TMDB_API_KEY';
  }

  static String getExternalLinksForTV(int id) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/external_ids?api_key=$TMDB_API_KEY';
  }

  static String getTVSeasons(int id) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getSeasonDetails(int id, int seasonNum) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNum?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getCollectionDetails(int id) {
    return '$TMDB_API_BASE_URL'
        '/collection/$id?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getEpisodeCredits(int id, int seasonNumber, int episodeNumber) {
    return '$TMDB_API_BASE_URL'
        '/tv/$id/season/$seasonNumber/episode/$episodeNumber/credits?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getTVWatchProviders(int id) {
    return '$TMDB_API_BASE_URL' '/tv/$id/watch/providers?api_key=$TMDB_API_KEY';
  }

  static String getMovieDetails(int id) {
    return '$TMDB_API_BASE_URL' '/movie/$id?api_key=$TMDB_API_KEY';
  }

  static String getTVDetails(int id) {
    return '$TMDB_API_BASE_URL' '/tv/$id?api_key=$TMDB_API_KEY';
  }

  static String searchMovieTVForStream(String titleName) {
    return '$CONSUMET_API' 'movies/flixhq/$titleName';
  }

  static String getMovieTVStreamInfo(String titleStreamId) {
    return '$CONSUMET_API' 'movies/flixhq/info?id=$titleStreamId';
  }

  static String getMovieTVStreamLinks(String episodeId, String mediaId) {
    return '$CONSUMET_API'
        'movies/flixhq/watch?episodeId=$episodeId&mediaId=$mediaId&server=upcloud';
  }
}
