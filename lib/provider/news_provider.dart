// import 'package:flutter/material.dart';
// import 'package:web_scraper/web_scraper.dart';

// class NewsProvider with ChangeNotifier {
//   final webScraper = WebScraper('https://imdb.com');
//   late List<Map<String, dynamic>> productNames;
//   late List<Map<String, dynamic>> productDescriptions;

//   // Future<void> initMixpanel() async {
//   //   mixpanel = await Mixpanel.init(mixpanelKey,
//   //       optOutTrackingDefault: false, trackAutomaticEvents: true);
//   //   notifyListeners();
//   // }

//   Future<void> getNews() async {
//     if (await webScraper.loadWebPage('/news/celebrity')) {
//       productNames = webScraper.getElement(
//           'h2.news-article__title > a.tracked-offsite-link', ['href']);
//       productDescriptions =
//           webScraper.getElement('img.news-article__image', ['src']);
//       print(productNames);
//       // print(productDescriptions);
//       notifyListeners();
//     }
//   }
// }
