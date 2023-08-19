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

const String currentAppVersion = '2.1.1-bv3';

final client = HttpClient();
const retryOptions = RetryOptions(
    maxDelay: Duration(milliseconds: 300),
    delayFactor: Duration(seconds: 0),
    maxAttempts: 100000);
const timeOut = Duration(seconds: 10);

final List<String> appNames = [
  'cinemax-v1.4.1.apk',
  'cinemax-v1.4.2.apk',
  'cinemax-v1.4.0.apk',
  'cinemax-v1.3.0.apk',
  'cinemax-1.3.0-build-v4.apk',
  'cinemax-v1.3.0-build-v3.apk',
  'cinemax-v1.3.0-build-v3.apk',
  'cinemax-v2.0.0.apk',
  'cinemax-v2.0.0-build-v2.apk',
  'cinemax-v2.0.0-build-v3.apk',
  'cinemax-v2.1.0.apk',
  'cinemax-v2.1.1.apk',
  'cinemax-v2.1.1-bv2.apk',
  'cinemax-v2.1.1-bv3.apk',
];

CacheManager cacheProp() {
  return CacheManager(
      Config('cacheKey', stalePeriod: const Duration(days: 10)));
}
