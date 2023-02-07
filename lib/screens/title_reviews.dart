import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:web_scraper/web_scraper.dart';

import '../constants/app_constants.dart';
import '../provider/settings_provider.dart';

class TitleReviews extends StatefulWidget {
  const TitleReviews({Key? key, required this.imdbId}) : super(key: key);
  final String imdbId;

  @override
  State<TitleReviews> createState() => _TitleReviewsState();
}

class _TitleReviewsState extends State<TitleReviews> {
  final WebScraper? webScraper = WebScraper('https://imdb.com');
  List<Map<String, dynamic>>? reviewDetail;
  List<Map<String, dynamic>>? reviewTitle;
  List<Map<String, dynamic>>? username;
  List<Map<String, dynamic>>? date;
  List<Map<String, dynamic>>? userRating;
  List<Map<String, dynamic>>? totalItems;

  bool isLoading = false;
  bool requestFailed = false;

  final client = HttpClient();
  final retryOptions = const RetryOptions(
      maxDelay: Duration(milliseconds: 300),
      delayFactor: Duration(seconds: 0),
      maxAttempts: 1000);
  final timeOut = const Duration(seconds: 10);

  Future<void> getData() async {
    try {
      if (await retryOptions.retry(
        () => webScraper!.loadWebPage(
            '/title/${widget.imdbId}/reviews?sort=totalVotes&dir=desc&ratingFilter=0'),
        retryIf: (e) =>
            e is SocketException ||
            e is TimeoutException ||
            e is WebScraperException,
      )) {
        setState(() {
          totalItems = webScraper!.getElement('div.lister-item', ['class']);
          userRating = webScraper!
              .getElement('span.rating-other-user-rating > span', ['class']);
          reviewTitle = webScraper!.getElement('a.title', ['href']);
          username =
              webScraper!.getElement('span.display-name-link > a', ['href']);

          date = webScraper!.getElement('span.review-date', ['class']);
          reviewDetail = webScraper!.getElement('div.text', ['class']);
        });
      }
    } finally {
      client.close();
    }
  }

  void getDataWithRetry() async {
    getData();
    // await Future.delayed(const Duration(seconds: 15));
    // checkLoad();
  }

  void checkLoad() {
    if (reviewDetail == null) {
      setState(() {
        requestFailed = true;
        totalItems = [];
        reviewDetail = [];
        reviewTitle = [];
        username = [];
        date = [];
        userRating = [];
      });
    }
  }

  @override
  void initState() {
    getDataWithRetry();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: Container(
        child: reviewDetail == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : requestFailed == true
                ? dataRetryWidget()
                : reviewDetail!.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'There are no reviews available for this title :(',
                            textAlign: TextAlign.center,
                            style: kTextHeaderStyle,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: totalItems!.length,
                        itemBuilder: ((context, index) {
                          return Container(
                            color: !isDark
                                ? index.isEven
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade100
                                : isDark
                                    ? index.isEven
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade800
                                    : Colors.blue,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      // '10/10',
                                      '${userRating![index]['title'].toString().startsWith('/') ? userRating![index]['title'].toString().replaceFirst('/', '') : userRating![index]['title'].toString()}/10',
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  reviewTitle![index]['title'],
                                  style: kBoldItemTitleStyle,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'by ${username![index]['title']}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      date![index]['title'],
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  reviewDetail![index]['title'],
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        })),
      ),
    );
  }

  Widget dataRetryWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/network-signal.svg',
            width: 60,
            height: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Please connect to the Internet and try again',
                textAlign: TextAlign.center),
          ),
          TextButton(
              onPressed: () async {
                setState(() {
                  requestFailed = false;
                  totalItems = null;
                  reviewDetail = null;

                  userRating = null;
                  username = null;
                  date = null;
                  reviewTitle = null;
                });
                getDataWithRetry();
              },
              child: const Text('Retry')),
        ],
      ),
    );
  }
}
