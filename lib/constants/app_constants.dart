import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:retry/retry.dart';
import 'dart:io';

const kTextHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 22,
);

const kBoldItemTitleStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 19,
);

const kTextSmallHeaderStyle = TextStyle(
  fontFamily: 'PoppinsSB',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 17,
  overflow: TextOverflow.ellipsis,
);

const kTextVerySmallBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  overflow: TextOverflow.ellipsis,
);

const kTextSmallAboutBodyStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  overflow: TextOverflow.ellipsis,
);

const kTableLeftStyle =
    TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold);

const String currentAppVersion = '2.4.1';

final client = HttpClient();
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 15);

final List<String> appNames = ['flixquest-v2.4.0.apk', 'flixquest-v2.4.1.apk'];

CacheManager cacheProp() {
  return CacheManager(
      Config('cacheKey', stalePeriod: const Duration(days: 10)));
}

enum MediaType { movie, tvShow }

enum StreamRoute { flixHQ, tmDB }

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
