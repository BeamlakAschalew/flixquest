import 'dart:convert';
import '/modals/images.dart';
import '/modals/person.dart';
import '/modals/tv.dart';
import '/modals/videos.dart';
import '/modals/watch_providers.dart';
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

Future<List<Movie>> fetchCollectionMovies(String api) async {
  CollectionMovieList collectionMovieList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  collectionMovieList = CollectionMovieList.fromJson(decodeRes);
  return collectionMovieList.movies ?? [];
}

Future fetchCollectionDetails(String api) async {
  CollectionDetails collectionDetails;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  collectionDetails = CollectionDetails.fromJson(decodeRes);
  return collectionDetails;
}

Future<List<Movie>> fetchPersonMovies(String api) async {
  PersonMoviesList personMoviesList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personMoviesList = PersonMoviesList.fromJson(decodeRes);
  return personMoviesList.movies ?? [];
}

Future<Images> fetchImages(String api) async {
  Images images;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  images = Images.fromJson(decodeRes);
  return images;
}

Future<PersonImages> fetchPersonImages(String api) async {
  PersonImages personImages;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personImages = PersonImages.fromJson(decodeRes);
  return personImages;
}

Future<Videos> fetchVideos(String api) async {
  Videos videos;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  videos = Videos.fromJson(decodeRes);
  return videos;
}

Future<Credits> fetchCredits(String api) async {
  Credits credits;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  credits = Credits.fromJson(decodeRes);
  return credits;
}

Future<List<Person>> fetchPerson(String api) async {
  PersonList credits;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  credits = PersonList.fromJson(decodeRes);
  return credits.person ?? [];
}

Future<List<Genres>> fetchGenre(String api) async {
  GenreList newGenreList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  newGenreList = GenreList.fromJson(decodeRes);
  return newGenreList.genre ?? [];
}

Future fetchSocialLinks(String api) async {
  ExternalLinks externalLinks;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  externalLinks = ExternalLinks.fromJson(decodeRes);
  return externalLinks;
}

Future fetchBelongsToCollection(String api) async {
  BelongsToCollection belongsToCollection;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  belongsToCollection = BelongsToCollection.fromJson(decodeRes);
  return belongsToCollection;
}

Future<MovieDetails> fetchMovieDetails(String api) async {
  MovieDetails movieDetails;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  movieDetails = MovieDetails.fromJson(decodeRes);
  return movieDetails;
}

// Future<Credits> fetchPerson(String api) async {
//   Credits credits;
//   var res = await http.get(Uri.parse(api));
//   var decodeRes = jsonDecode(res.body);
//   credits = Credits.fromJson(decodeRes);
//   return credits;
// }

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

Future<List<TV>> fetchTV(String api) async {
  TVList tvList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  tvList = TVList.fromJson(decodeRes);
  return tvList.tvSeries ?? [];
}

Future<TVDetails> fetchTVDetails(String api) async {
  TVDetails tvDetails;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  tvDetails = TVDetails.fromJson(decodeRes);
  return tvDetails;
}

Future<List<TV>> fetchPersonTV(String api) async {
  PersonTVList personTVList;
  var res = await http.get(Uri.parse(api));
  var decodeRes = jsonDecode(res.body);
  personTVList = PersonTVList.fromJson(decodeRes);
  return personTVList.movies ?? [];
}
