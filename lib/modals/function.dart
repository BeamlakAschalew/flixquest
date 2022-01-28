import 'dart:convert';
import 'package:cinemax/modals/images.dart';
import 'package:cinemax/modals/videos.dart';
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

Future<MovieImages> fetchImages(String api) async {
  MovieImages movieImages;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieImages = MovieImages.fromJson(decodeRes);
  return movieImages;
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

Future<List<Genres>> fetchNewCredits(String api) async {
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
