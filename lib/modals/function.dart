import 'dart:convert';
import 'package:cinemax/modals/images.dart';
import 'package:cinemax/modals/person.dart';
import 'package:cinemax/modals/videos.dart';
import 'package:cinemax/modals/watch_providers.dart';
import 'package:http/http.dart' as http;
import '/modals/credits.dart';
import '/modals/genres.dart';
import '/modals/movie.dart';

Future<List<Movie>> fetchMovies(String api) async {
  MovieList movieList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieList = MovieList.fromJson(decodeRes);
  return movieList.movies ?? [];
}

Future<List<Movie>> fetchPersonMovies(String api) async {
  PersonMoviesList personMoviesList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personMoviesList = PersonMoviesList.fromJson(decodeRes);
  return personMoviesList.movies ?? [];
}

Future<MovieImages> fetchImages(String api) async {
  MovieImages movieImages;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieImages = MovieImages.fromJson(decodeRes);
  return movieImages;
}

Future<PersonImages> fetchPersonImages(String api) async {
  PersonImages personImages;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personImages = PersonImages.fromJson(decodeRes);
  return personImages;
}

Future<MovieVideos> fetchVideos(String api) async {
  MovieVideos movieVideos;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieVideos = MovieVideos.fromJson(decodeRes);
  return movieVideos;
}

Future<Credits> fetchCredits(String api) async {
  Credits credits;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  credits = Credits.fromJson(decodeRes);
  return credits;
}

Future<List<Genres>> fetchNewGenre(String api) async {
  GenreList newGenreList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  newGenreList = GenreList.fromJson(decodeRes);
  return newGenreList.genre ?? [];
}

Future<MovieDetails> fetchMovieDetails(String api) async {
  MovieDetails movieDetails;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieDetails = MovieDetails.fromJson(decodeRes);
  return movieDetails;
}

Future<List<Movie>> fetchMovieRecommendations(String api) async {
  MovieList movieList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieList = MovieList.fromJson(decodeRes);
  return movieList.movies ?? [];
}

Future<List<Movie>> fetchSimilarMovies(String api) async {
  MovieList movieList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieList = MovieList.fromJson(decodeRes);
  return movieList.movies ?? [];
}

Future<PersonDetails> fetchPersonDetails(String api) async {
  PersonDetails personDetails;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personDetails = PersonDetails.fromJson(decodeRes);
  return personDetails;
}

Future<WatchProviders> fetchWatchProviders(String api) async {
  WatchProviders watchProviders;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  watchProviders = WatchProviders.fromJson(decodeRes);
  return watchProviders;
}
