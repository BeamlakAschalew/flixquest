import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web_scraper/web_scraper.dart';
import '../constants/app_constants.dart';
import '../provider/settings_provider.dart';
import '../widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'news_webview.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          title: const Text(
            'News',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.grey,
              width: double.infinity,
              child: TabBar(
                isScrollable: true,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                tabs: [
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(FontAwesomeIcons.fire),
                      ),
                      Text(
                        'Top news',
                      ),
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.movie_creation_rounded),
                      ),
                      Text(
                        'Movie news',
                      ),
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.live_tv_rounded)),
                      Text(
                        'TV news',
                      ),
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(FontAwesomeIcons.user)),
                      Text(
                        'Celebrity news',
                      ),
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(FontAwesomeIcons.starOfLife)),
                      Text(
                        'Indie news',
                      ),
                    ],
                  )),
                ],
                indicatorColor: isDark ? Colors.white : Colors.black,
                indicatorWeight: 3,
                //isScrollable: true,
                labelStyle: const TextStyle(
                  fontFamily: 'PoppinsSB',
                  color: Colors.black,
                  fontSize: 17,
                ),
                unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.black87),
                labelColor: Colors.black,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                // controller: tabController,
                children: const [
                  NewsView(newsType: '/news/top'),
                  NewsView(
                    newsType: '/news/movie',
                  ),
                  NewsView(newsType: '/news/tv'),
                  NewsView(
                    newsType: '/news/celebrity',
                  ),
                  NewsView(newsType: '/news/indie')
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewsView extends StatefulWidget {
  const NewsView({
    Key? key,
    required this.newsType,
  }) : super(key: key);
  final String newsType;

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView>
    with AutomaticKeepAliveClientMixin {
  final WebScraper? webScraper = WebScraper('https://imdb.com');
  List<Map<String, dynamic>>? articleNames;
  List<Map<String, dynamic>>? atricleImage;
  List<Map<String, dynamic>>? articleWebsite;

  final scrollController = ScrollController();
  @override
  void initState() {
    getNews();
    super.initState();
  }

  bool isLoading = false;

  Future<void> getNews() async {
    try {
      await retryOptions.retry(
        () => webScraper!.loadWebPage(widget.newsType),
        retryIf: (e) =>
            e is SocketException ||
            e is TimeoutException ||
            e is WebScraperException,
      );
      {
        setState(() {
          articleNames = webScraper!.getElement(
              'h2.news-article__title > a.tracked-offsite-link', ['href']);
          atricleImage =
              webScraper!.getElement('img.news-article__image', ['src']);
          articleWebsite = webScraper!.getElement(
              'ul.news-article__header-detail > li.ipl-inline-list__item > a.tracked-offsite-link',
              ['class']);
        });
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return articleNames == null
        ? newsShimmer(isDark, scrollController, isLoading)
        : Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    itemBuilder: ((context, index) {
                      Map<String, dynamic> attributes =
                          atricleImage![index]['attributes'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return NewsWebView(
                                atricleUrl: articleNames![index]['attributes']
                                    ['href']);
                          }));
                          // launch(
                          //   articleNames![index]['attributes'][
                          //       'href'], /* mode: LaunchMode.inAppWebView,*/
                          // );
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: SizedBox(
                                      height: 150,
                                      width: 100,
                                      child: attributes['src'] == null
                                          ? Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: attributes['src'],
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    // fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              // placeholder: (context, url) =>
                                              //     scrollingImageShimmer(isDark),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    )),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            articleNames![index]['title'],
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                /* fontSize: 18*/
                                                fontSize: 15),
                                          ),
                                          Text(articleWebsite![index]['title']),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color:
                                    !isDark ? Colors.black54 : Colors.white54,
                                thickness: 1,
                                endIndent: 20,
                                indent: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    itemCount: atricleImage!.length,
                  ),
                ),
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
