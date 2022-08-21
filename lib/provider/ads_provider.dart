import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

class ADSProvider with ChangeNotifier {
  var startAppSdk = StartAppSdk();
  var startAppSdk1 = StartAppSdk();
  var startAppSdk2 = StartAppSdk();
  var startAppSdk3 = StartAppSdk();
  var startAppSdk4 = StartAppSdk();
  var startAppSdk5 = StartAppSdk();
  var startAppSdk6 = StartAppSdk();
  StartAppBannerAd? bannerAd0;
  StartAppBannerAd? bannerAd1;
  StartAppBannerAd? bannerAd2;
  StartAppBannerAd? bannerAd3;
  StartAppBannerAd? bannerAd4;
  StartAppBannerAd? bannerAd5;
  StartAppBannerAd? bannerAd6;

  void getBannerAD() {
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
      bannerAd1 = bannerAd;
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

    startAppSdk3
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd3 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk4
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd4 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk5
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd5 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdk6
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      bannerAd6 = bannerAd;
      notifyListeners();
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }
}
