import 'dart:async';
import 'dart:io';

import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';
import 'package:web_scraper/web_scraper.dart';

class DidYouKnowScreen extends StatefulWidget {
  const DidYouKnowScreen(
      {Key? key,
      required this.dataType,
      required this.dataName,
      required this.imdbId})
      : super(key: key);
  final String dataType;
  final String dataName;
  final String imdbId;

  @override
  State<DidYouKnowScreen> createState() => _DidYouKnowScreenState();
}

class _DidYouKnowScreenState extends State<DidYouKnowScreen> {
  final WebScraper? webScraper = WebScraper('https://imdb.com');
  List<Map<String, dynamic>>? dataDetail;
  List<Map<String, dynamic>>? likedNumberOfData;

  bool isLoading = false;
  bool requestFailed = false;

  final client = HttpClient();
  final retryOptions = const RetryOptions(
      maxDelay: Duration(milliseconds: 300),
      delayFactor: Duration(seconds: 0),
      maxAttempts: 1000);
  final timeOut = const Duration(seconds: 10);

  Future<void> getData(String dataType) async {
    try {
      if (await retryOptions.retry(
        () => webScraper!.loadWebPage('/title/${widget.imdbId}/$dataType/'),
        retryIf: (e) =>
            e is SocketException ||
            e is TimeoutException ||
            e is WebScraperException,
      )) {
        setState(() {
          dataDetail = webScraper!.getElement(
              dataType == 'alternateversions' ||
                      dataType == 'movieconnections' ||
                      dataType == 'soundtrack'
                  ? 'div.soda'
                  : 'div.sodatext',
              ['class']);
          likedNumberOfData = webScraper!.getElement(
              'div.did-you-know-actions > a.interesting-count-text', ['href']);
        });
      }
    } finally {
      client.close();
    }
  }

  void getDataWithRetry() async {
    getData(widget.dataType);
    // await Future.delayed(const Duration(seconds: 15));
    // checkLoad();
  }

  void checkLoad() {
    if (dataDetail == null) {
      setState(() {
        requestFailed = true;
        dataDetail = [];
        likedNumberOfData = [];
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
          title: Text(widget.dataName),
        ),
        body: Container(
          child: dataDetail == null
              ? const Center(child: CircularProgressIndicator())
              : requestFailed == true
                  ? dataRetryWidget()
                  : dataDetail!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'There are no ${widget.dataName} available for this title :(',
                              textAlign: TextAlign.center,
                              style: kTextHeaderStyle,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: dataDetail!.length,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      dataDetail![index]['title'],
                                      textAlign: TextAlign.start,
                                    ),
                                  )
                                ],
                              ),
                            );
                          })),
        ));
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
                  dataDetail = null;
                  likedNumberOfData = null;
                });
                getDataWithRetry();
              },
              child: const Text('Retry')),
        ],
      ),
    );
  }
}
