import 'package:cinemax/constants/app_constants.dart';
import 'package:cinemax/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> getData(String dataType) async {
    if (await webScraper!.loadWebPage('/title/${widget.imdbId}/$dataType/')) {
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
  }

  void getDataWithRetry() async {
    getData(widget.dataType);
    await Future.delayed(const Duration(seconds: 15));
    checkLoad();
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
          color: isDark ? Colors.black : Colors.white,
          child: dataDetail == null
              ? const Center(child: CircularProgressIndicator())
              : requestFailed == true
                  ? dataRetryWidget()
                  : dataDetail!.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'There are no ${widget.dataName} available for this movie :(',
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

                              //  color:
                              //   !isDark
                              //       ? index.isEven
                              //           ? Colors.grey.shade500
                              //           : Colors.grey.shade100
                              //       : Colors.grey.shade800 ,
                              // color: !isDark ? index.isEven
                              //     ,
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
