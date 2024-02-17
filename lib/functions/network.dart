import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flixquest/models/custom_exceptions.dart';
import 'package:flixquest/video_providers/common.dart';
import 'package:flixquest/video_providers/flixhq.dart';
import 'package:retry/retry.dart';

import '../models/external_subtitles.dart';
import '../constants/app_constants.dart';
import '../video_providers/dramacool.dart';
import '../video_providers/flixquest_api_source.dart';
import '../video_providers/zoro.dart';
import '/models/update.dart';
import '/models/images.dart';
import '/models/person.dart';
import '/models/tv.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import 'package:http/http.dart' as http;
import '/models/credits.dart';
import '/models/genres.dart';
import '/models/movie.dart';
import '../models/live_tv.dart';

Future<List<Movie>> fetchMovies(String api) async {
  MovieList movieList;
  
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieList = MovieList.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return movieList.movies ?? [];
}

Future<List<Movie>> fetchCollectionMovies(String api) async {
  CollectionMovieList collectionMovieList;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    collectionMovieList = CollectionMovieList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return collectionMovieList.movies ?? [];
}

Future fetchCollectionDetails(String api) async {
  CollectionDetails collectionDetails;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    collectionDetails = CollectionDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return collectionDetails;
}

Future<List<Movie>> fetchPersonMovies(String api) async {
  PersonMoviesList personMoviesList;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personMoviesList = PersonMoviesList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personMoviesList.movies ?? [];
}

Future<Images> fetchImages(String api) async {
  Images images;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    images = Images.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return images;
}

Future<PersonImages> fetchPersonImages(String api) async {
  PersonImages personImages;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personImages = PersonImages.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personImages;
}

Future<Videos> fetchVideos(String api) async {
  Videos videos;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    videos = Videos.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return videos;
}

Future<Credits> fetchCredits(String api) async {
  Credits credits;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    credits = Credits.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return credits;
}

Future<List<Person>> fetchPerson(String api) async {
  PersonList credits;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    credits = PersonList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return credits.person ?? [];
}

Future<List<Genres>> fetchGenre(String api) async {
  GenreList newGenreList;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    newGenreList = GenreList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return newGenreList.genre ?? [];
}

Future<ExternalLinks> fetchSocialLinks(String api) async {
  ExternalLinks externalLinks;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    externalLinks = ExternalLinks.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return externalLinks;
}

Future fetchBelongsToCollection(String api) async {
  BelongsToCollection belongsToCollection;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    belongsToCollection = BelongsToCollection.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return belongsToCollection;
}

Future<MovieDetails> fetchMovieDetails(String api) async {
  MovieDetails movieDetails;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movieDetails = MovieDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
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
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personDetails = PersonDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personDetails;
}

Future<WatchProviders> fetchWatchProviders(String api, String country) async {
  WatchProviders watchProviders;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    watchProviders = WatchProviders.fromJson(decodeRes, country);
  } finally {
    client.close();
  }
  return watchProviders;
}

Future<List<TV>> fetchTV(String api) async {
  TVList tvList;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tvList = TVList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tvList.tvSeries ?? [];
}

Future<TVDetails> fetchTVDetails(String api) async {
  TVDetails tvDetails;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tvDetails = TVDetails.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tvDetails;
}

Future<List<TV>> fetchPersonTV(String api) async {
  PersonTVList personTVList;
  try {
    var res = await retryOptions.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    personTVList = PersonTVList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return personTVList.tv ?? [];
}

Future checkForUpdate(String api) async {
  UpdateChecker updateChecker;
  try {
    var res = await const RetryOptions(
            maxDelay: Duration(milliseconds: 300),
            delayFactor: Duration(seconds: 0),
            maxAttempts: 3)
        .retry(
      (() => http.get(Uri.parse(api)).timeout(timeOut)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    updateChecker = UpdateChecker.fromJson(decodeRes);
    client.close();
  } catch (e) {
    rethrow;
  }
  return updateChecker;
}

Future<Movie> getMovie(String api) async {
  Movie movie;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    movie = Movie.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return movie;
}

Future<TV> getTV(String api) async {
  TV tv;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    tv = TV.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return tv;
}

Future<List<FlixHQMovieSearchEntry>> fetchMoviesForStreamFlixHQ(
    String api) async {
  FlixHQMovieSearch movieStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieStream = FlixHQMovieSearch.fromJson(decodeRes);

    if (movieStream.results == null || movieStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return movieStream.results ?? [];
}

Future<List<FlixHQMovieInfoEntries>> getMovieStreamEpisodesFlixHQ(
    String api) async {
  FlixHQMovieInfo movieInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    movieInfo = FlixHQMovieInfo.fromJson(decodeRes);

    if (movieInfo.episodes == null || movieInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return movieInfo.episodes ?? [];
}

Future<FlixHQStreamSources> getMovieStreamLinksAndSubsFlixHQ(String api) async {
  FlixHQStreamSources movieVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    movieVideoSources = FlixHQStreamSources.fromJson(decodeRes);

    if (movieVideoSources.videoLinks == null ||
        movieVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return movieVideoSources;
}

Future<List<FlixHQTVSearchEntry>> fetchTVForStreamFlixHQ(String api) async {
  FlixHQTVSearch tvStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvStream = FlixHQTVSearch.fromJson(decodeRes);

    if (tvStream.results == null || tvStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvStream.results ?? [];
}

Future<FlixHQTVInfo> getTVStreamEpisodesFlixHQ(String api) async {
  FlixHQTVInfo tvInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    tvInfo = FlixHQTVInfo.fromJson(decodeRes);

    if (tvInfo.episodes == null || tvInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return tvInfo;
}

Future<FlixHQStreamSources> getTVStreamLinksAndSubsFlixHQ(String api) async {
  FlixHQStreamSources tvVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    tvVideoSources = FlixHQStreamSources.fromJson(decodeRes);

    if (tvVideoSources.videoLinks == null ||
        tvVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return tvVideoSources;
}

Future<String> getVttFileAsString(String url) async {
  try {
    var response = await retryOptions.retry(
      () => http.get(Uri.parse(url)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final decoded = utf8.decode(bytes);
      if (decoded.startsWith('<')) {
        return '';
      } else {
        return decoded;
      }
    } else {
      return "";
    }
  } catch (e) {
    rethrow;
  }
}

Future<List<Channel>> fetchChannels(String api) async {
  ChannelsList channelsList;
  try {
    var res = await retryOptions.retry(
      () => http.get(Uri.parse(api)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    channelsList = ChannelsList.fromJson(decodeRes);
  } finally {
    client.close();
  }
  return channelsList.channels ?? [];
}

/// Stream TMDB route

Future<FlixHQMovieInfoTMDBRoute> getMovieStreamEpisodesTMDB(String api) async {
  FlixHQMovieInfoTMDBRoute movieInfo;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('error')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    movieInfo = FlixHQMovieInfoTMDBRoute.fromJson(decodeRes);
  } catch (e) {
    rethrow;
  }

  return movieInfo;
}

Future<FlixHQTVInfoTMDBRoute> getTVStreamEpisodesTMDB(String api) async {
  FlixHQTVInfoTMDBRoute tvInfo;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      decodeRes = jsonDecode(res.body);

      if (decodeRes.containsKey('error')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    tvInfo = FlixHQTVInfoTMDBRoute.fromJson(decodeRes);

    if (tvInfo.seasons == null || tvInfo.seasons!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return tvInfo;
}

Future<List<SubtitleData>> getExternalSubtitle(String api, String key) async {
  ExternalSubtitle subData;

  try {
    var res = await retryOptions.retry(
      () =>
          http.get(Uri.parse(api), headers: {"Api-Key": key}).timeout(timeOut),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    subData = ExternalSubtitle.fromJson(decodeRes);
  } catch (e) {
    rethrow;
  }

  return subData.data ?? [];
}

Future<SubtitleDownload> downloadExternalSubtitle(
    String api, int fileId, String key) async {
  SubtitleDownload sub;
  final Map<String, String> headers = {
    'User-Agent': 'FlixQuest v2.4.0',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Api-Key': key
  };
  var body = '{"file_id":$fileId}';
  try {
    var response = await retryOptions.retry(
      () => http.post(Uri.parse(api), headers: headers, body: body),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(response.body);
    sub = SubtitleDownload.fromJson(decodeRes);
  } finally {
    client.close();
  }

  return sub;
}

Future<List<DCVASearchEntry>> fetchMovieTVForStreamDCVA(String api) async {
  DCVASearch dcvaStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    dcvaStream = DCVASearch.fromJson(decodeRes);

    if (dcvaStream.results == null || dcvaStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return dcvaStream.results ?? [];
}

Future<List<DCVAInfoEntries>> getMovieTVStreamEpisodesDCVA(String api) async {
  DCVAInfo dcvaInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    dcvaInfo = DCVAInfo.fromJson(decodeRes);

    if (dcvaInfo.episodes == null || dcvaInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return dcvaInfo.episodes ?? [];
}

Future<DCVAStreamSources> getMovieTVStreamLinksAndSubsDCVA(String api) async {
  DCVAStreamSources dcvaVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    dcvaVideoSources = DramacoolStreamSources.fromJson(decodeRes);

    if (dcvaVideoSources.videoLinks == null ||
        dcvaVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return dcvaVideoSources;
}

Future<List<ZoroSearchEntry>> fetchMovieTVForStreamZoro(String api) async {
  ZoroSearch zoroStream;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);

    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }

    zoroStream = ZoroSearch.fromJson(decodeRes);
    if (zoroStream.results == null || zoroStream.results!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return zoroStream.results ?? [];
}

Future<List<ZoroInfoEntries>> getMovieTVStreamEpisodesZoro(String api) async {
  ZoroInfo zoroInfo;
  try {
    var res = await retryOptionsStream.retry(
      (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    var decodeRes = jsonDecode(res.body);

    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw ServerDownException();
    }
    zoroInfo = ZoroInfo.fromJson(decodeRes);

    if (zoroInfo.episodes == null || zoroInfo.episodes!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }

  return zoroInfo.episodes ?? [];
}

Future<ZoroStreamSources> getMovieTVStreamLinksAndSubsZoro(String api) async {
  ZoroStreamSources zoroVideoSources;
  int tries = 3;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    zoroVideoSources = ZoroStreamSources.fromJson(decodeRes);

    if (zoroVideoSources.videoLinks == null ||
        zoroVideoSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return zoroVideoSources;
}

Future<FlixQuestAPIStreamSources> getFlixQuestAPILinks(String api) async {
  FlixQuestAPIStreamSources fqAPIStreamSources;
  int tries = 2;
  dynamic decodeRes;
  try {
    dynamic res;
    while (tries > 0) {
      res = await retryOptionsStream.retry(
        (() => http.get(Uri.parse(api)).timeout(timeOutStream)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      decodeRes = jsonDecode(res.body);
      if (decodeRes.containsKey('message')) {
        --tries;
      } else {
        break;
      }
    }
    if (decodeRes.containsKey('message') || res.statusCode != 200) {
      throw NotFoundException();
    }
    fqAPIStreamSources = FlixQuestAPIStreamSources.fromJson(decodeRes);

    if (fqAPIStreamSources.videoLinks == null ||
        fqAPIStreamSources.videoLinks!.isEmpty) {
      throw NotFoundException();
    }
  } catch (e) {
    rethrow;
  }
  return fqAPIStreamSources;
}
