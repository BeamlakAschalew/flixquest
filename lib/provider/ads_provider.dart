import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

class ADSProvider with ChangeNotifier {
  var startAppSdk = StartAppSdk();
  var startAppSdk1 = StartAppSdk();
  var startAppSdk2 = StartAppSdk();

  var startAppSdk6 = StartAppSdk();
  var startAppSdk7 = StartAppSdk();
  var startAppSdk8 = StartAppSdk();
  var startAppSdk9 = StartAppSdk();
  var startAppSdk10 = StartAppSdk();
  StartAppBannerAd? bannerAd0;
  StartAppBannerAd? bannerAd1;
  StartAppBannerAd? bannerAd2;

  StartAppBannerAd? bannerAd6;
  StartAppBannerAd? bannerAd7;
  StartAppBannerAd? bannerAd8;
  StartAppBannerAd? bannerAd9;
  StartAppBannerAd? bannerAd10;

  void getBannerADForMainMovieDisplay() {
    startAppSdk
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd0 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk1
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk2
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd2 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  void getBannerADforMovieDetail() {
    startAppSdk7
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd7 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk8
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd8 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk9
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd9 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk10
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd10 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }
}
