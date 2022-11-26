import 'package:cinemax/provider/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:web_scraper/web_scraper.dart';

import '../provider/darktheme_provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        Container(
          color: const Color(0xFFF57C00),
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
            ],
            indicatorColor: isDark ? Colors.white : Colors.black,
            indicatorWeight: 3,
            //isScrollable: true,
            labelStyle: const TextStyle(
              fontFamily: 'PoppinsSB',
              color: Colors.black,
              fontSize: 17,
            ),
            unselectedLabelStyle:
                const TextStyle(fontFamily: 'Poppins', color: Colors.black87),
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
              NewsView(
                newsType: '/news/movie',
              ),
              NewsView(newsType: '/news/tv'),
              NewsView(
                newsType: '/news/celebrity',
              )
            ],
          ),
        )
      ],
    );
    // return Container(
    //   child: Text('data'),
    // );
  }

  @override
  bool get wantKeepAlive => true;
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
  final webScraper = WebScraper('https://imdb.com');
  List<Map<String, dynamic>>? articleNames;
  List<Map<String, dynamic>>? atricleImage;
  List<Map<String, dynamic>>? articleWebsite;

  @override
  void initState() {
    getMovieNews();
    super.initState();
  }

  Future<void> getMovieNews() async {
    if (await webScraper.loadWebPage(widget.newsType)) {
      setState(() {
        articleNames = webScraper.getElement(
            'h2.news-article__title > a.tracked-offsite-link', ['href']);
        atricleImage =
            webScraper.getElement('img.news-article__image', ['src']);
        articleWebsite = webScraper.getElement(
            'ul.news-article__header-detail > li.ipl-inline-list__item > a.tracked-offsite-link',
            ['class']);
        // print(productDescriptions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getMovieNews();
    return articleNames == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    itemBuilder: ((context, index) {
                      Map<String, dynamic> attributes =
                          atricleImage![index]['attributes'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: SizedBox(
                                    height: 150,
                                    width: 100,
                                    child: Image.network(attributes['src']))),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(articleNames![index]['title']),
                                  Text(articleWebsite![index]['title']),
                                ],
                              ),
                              flex: 2,
                            )
                          ],
                        ),
                      );
                    }),
                    itemCount: articleNames!.length,
                  ),
                ),
              ),
            ],
          );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
