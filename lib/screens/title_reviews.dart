import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> getData() async {
    if (await webScraper!.loadWebPage(
        '/title/${widget.imdbId}/reviews?sort=totalVotes&dir=desc&ratingFilter=0')) {
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
  }

  void getDataWithRetry() async {
    getData();
    await Future.delayed(const Duration(seconds: 15));
    checkLoad();
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
          Image.asset('assets/images/network-signal.png',
              width: 60, height: 60),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Please connect to the Internet and try again',
                textAlign: TextAlign.center),
          ),
          TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0x0DF57C00)),
                  maximumSize: MaterialStateProperty.all(const Size(200, 60)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: const BorderSide(color: Color(0xFFF57C00))))),
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
