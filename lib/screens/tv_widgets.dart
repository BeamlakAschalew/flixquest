// ignore_for_file: avoid_unnecessary_containers
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemax/provider/adultmode_provider.dart';
import 'package:cinemax/screens/guest_star_detail.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';
import '../provider/ads_provider.dart';
import '../provider/darktheme_provider.dart';
import '../provider/imagequality_provider.dart';
import '../provider/mixpanel_provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../constants/app_constants.dart';
import '/models/credits.dart';
import '/models/function.dart';
import '/models/genres.dart';
import '/models/images.dart';
import '/models/movie.dart';
import '/models/social_icons_icons.dart';
import '/models/tv.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import '/screens/cast_detail.dart';
import '/screens/createdby_detail.dart';
import '/screens/episode_detail.dart';
import '/screens/seasons_detail.dart';
import '/screens/streaming_services_tvshows.dart';
import '/screens/tv_detail.dart';
import '/screens/genre_tv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'crew_detail.dart';
import 'movie_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class MainTVDisplay extends StatefulWidget {
  const MainTVDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainTVDisplay> createState() => _MainTVDisplayState();
}

class _MainTVDisplayState extends State<MainTVDisplay> {
  var startAppSdk3 = StartAppSdk();
  var startAppSdk4 = StartAppSdk();
  var startAppSdk5 = StartAppSdk();

  StartAppBannerAd? bannerAd3;
  StartAppBannerAd? bannerAd4;
  StartAppBannerAd? bannerAd5;

  @override
  void initState() {
    super.initState();
    getBannerADForTVDisplay();
  }

  void getBannerADForTVDisplay() {
    startAppSdk4
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAd4 = bannerAd;
      });
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
      setState(() {
        bannerAd5 = bannerAd;
      });
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
      setState(() {
        bannerAd5 = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    // var bannerAd6 = Provider.of<ADSProvider>(context).bannerAd6;
    // var bannerAd5 = Provider.of<ADSProvider>(context).bannerAd5;
    // var bannerAd4 = Provider.of<ADSProvider>(context).bannerAd4;
    return Container(
      child: ListView(
        children: [
          DiscoverTV(
              includeAdult: Provider.of<AdultmodeProvider>(context).isAdult),
          bannerAd3 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StartAppBanner(bannerAd3!),
                )
              : Container(),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Popular',
            api: Endpoints.popularTVUrl(1),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Trending this week',
            api: Endpoints.trendingTVUrl(1),
            discoverType: 1,
            isTrending: true,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Top Rated',
            api: Endpoints.topRatedTVUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          bannerAd5 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StartAppBanner(bannerAd5!),
                )
              : Container(),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'Airing today',
            api: Endpoints.airingTodayUrl(1),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
            title: 'On the air',
            api: Endpoints.onTheAirUrl(1),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          TVGenreListGrid(api: Endpoints.tvGenresUrl()),
          const TVShowsFromWatchProviders(),
          bannerAd4 != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: StartAppBanner(bannerAd4!),
                )
              : Container(),
        ],
      ),
    );
  }
}

class DiscoverTV extends StatefulWidget {
  final bool includeAdult;
  const DiscoverTV({required this.includeAdult, Key? key}) : super(key: key);
  @override
  _DiscoverTVState createState() => _DiscoverTVState();
}

class _DiscoverTVState extends State<DiscoverTV>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;
  List<TV>? tvList;
  @override
  void initState() {
    super.initState();
    fetchTV(Endpoints.discoverTVUrl(1) +
            '&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        tvList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Discover',
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: deviceHeight * 0.417,
          child: tvList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: true,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, pageViewIndex) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {
                          mixpanel.track('Most viewed TV pages', properties: {
                            'TV series name': '${tvList![index].originalName}',
                            'TV series id': '${tvList![index].id}',
                            'Is TV series adult?': '${tvList![index].adult}'
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TVDetailPage(
                                      tvSeries: tvList![index],
                                      heroId: '${tvList![index].id}')));
                        },
                        child: Hero(
                          tag: '${tvList![index].id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              fadeOutDuration:
                                  const Duration(milliseconds: 300),
                              fadeOutCurve: Curves.easeOut,
                              fadeInDuration: Duration(milliseconds: 700),
                              fadeInCurve: Curves.easeIn,
                              imageUrl: TMDB_BASE_IMAGE_URL +
                                  imageQuality +
                                  tvList![index].posterPath!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Image.asset(
                                'assets/images/loading.gif',
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/na_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: tvList!.length,
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTV extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;
  final bool? includeAdult;
  const ScrollingTV({
    Key? key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
    required this.includeAdult,
  }) : super(key: key);
  @override
  _ScrollingTVState createState() => _ScrollingTVState();
}

class _ScrollingTVState extends State<ScrollingTV>
    with AutomaticKeepAliveClientMixin {
  late int index;
  List<TV>? tvList;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/tv/${widget.discoverType}?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistMovies);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/tv/week?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}language=en-US&include_adult=false&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistMovies);
          });
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchTV(widget.api + '&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: tvList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tvList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                mixpanel
                                    .track('Most viewed TV pages', properties: {
                                  'TV series name':
                                      '${tvList![index].originalName}',
                                  'TV series id': '${tvList![index].id}'
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TVDetailPage(
                                            tvSeries: tvList![index],
                                            heroId:
                                                '${tvList![index].id}${widget.title}')));
                              },
                              child: SizedBox(
                                width: 105,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${tvList![index].id}${widget.title}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: tvList![index].posterPath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  fadeOutCurve: Curves.easeOut,
                                                  fadeInDuration: Duration(
                                                      milliseconds: 700),
                                                  fadeInCurve: Curves.easeIn,
                                                  imageUrl:
                                                      TMDB_BASE_IMAGE_URL +
                                                          imageQuality +
                                                          tvList![index]
                                                              .posterPath!,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      Image.asset(
                                                    'assets/images/loading.gif',
                                                    fit: BoxFit.cover,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tvList![index].name!,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Visibility(
                        child: const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ),
                        visible: isLoading,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingTVArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  _ScrollingTVArtistsState createState() => _ScrollingTVArtistsState();
}

class _ScrollingTVArtistsState extends State<ScrollingTVArtists>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Cast',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.cast!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            'There are no casts available for this TV show',
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Cast',
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.cast!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.cast![index].name}',
                            'Person id': '${credits!.cast![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                              cast: credits!.cast![index],
                              heroId: '${credits!.cast![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag: '${credits!.cast![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!
                                                  .cast![index].profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_square.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!.cast![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_sqaure.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.cast![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeCasts extends StatefulWidget {
  final String? api;
  const ScrollingTVEpisodeCasts({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  _ScrollingTVEpisodeCastsState createState() =>
      _ScrollingTVEpisodeCastsState();
}

class _ScrollingTVEpisodeCastsState extends State<ScrollingTVEpisodeCasts>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Cast',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.cast!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            'There is no cast list available for this episode',
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Cast',
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.cast!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.cast![index].name}',
                            'Person id': '${credits!.cast![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                              cast: credits!.cast![index],
                              heroId: '${credits!.cast![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag: '${credits!.cast![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!
                                                  .cast![index].profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_square.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!.cast![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_sqaure.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.cast![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeGuestStars extends StatefulWidget {
  final String? api;
  const ScrollingTVEpisodeGuestStars({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  _ScrollingTVEpisodeGuestStarsState createState() =>
      _ScrollingTVEpisodeGuestStarsState();
}

class _ScrollingTVEpisodeGuestStarsState
    extends State<ScrollingTVEpisodeGuestStars>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Guest stars',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.episodeGuestStars!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            'There is no guest star list available for this episode',
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Guest stars',
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.episodeGuestStars!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name':
                                '${credits!.episodeGuestStars![index].name}',
                            'Person id':
                                '${credits!.episodeGuestStars![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return GuestStarDetailPage(
                              cast: credits!.episodeGuestStars![index],
                              heroId:
                                  '${credits!.episodeGuestStars![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag:
                                        '${credits!.episodeGuestStars![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!.episodeGuestStars![index]
                                                  .profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_square.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!
                                                      .episodeGuestStars![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_sqaure.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.episodeGuestStars![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeCrew extends StatefulWidget {
  final String? api;
  const ScrollingTVEpisodeCrew({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  _ScrollingTVEpisodeCrewState createState() => _ScrollingTVEpisodeCrewState();
}

class _ScrollingTVEpisodeCrewState extends State<ScrollingTVEpisodeCrew>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Crew',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.crew!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            'There is no crew list available for this episode',
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Crew',
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.crew!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.crew![index].name}',
                            'Person id': '${credits!.crew![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CrewDetailPage(
                              crew: credits!.crew![index],
                              heroId: '${credits!.crew![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag: '${credits!.crew![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!
                                                  .crew![index].profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_square.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!.crew![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_sqaure.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.crew![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVCreators extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingTVCreators({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  _ScrollingTVCreatorsState createState() => _ScrollingTVCreatorsState();
}

class _ScrollingTVCreatorsState extends State<ScrollingTVCreators>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        tvDetails == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Created by',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : tvDetails!.createdBy!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            'There is/are no creator/s available for this TV show',
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Created by',
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: tvDetails == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tvDetails!.createdBy!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name':
                                '${tvDetails!.createdBy![index].name}',
                            'Person id': '${tvDetails!.createdBy![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CreatedByPersonDetailPage(
                              createdBy: tvDetails!.createdBy![index],
                              heroId: '${tvDetails!.createdBy![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Hero(
                                  tag: '${tvDetails!.createdBy![index].id!}',
                                  child: SizedBox(
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: tvDetails!.createdBy![index]
                                                  .profilePath ==
                                              null
                                          ? Image.asset(
                                              'assets/images/na_square.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  tvDetails!.createdBy![index]
                                                      .profilePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_sqaure.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    tvDetails!.createdBy![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVImagesDisplay extends StatefulWidget {
  final String? api, title;
  const TVImagesDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  _TVImagesDisplayState createState() => _TVImagesDisplayState();
}

class _TVImagesDisplayState extends State<TVImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        tvImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: tvImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvImages!.backdrop!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                            'This tv show doesn\'t have an image provided',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration: Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      tvImages!.backdrop![index].filePath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/loading.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: tvImages!.backdrop!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class TVSeasonImagesDisplay extends StatefulWidget {
  final String? api, title;
  const TVSeasonImagesDisplay({Key? key, this.api, this.title})
      : super(key: key);

  @override
  _TVSeasonImagesDisplayState createState() => _TVSeasonImagesDisplayState();
}

class _TVSeasonImagesDisplayState extends State<TVSeasonImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        tvImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 160,
            child: tvImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvImages!.poster!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                            'This tv season doesn\'t have an image provided',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration: Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      tvImages!.poster![index].posterPath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/loading.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: tvImages!.poster!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class TVEpisodeImagesDisplay extends StatefulWidget {
  final String? api, title;
  const TVEpisodeImagesDisplay({Key? key, this.api, this.title})
      : super(key: key);

  @override
  _TVEpisodeImagesDisplayState createState() => _TVEpisodeImagesDisplayState();
}

class _TVEpisodeImagesDisplayState extends State<TVEpisodeImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        tvImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: tvImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvImages!.still!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'This TV series episode doesn\'t have an image provided',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration: Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      tvImages!.still![index].stillPath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    'assets/images/loading.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: tvImages!.still!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class TVVideosDisplay extends StatefulWidget {
  final String? api, title, api2;
  const TVVideosDisplay({Key? key, this.api, this.title, this.api2})
      : super(key: key);

  @override
  _TVVideosDisplayState createState() => _TVVideosDisplayState();
}

class _TVVideosDisplayState extends State<TVVideosDisplay> {
  Videos? tvVideos;

  @override
  void initState() {
    super.initState();
    fetchVideos(widget.api!).then((value) {
      setState(() {
        tvVideos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    return Column(
      children: [
        tvVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: tvVideos == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvVideos!.result!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'This TV series episode doesn\'t have a video provided',
                              textAlign: TextAlign.center),
                        )),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            disableCenter: true,
                            viewportFraction: 0.8,
                            enlargeCenterPage: false,
                            autoPlay: true,
                          ),
                          itemBuilder:
                              (BuildContext context, int index, pageViewIndex) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  launch(YOUTUBE_BASE_URL +
                                      tvVideos!.result![index].videoLink!);
                                },
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 130,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        YOUTUBE_THUMBNAIL_URL +
                                                            tvVideos!
                                                                .result![index]
                                                                .videoLink! +
                                                            '/hqdefault.jpg',
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        playButtonVisibility,
                                                    child: const SizedBox(
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 90,
                                                      ),
                                                      height: 90,
                                                      width: 90,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tvVideos!.result![index].name!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: tvVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class TVCastTab extends StatefulWidget {
  final String? api;
  const TVCastTab({Key? key, this.api}) : super(key: key);

  @override
  _TVCastTabState createState() => _TVCastTabState();
}

class _TVCastTabState extends State<TVCastTab>
    with AutomaticKeepAliveClientMixin<TVCastTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return credits == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : credits!.cast!.isEmpty
            ? Container(
                child: const Center(
                  child:
                      Text('There is no data available for this TV show cast'),
                ),
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.cast![index].name}',
                            'Person id': '${credits!.cast![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_square.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_sqaure.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'As : '
                                            '${credits!.cast![index].roles![0].character!.isEmpty ? 'N/A' : credits!.cast![index].roles![0].character!}',
                                          ),
                                          Text(
                                            credits!.cast![index].roles![0]
                                                        .episodeCount! ==
                                                    1
                                                ? credits!.cast![index]
                                                        .roles![0].episodeCount!
                                                        .toString() +
                                                    ' episode'
                                                : credits!.cast![index]
                                                        .roles![0].episodeCount!
                                                        .toString() +
                                                    ' episodes',
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
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
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVSeasonsTab extends StatefulWidget {
  final String? api;
  final int? tvId;
  final String? seriesName;
  final bool? adult;
  const TVSeasonsTab(
      {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
      : super(key: key);

  @override
  _TVSeasonsTabState createState() => _TVSeasonsTabState();
}

class _TVSeasonsTabState extends State<TVSeasonsTab>
    with AutomaticKeepAliveClientMixin<TVSeasonsTab> {
  TVDetails? tvDetails;
  var startAppSdkTVSeason = StartAppSdk();
  StartAppBannerAd? bannerAdTVSeason;

  void getBannerADForMovieDetail() {
    startAppSdkTVSeason
        .loadBannerAd(StartAppBannerType.BANNER)
        .then((bannerAd) {
      setState(() {
        bannerAdTVSeason = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    getBannerADForMovieDetail();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return tvDetails == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : tvDetails!.seasons!.isEmpty
            ? Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('There is no season available for this TV show'),
                ),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: tvDetails!.seasons!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                mixpanel.track('Most viewed season details',
                                    properties: {
                                      'TV series name': '${widget.seriesName}',
                                      'TV series season number':
                                          '${tvDetails!.seasons![index].seasonNumber}',
                                      'Is TV series adult?': '${widget.adult}'
                                    });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SeasonsDetail(
                                            adult: widget.adult,
                                            seriesName: widget.seriesName,
                                            tvId: widget.tvId,
                                            tvDetails: tvDetails!,
                                            seasons: tvDetails!.seasons![index],
                                            heroId:
                                                '${tvDetails!.seasons![index].seasonId}')));
                              },
                              child: Container(
                                color: isDark
                                    ? Color(0xFF202124)
                                    : Color(0xFFFFFFFF),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 5.0,
                                    left: 15,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30.0),
                                            child: SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: Hero(
                                                tag:
                                                    '${tvDetails!.seasons![index].seasonId}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: tvDetails!
                                                              .seasons![index]
                                                              .posterPath ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : CachedNetworkImage(
                                                          fadeOutDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          fadeOutCurve:
                                                              Curves.easeOut,
                                                          fadeInDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      700),
                                                          fadeInCurve:
                                                              Curves.easeIn,
                                                          imageUrl:
                                                              TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  tvDetails!
                                                                      .seasons![
                                                                          index]
                                                                      .posterPath!,
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  Image.asset(
                                                            'assets/images/loading.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tvDetails!
                                                      .seasons![index].name!,
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: 'PoppinsSB',
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: !isDark
                                            ? Colors.black54
                                            : Colors.white54,
                                        thickness: 1,
                                        endIndent: 20,
                                        indent: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    bannerAdTVSeason != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(bannerAdTVSeason!),
                            ),
                          )
                        : Container(),
                  ],
                ));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVCrewTab extends StatefulWidget {
  final String? api;
  const TVCrewTab({Key? key, this.api}) : super(key: key);

  @override
  _TVCrewTabState createState() => _TVCrewTabState();
}

class _TVCrewTabState extends State<TVCrewTab>
    with AutomaticKeepAliveClientMixin<TVCrewTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return credits == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : credits!.crew!.isEmpty
            ? Container(
                child: const Center(
                  child:
                      Text('There is no data available for this TV show cast'),
                ),
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: ListView.builder(
                    itemCount: credits!.crew!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.crew![index].name}',
                            'Person id': '${credits!.crew![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CrewDetailPage(
                                crew: credits!.crew![index],
                                heroId: '${credits!.crew![index].name}');
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.crew![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.crew![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_square.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .crew![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_sqaure.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.crew![index].name!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB'),
                                          ),
                                          Text(
                                            'Job : '
                                            '${credits!.crew![index].department!.isEmpty ? 'N/A' : credits!.crew![index].department!}',
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
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
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVRecommendationsTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  const TVRecommendationsTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult})
      : super(key: key);

  @override
  _TVRecommendationsTabState createState() => _TVRecommendationsTabState();
}

class _TVRecommendationsTabState extends State<TVRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  var startAppSdkTVRecommendation = StartAppSdk();
  StartAppBannerAd? bannerAdTVRecommendation;
  @override
  void initState() {
    super.initState();
    getBannerADForMovieRecommendation();
    fetchTV(widget.api + '&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  void getBannerADForMovieRecommendation() {
    startAppSdkTVRecommendation
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdTVRecommendation = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse(
            '$TMDB_API_BASE_URL/tv/${widget.tvId}/recommendations?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}'
            '&language=en-US'
            '&page=$pageNum'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });

    return "success";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return tvList == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : tvList!.isEmpty
            ? Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Center(
                    child: Text(
                        'There is no recommendations available for this TV show'),
                  ),
                ),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: tvList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                mixpanel
                                    .track('Most viewed TV pages', properties: {
                                  'TV series name':
                                      '${tvList![index].originalName}',
                                  'TV series id': '${tvList![index].id}'
                                });
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return TVDetailPage(
                                    tvSeries: tvList![index],
                                    heroId: '${tvList![index].id}',
                                  );
                                }));
                              },
                              child: Container(
                                color: isDark
                                    ? Color(0xFF202124)
                                    : Color(0xFFFFFFFF),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 3.0,
                                    left: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: Hero(
                                                tag: '${tvList![index].id}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: tvList![index]
                                                              .posterPath ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : CachedNetworkImage(
                                                          fadeOutDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          fadeOutCurve:
                                                              Curves.easeOut,
                                                          fadeInDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      700),
                                                          fadeInCurve:
                                                              Curves.easeIn,
                                                          imageUrl:
                                                              TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  tvList![index]
                                                                      .posterPath!,
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  Image.asset(
                                                            'assets/images/loading.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tvList![index].name!,
                                                  style: const TextStyle(
                                                      fontFamily: 'PoppinsSB',
                                                      fontSize: 15,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    const Icon(Icons.star,
                                                        color:
                                                            Color(0xFFF57C00)),
                                                    Text(
                                                      tvList![index]
                                                          .voteAverage!
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: !isDark
                                            ? Colors.black54
                                            : Colors.white54,
                                        thickness: 1,
                                        endIndent: 20,
                                        indent: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )),
                    bannerAdTVRecommendation != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(
                                bannerAdTVRecommendation!,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ));
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarTVTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  const SimilarTVTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult})
      : super(key: key);

  @override
  _SimilarTVTabState createState() => _SimilarTVTabState();
}

class _SimilarTVTabState extends State<SimilarTVTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  var startAppSdkTVSimilars = StartAppSdk();
  StartAppBannerAd? bannerAdTVSimilars;
  @override
  void initState() {
    super.initState();
    getBannerADForTVSimilars();
    fetchTV(widget.api + '&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  void getBannerADForTVSimilars() {
    startAppSdkTVSimilars
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdTVSimilars = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse(
            '$TMDB_API_BASE_URL/tv/${widget.tvId}/similar?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}'
            '&language=en-US'
            '&page=$pageNum'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });

    return "success";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return tvList == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : tvList!.isEmpty
            ? Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: const Center(
                  child:
                      Text('There are no similars available for this TV show'),
                ),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: tvList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                mixpanel
                                    .track('Most viewed TV pages', properties: {
                                  'TV series name':
                                      '${tvList![index].originalName}',
                                  'TV series id': '${tvList![index].id}'
                                });
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return TVDetailPage(
                                    tvSeries: tvList![index],
                                    heroId: '${tvList![index].id}',
                                  );
                                }));
                              },
                              child: Container(
                                color: isDark
                                    ? Color(0xFF202124)
                                    : Color(0xFFFFFFFF),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 3.0,
                                    left: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: Hero(
                                                tag: '${tvList![index].id}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: tvList![index]
                                                              .posterPath ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : CachedNetworkImage(
                                                          fadeOutDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          fadeOutCurve:
                                                              Curves.easeOut,
                                                          fadeInDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      700),
                                                          fadeInCurve:
                                                              Curves.easeIn,
                                                          imageUrl:
                                                              TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  tvList![index]
                                                                      .posterPath!,
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  Image.asset(
                                                            'assets/images/loading.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tvList![index].name!,
                                                  style: const TextStyle(
                                                      fontFamily: 'PoppinsSB',
                                                      fontSize: 15,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    const Icon(Icons.star,
                                                        color:
                                                            Color(0xFFF57C00)),
                                                    Text(
                                                      tvList![index]
                                                          .voteAverage!
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: !isDark
                                            ? Colors.black54
                                            : Colors.white54,
                                        thickness: 1,
                                        endIndent: 20,
                                        indent: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )),
                    bannerAdTVSimilars != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(
                                bannerAdTVSimilars!,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVGenreDisplay extends StatefulWidget {
  final String? api;
  const TVGenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  _TVGenreDisplayState createState() => _TVGenreDisplayState();
}

class _TVGenreDisplayState extends State<TVGenreDisplay>
    with AutomaticKeepAliveClientMixin<TVGenreDisplay> {
  List<Genres>? genres;
  @override
  void initState() {
    super.initState();
    fetchGenre(widget.api!).then((value) {
      setState(() {
        genres = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Container(
        child: SizedBox(
      height: genres == null || genres!.isEmpty ? 0 : 80,
      child: genres == null
          ? Container()
          : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: genres!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TVGenre(
                                    genres: genres![index],
                                  )));
                    },
                    child: Chip(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Color(0xFFF57C00)),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      label: Text(
                        genres![index].genreName!,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        // style: widget.themeData.textTheme.bodyText1,
                      ),
                      backgroundColor:
                          isDark ? Color(0xFF2b2c30) : Color(0xFFDFDEDE),
                    ),
                  ),
                );
              },
            ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreTV extends StatefulWidget {
  final String api;
  final int genreId;
  final bool? includeAdult;
  const ParticularGenreTV(
      {Key? key,
      required this.api,
      required this.genreId,
      required this.includeAdult})
      : super(key: key);
  @override
  _ParticularGenreTVState createState() => _ParticularGenreTVState();
}

class _ParticularGenreTVState extends State<ParticularGenreTV> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  var startAppSdkTVGenres = StartAppSdk();
  StartAppBannerAd? bannerAdTVGenres;

  void getBannerADForTVGenres() {
    startAppSdkTVGenres
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdTVGenres = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(
            Uri.parse('$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
                '&language=en-US'
                '&sort_by=popularity.desc'
                '&watch_region=US&include_adult=${widget.includeAdult}'
                '&page=$pageNum'
                '&with_genres=${widget.genreId}'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getBannerADForTVGenres();
    fetchTV(widget.api + '&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return tvList == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : tvList!.isEmpty
            ? Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('Oops! movies for this genre doesn\'t exist :('),
                ),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: tvList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        mixpanel.track('Most viewed TV pages',
                                            properties: {
                                              'TV series name':
                                                  '${tvList![index].originalName}',
                                              'TV series id':
                                                  '${tvList![index].id}',
                                              'Is TV series adult?':
                                                  '${tvList![index].adult}'
                                            });
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return TVDetailPage(
                                            tvSeries: tvList![index],
                                            heroId: '${tvList![index].id}',
                                          );
                                        }));
                                      },
                                      child: Container(
                                        color: isDark
                                            ? Color(0xFF202124)
                                            : Color(0xFFFFFFFF),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 0.0,
                                            bottom: 3.0,
                                            left: 10,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: SizedBox(
                                                      width: 85,
                                                      height: 130,
                                                      child: Hero(
                                                        tag:
                                                            '${tvList![index].id}',
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: tvList![index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : CachedNetworkImage(
                                                                  fadeOutDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                  fadeOutCurve:
                                                                      Curves
                                                                          .easeOut,
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              700),
                                                                  fadeInCurve:
                                                                      Curves
                                                                          .easeIn,
                                                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                                                      imageQuality +
                                                                      tvList![index]
                                                                          .posterPath!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/loading.gif',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/na_logo.png',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          tvList![index].name!,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'PoppinsSB',
                                                              fontSize: 15,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            const Icon(
                                                                Icons.star,
                                                                color: Color(
                                                                    0xFFF57C00)),
                                                            Text(
                                                              tvList![index]
                                                                  .voteAverage!
                                                                  .toStringAsFixed(
                                                                      1),
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Divider(
                                                color: !isDark
                                                    ? Colors.black54
                                                    : Colors.white54,
                                                thickness: 1,
                                                endIndent: 20,
                                                indent: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )),
                    bannerAdTVGenres != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(bannerAdTVGenres!),
                            ),
                          )
                        : Container(),
                  ],
                ));
  }
}

class TVInfoTable extends StatefulWidget {
  final String? api;
  const TVInfoTable({Key? key, this.api}) : super(key: key);

  @override
  _TVInfoTableState createState() => _TVInfoTableState();
}

class _TVInfoTableState extends State<TVInfoTable> {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return tvDetails == null
        ? const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: [
              const Text(
                'TV series Info',
                style: kTextHeaderStyle,
              ),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(dataRowHeight: 40, columns: [
                      const DataColumn(
                          label: Text(
                        'Original Title',
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      )),
                      DataColumn(
                        label: Text(
                          tvDetails!.originalTitle!,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ], rows: [
                      DataRow(cells: [
                        const DataCell(Text('Status')),
                        DataCell(Text(tvDetails!.status!.isEmpty
                            ? 'unknown'
                            : tvDetails!.status!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Runtime')),
                        DataCell(Text(tvDetails!.runtime!.isEmpty
                            ? '-'
                            : tvDetails!.runtime![0] == 0
                                ? 'N/A'
                                : '${tvDetails!.runtime![0]} mins')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Spoken languages')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: tvDetails!.spokenLanguages!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tvDetails!.spokenLanguages!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(tvDetails!
                                              .spokenLanguages!.isEmpty
                                          ? 'N/A'
                                          : '${tvDetails!.spokenLanguages![index].englishName},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Total seasons')),
                        DataCell(Text(tvDetails!.numberOfSeasons! == 0
                            ? '-'
                            : '${tvDetails!.numberOfSeasons!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Total episodes')),
                        DataCell(Text(tvDetails!.numberOfEpisodes! == 0
                            ? '-'
                            : '${tvDetails!.numberOfEpisodes!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Tagline')),
                        DataCell(
                          Text(
                            tvDetails!.tagline!.isEmpty
                                ? '-'
                                : tvDetails!.tagline!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production companies')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: tvDetails!.productionCompanies!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      tvDetails!.productionCompanies!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(tvDetails!
                                              .productionCompanies!.isEmpty
                                          ? 'N/A'
                                          : '${tvDetails!.productionCompanies![index].name},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production countries')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: tvDetails!.productionCountries!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      tvDetails!.productionCountries!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(tvDetails!
                                              .productionCountries!.isEmpty
                                          ? 'N/A'
                                          : '${tvDetails!.productionCountries![index].name},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                    ]),
                  ),
                ),
              ),
            ],
          );
  }
}

class TVSocialLinks extends StatefulWidget {
  final String? api;
  const TVSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  _TVSocialLinksState createState() => _TVSocialLinksState();
}

class _TVSocialLinksState extends State<TVSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    fetchSocialLinks(widget.api!).then((value) {
      setState(() {
        externalLinks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social media links',
              style: kTextHeaderStyle,
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? const Center(
                          child: Text(
                            'This tv show doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                isDark ? Colors.transparent : Color(0xFFDFDEDE),
                          ),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SocialIconWidget(
                                isNull: externalLinks?.facebookUsername == null,
                                url: externalLinks?.facebookUsername == null
                                    ? ''
                                    : FACEBOOK_BASE_URL +
                                        externalLinks!.facebookUsername!,
                                icon: const Icon(
                                  SocialIcons.facebook_f,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull:
                                    externalLinks?.instagramUsername == null,
                                url: externalLinks?.instagramUsername == null
                                    ? ''
                                    : INSTAGRAM_BASE_URL +
                                        externalLinks!.instagramUsername!,
                                icon: const Icon(
                                  SocialIcons.instagram,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.twitterUsername == null,
                                url: externalLinks?.twitterUsername == null
                                    ? ''
                                    : TWITTER_BASE_URL +
                                        externalLinks!.twitterUsername!,
                                icon: const Icon(
                                  SocialIcons.twitter,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              SocialIconWidget(
                                isNull: externalLinks?.imdbId == null,
                                url: externalLinks?.imdbId == null
                                    ? ''
                                    : IMDB_BASE_URL + externalLinks!.imdbId!,
                                icon: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.imdb,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeasonsList extends StatefulWidget {
  final String? api;
  final String? title;
  final int? tvId;
  final String? seriesName;
  final bool? adult;

  const SeasonsList(
      {Key? key,
      this.api,
      this.title,
      this.tvId,
      this.seriesName,
      required this.adult})
      : super(key: key);

  @override
  _SeasonsListState createState() => _SeasonsListState();
}

class _SeasonsListState extends State<SeasonsList> {
  TVDetails? tvDetails;
  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title!,
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: tvDetails == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : tvDetails!.seasons!.isEmpty
                  ? Container(
                      color: const Color(0xFF202124),
                      child: const Center(
                        child: Text(
                            'There is no season available for this TV show',
                            textAlign: TextAlign.center),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: tvDetails!.seasons!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    mixpanel.track('Most viewed season details',
                                        properties: {
                                          'TV series name':
                                              '${widget.seriesName}',
                                          'TV series season number':
                                              '${tvDetails!.seasons![index].seasonNumber}',
                                          'Is TV series adult?':
                                              '${widget.adult}'
                                        });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SeasonsDetail(
                                                tvId: widget.tvId,
                                                adult: widget.adult,
                                                seriesName: widget.seriesName,
                                                tvDetails: tvDetails!,
                                                seasons:
                                                    tvDetails!.seasons![index],
                                                heroId:
                                                    '${tvDetails!.seasons![index].seasonNumber}')));
                                  },
                                  child: SizedBox(
                                    width: 105,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Hero(
                                            tag:
                                                '${tvDetails!.seasons![index].seasonNumber}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: tvDetails!.seasons![index]
                                                          .posterPath ==
                                                      null
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      fadeOutDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  300),
                                                      fadeOutCurve:
                                                          Curves.easeOut,
                                                      fadeInDuration: Duration(
                                                          milliseconds: 700),
                                                      fadeInCurve:
                                                          Curves.easeIn,
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              tvDetails!
                                                                  .seasons![
                                                                      index]
                                                                  .posterPath!,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              Image.asset(
                                                        'assets/images/loading.gif',
                                                        fit: BoxFit.cover,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              tvDetails!.seasons![index].name!,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class EpisodeListWidget extends StatefulWidget {
  final int? tvId;
  final String? api;
  final String? seriesName;
  final bool? adult;
  const EpisodeListWidget(
      {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
      : super(key: key);

  @override
  _EpisodeListWidgetState createState() => _EpisodeListWidgetState();
}

class _EpisodeListWidgetState extends State<EpisodeListWidget>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Container(
        color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
        child: tvDetails == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: tvDetails!.episodes!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      mixpanel
                          .track('Most viewed episode details', properties: {
                        'TV series name': '${widget.seriesName}',
                        'TV series episode name':
                            '${tvDetails!.episodes![index].name}',
                      });
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EpisodeDetailPage(
                            adult: widget.adult,
                            seriesName: widget.seriesName,
                            tvId: widget.tvId,
                            episodes: tvDetails!.episodes,
                            episodeList: tvDetails!.episodes![index]);
                      }));
                    },
                    child: Container(
                      color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 8.0,
                          left: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tvDetails!.episodes![index].episodeNumber!
                                    .toString()),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, left: 5.0),
                                  child: Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: tvDetails!.episodes![index]
                                                      .stillPath ==
                                                  null ||
                                              tvDetails!.episodes![index]
                                                  .stillPath!.isEmpty
                                          ? Image.asset(
                                              'assets/images/na_logo.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration:
                                                  Duration(milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  tvDetails!.episodes![index]
                                                      .stillPath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                'assets/images/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                    height: 56.4,
                                    width: 100,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(tvDetails!.episodes![index].name!,
                                          style: const TextStyle(
                                              overflow: TextOverflow.ellipsis)),
                                      Text(
                                        tvDetails!.episodes![index].airDate ==
                                                    null ||
                                                tvDetails!.episodes![index]
                                                    .airDate!.isEmpty
                                            ? 'Air date unknown'
                                            : '${DateTime.parse(tvDetails!.episodes![index].airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(tvDetails!.episodes![index].airDate!))}, ${DateTime.parse(tvDetails!.episodes![index].airDate!).year}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                      ),
                                      Row(children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 3.0),
                                          child: Icon(
                                            Icons.star,
                                            size: 20,
                                          ),
                                        ),
                                        Text(tvDetails!
                                            .episodes![index].voteAverage!
                                            .toStringAsFixed(1))
                                      ]),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Divider(
                              color: Color(0xFFF57C00),
                              thickness: 1.5,
                              endIndent: 30,
                              indent: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVWatchProvidersDetails extends StatefulWidget {
  final String api;
  const TVWatchProvidersDetails({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<TVWatchProvidersDetails> createState() =>
      _TVWatchProvidersDetailsState();
}

class _TVWatchProvidersDetailsState extends State<TVWatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return watchProviders == null
        ? const Center(child: CircularProgressIndicator())
        : Container(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF2b2c30) : Color(0xFFDFDEDE),
                  ),
                  child: Center(
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      indicatorColor: const Color(0xFFF57C00),
                      indicatorWeight: 3,
                      unselectedLabelColor: Colors.white54,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Text('Buy',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.white : Colors.black)),
                        ),
                        Tab(
                          child: Text('Stream',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.white : Colors.black)),
                        ),
                        Tab(
                          child: Text('ADS',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.white : Colors.black)),
                        ),
                        Tab(
                          child: Text('Rent',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.white : Colors.black)),
                        ),
                        Tab(
                          child: Text('Free',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: isDark ? Colors.white : Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.buy == null
                            ? const Center(
                                child: Text(
                                    'This TV series doesn\'t have an option to buy yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.buy!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: watchProviders!
                                                        .buy![index].logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            watchProviders!
                                                                .buy![index]
                                                                .logoPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              watchProviders!
                                                  .buy![index].providerName!,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.flatRate == null
                            ? const Center(
                                child: Text(
                                    'This TV series doesn\'t have an option to stream yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.flatRate!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: watchProviders!
                                                        .flatRate![index]
                                                        .logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            watchProviders!
                                                                .flatRate![
                                                                    index]
                                                                .logoPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              watchProviders!.flatRate![index]
                                                  .providerName!,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.ads == null
                            ? const Center(
                                child: Text(
                                    'This TV series doesn\'t have an option to watch through ADS yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.ads!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: watchProviders!
                                                        .ads![index].logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            watchProviders!
                                                                .ads![index]
                                                                .logoPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            watchProviders!
                                                .ads![index].providerName!,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.rent == null
                            ? const Center(
                                child: Text(
                                    'This TV series doesn\'t have an option to rent yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.rent!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: watchProviders!.rent![index]
                                                        .logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            watchProviders!
                                                                .rent![index]
                                                                .logoPath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            watchProviders!
                                                .rent![index].providerName!,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: const FadeInImage(
                                          image: AssetImage(
                                              'assets/images/logo_shadow.png'),
                                          fit: BoxFit.cover,
                                          placeholder: AssetImage(
                                              'assets/images/loading.gif'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Expanded(
                                        flex: 6,
                                        child: Text(
                                          'Cinemax',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}

class TVGenreListGrid extends StatefulWidget {
  final String api;
  const TVGenreListGrid({Key? key, required this.api}) : super(key: key);

  @override
  _TVGenreListGridState createState() => _TVGenreListGridState();
}

class _TVGenreListGridState extends State<TVGenreListGrid>
    with AutomaticKeepAliveClientMixin<TVGenreListGrid> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    fetchGenre(widget.api).then((value) {
      setState(() {
        genreList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return genreList == null
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Genres',
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Genres',
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: genreList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return TVGenre(genres: genreList![index]);
                                  }));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 125,
                                    alignment: Alignment.center,
                                    child: Text(genreList![index].genreName!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF57C00),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class TVShowsFromWatchProviders extends StatefulWidget {
  const TVShowsFromWatchProviders({Key? key}) : super(key: key);

  @override
  _TVShowsFromWatchProvidersState createState() =>
      _TVShowsFromWatchProvidersState();
}

class _TVShowsFromWatchProvidersState extends State<TVShowsFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Streaming services',
              style: kTextHeaderStyle,
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 75,
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      TVStreamingServicesWidget(
                          imagePath: 'assets/images/disney_plus.png',
                          title: 'Disney plus',
                          providerID: 337),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix Kids',
                        providerID: 175,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]);
  }
}

class TVStreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const TVStreamingServicesWidget({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.providerID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return StreamingServicesTVShows(
            providerId: providerID,
            providerName: title,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 60,
          width: 200,
          decoration: BoxDecoration(
              color: const Color(0xFFF57C00),
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(imagePath),
                height: 50,
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticularStreamingServiceTVShows extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  const ParticularStreamingServiceTVShows({
    Key? key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
  }) : super(key: key);
  @override
  _ParticularStreamingServiceTVShowsState createState() =>
      _ParticularStreamingServiceTVShowsState();
}

class _ParticularStreamingServiceTVShowsState
    extends State<ParticularStreamingServiceTVShows> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  var startAppSdkTVProviders = StartAppSdk();
  StartAppBannerAd? bannerAdTVProviders;
  int pageNum = 2;
  bool isLoading = false;

  void getBannerADForTVProviders() {
    startAppSdkTVProviders
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdTVProviders = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/discover/tv?api_key='
            '$TMDB_API_KEY'
            '&language=en-US&sort_by=popularity&include_adult=${widget.includeAdult}'
            '.desc&include_adult=false&include_video=false&page=$pageNum'
            '&with_watch_providers=${widget.providerID}'
            '&watch_region=US'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getBannerADForTVProviders();
    fetchTV(widget.api + '&include_adult=${widget.includeAdult}').then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return tvList == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : tvList!.isEmpty
            ? Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'Oops! TV shows for this watch provider doesn\'t exist :('),
                ),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  controller: _scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: tvList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        mixpanel.track('Most viewed TV pages',
                                            properties: {
                                              'TV series name':
                                                  '${tvList![index].originalName}',
                                              'TV series id':
                                                  '${tvList![index].id}',
                                              'Is Movie adult?':
                                                  '${tvList![index].adult}'
                                            });
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return TVDetailPage(
                                            tvSeries: tvList![index],
                                            heroId: '${tvList![index].id}',
                                          );
                                        }));
                                      },
                                      child: Container(
                                        color: isDark
                                            ? Color(0xFF202124)
                                            : Color(0xFFFFFFFF),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 0.0,
                                            bottom: 3.0,
                                            left: 10,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: SizedBox(
                                                      width: 85,
                                                      height: 130,
                                                      child: Hero(
                                                        tag:
                                                            '${tvList![index].id}',
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: tvList![index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : CachedNetworkImage(
                                                                  fadeOutDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                  fadeOutCurve:
                                                                      Curves
                                                                          .easeOut,
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              700),
                                                                  fadeInCurve:
                                                                      Curves
                                                                          .easeIn,
                                                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                                                      imageQuality +
                                                                      tvList![index]
                                                                          .posterPath!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/loading.gif',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/na_logo.png',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          tvList![index].name!,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'PoppinsSB',
                                                              fontSize: 15,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            const Icon(
                                                                Icons.star,
                                                                color: Color(
                                                                    0xFFF57C00)),
                                                            Text(
                                                              tvList![index]
                                                                  .voteAverage!
                                                                  .toStringAsFixed(
                                                                      1),
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Divider(
                                                color: !isDark
                                                    ? Colors.black54
                                                    : Colors.white54,
                                                thickness: 1,
                                                endIndent: 20,
                                                indent: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )),
                    bannerAdTVProviders != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(
                                bannerAdTVProviders!,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ));
  }
}

class TVEpisodeCastTab extends StatefulWidget {
  final String? api;
  const TVEpisodeCastTab({Key? key, this.api}) : super(key: key);

  @override
  _TVEpisodeCastTabState createState() => _TVEpisodeCastTabState();
}

class _TVEpisodeCastTabState extends State<TVEpisodeCastTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeCastTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return credits == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : credits!.cast!.isEmpty
            ? Container(
                child: const Center(
                  child: Text(
                      'There is no data available for this TV episode cast'),
                ),
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.cast![index].name}',
                            'Person id': '${credits!.cast![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_square.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_square.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'As : '
                                            '${credits!.cast![index].character!.isEmpty ? 'N/A' : credits!.cast![index].character!}',
                                          ),
                                          // Text(
                                          //   credits!.cast![index].roles![0]
                                          //               .episodeCount! ==
                                          //           1
                                          //       ? credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episode'
                                          //       : credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episodes',
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
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
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVEpisodeGuestStarsTab extends StatefulWidget {
  final String? api;
  const TVEpisodeGuestStarsTab({Key? key, this.api}) : super(key: key);

  @override
  _TVEpisodeGuestStarsTabState createState() => _TVEpisodeGuestStarsTabState();
}

class _TVEpisodeGuestStarsTabState extends State<TVEpisodeGuestStarsTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeGuestStarsTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return credits == null
        ? Container(
            color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : credits!.episodeGuestStars!.isEmpty
            ? Container(
                child: const Center(
                  child: Text(
                      'There is no data available for this TV episode guest stars'),
                ),
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
              )
            : Container(
                color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                child: ListView.builder(
                    itemCount: credits!.episodeGuestStars!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name':
                                '${credits!.episodeGuestStars![index].name}',
                            'Person id':
                                '${credits!.episodeGuestStars![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return GuestStarDetailPage(
                                cast: credits!.episodeGuestStars![index],
                                heroId:
                                    '${credits!.episodeGuestStars![index].creditId}');
                          }));
                        },
                        child: Container(
                          color: isDark ? Color(0xFF202124) : Color(0xFFFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 5.0,
                              left: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  // crossAxisAlignment:
                                  //     CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, left: 10),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Hero(
                                          tag:
                                              '${credits!.episodeGuestStars![index].creditId}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!
                                                        .episodeGuestStars![
                                                            index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_square.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fadeOutDuration:
                                                        const Duration(
                                                            milliseconds: 300),
                                                    fadeOutCurve:
                                                        Curves.easeOut,
                                                    fadeInDuration: Duration(
                                                        milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl: TMDB_BASE_IMAGE_URL +
                                                        imageQuality +
                                                        credits!
                                                            .episodeGuestStars![
                                                                index]
                                                            .profilePath!,
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_square.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            credits!.episodeGuestStars![index]
                                                .name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'As : '
                                            '${credits!.episodeGuestStars![index].character!.isEmpty ? 'N/A' : credits!.episodeGuestStars![index].character!}',
                                          ),
                                          // Text(
                                          //   credits!.cast![index].roles![0]
                                          //               .episodeCount! ==
                                          //           1
                                          //       ? credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episode'
                                          //       : credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episodes',
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
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
                        ),
                      );
                    }));
  }

  @override
  bool get wantKeepAlive => true;
}
