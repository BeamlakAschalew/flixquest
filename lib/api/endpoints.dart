import '/constants/api_constants.dart';

class Endpoints {
  static String discoverMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity'
        '.desc&include_adult=false&include_video=false&page'
        '=$page';
  }

  static String nowPlayingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/now_playing?api_key='
        '$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String getCreditsUrl(int id) {
    return TMDB_API_BASE_URL + '/movie/$id/credits?api_key=$TMDB_API_KEY';
  }

  static String topRatedUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/top_rated?api_key='
        '$TMDB_API_KEY'
        '&include_adult=false&page=$page'
        '&region=US';
  }

  static String popularMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/popular?api_key='
        '$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String trendingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/trending/movie/week?api_key='
        '$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String upcomingMoviesUrl(int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/upcoming?api_key='
        '$TMDB_API_KEY'
        '&include_adult=false&page=$page';
  }

  static String movieDetailsUrl(int movieId) {
    return '$TMDB_API_BASE_URL/movie/$movieId?api_key=$TMDB_API_KEY&append_to_response=credits,'
        'images';
  }

  static String genresUrl() {
    return '$TMDB_API_BASE_URL/genre/movie/list?api_key=$TMDB_API_KEY&language=en-US';
  }

  static String getMoviesForGenre(int genreId, int page) {
    return '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
        '&language=en-US'
        '&sort_by=popularity.desc'
        '&include_adult=false'
        '&include_video=false'
        '&page=$page'
        '&with_genres=$genreId';
  }

  static String movieReviewsUrl(int movieId, int page) {
    return '$TMDB_API_BASE_URL/movie/$movieId/reviews?api_key=$TMDB_API_KEY'
        '&language=en-US&page=$page';
  }

  static String movieSearchUrl(String query) {
    return "$TMDB_API_BASE_URL/search/movie?query=$query&api_key=$TMDB_API_KEY";
  }

  static String personSearchUrl(String query) {
    return "$TMDB_API_BASE_URL/search/person?query=$query&api_key=$TMDB_API_KEY";
  }

  static getPerson(int personId) {
    return "$TMDB_API_BASE_URL/person/$personId?api_key=$TMDB_API_KEY&append_to_response=movie_credits";
  }

  static watchProvidersMovies(int providerId, int page) {
    return '$TMDB_API_BASE_URL'
        '/discover/movie?api_key='
        '$TMDB_API_KEY'
        '&language=en-US&sort_by=popularity'
        '.desc&include_adult=false&include_video=false&page=$page'
        '&with_watch_providers=$providerId'
        '&watch_region=US';
  }

  static String getImages(int id) {
    return TMDB_API_BASE_URL + '/movie/$id/images?api_key=$TMDB_API_KEY';
  }

  static String getVideos(int id) {
    return TMDB_API_BASE_URL + '/movie/$id/videos?api_key=$TMDB_API_KEY';
  }

  static String getMovieRecommendations(int id, int page) {
    return '$TMDB_API_BASE_URL'
        '/movie/$id/recommendations?api_key=$TMDB_API_KEY&language=en-US&page=$page';
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
}
