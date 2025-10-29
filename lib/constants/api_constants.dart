// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

const String TMDB_API_BASE_URL = 'https://api.themoviedb.org/3';
const String opensubtitlesBaseUrl = 'https://api.opensubtitles.com/api/v1';
String TMDB_API_KEY = dotenv.env['TMDB_API_KEY']!;
String mixpanelKey = dotenv.env['MIXPANEL_API_KEY']!;
String openSubtitlesKey = dotenv.env['OPENSUBTITLES_API_KEY']!;
const TMDB_BASE_IMAGE_URL = 'https://image.tmdb.org/t/p/';
const String EMBED_BASE_MOVIE_URL =
    'https://www.2embed.to/embed/tmdb/movie?id=';
const String EMBED_BASE_TV_URL = 'https://www.2embed.to/embed/tmdb/tv?id=';
const String YOUTUBE_THUMBNAIL_URL = 'https://i3.ytimg.com/vi/';
const String YOUTUBE_BASE_URL = 'https://youtube.com/watch?v=';
const String FACEBOOK_BASE_URL = 'https://facebook.com/';
const String INSTAGRAM_BASE_URL = 'https://instagram.com/';
const String TWITTER_BASE_URL = 'https://twitter.com/';
const String IMDB_BASE_URL = 'https://imdb.com/title/';
const String TWOEMBED_BASE_URL = 'https://2embed.biz';
const String FLIXQUEST_UPDATE_URL =
    'https://beamlakaschalew.github.io/cinemax/res/update.json';
String CONSUMET_API = dotenv.env['CONSUMET_URL']!;
String CONSUMET_INFO_API = dotenv.env['CONSUMET_URL']!;
String flixquestApiUrl = dotenv.env['FLIXQUEST_API_URL']!;
String flixhqNewUrl = dotenv.env['FLIXHQ_NEW_URL']!;
const String STREAMING_SERVER_FLIXHQ = 'vidcloud';
const String STREAMING_SERVER_NEW_FLIXHQ = 'megacloud';
const String STREAMING_SERVER_DCVA = 'asianload';
const String STREAMING_SERVER_ZORO = 'vidcloud';
