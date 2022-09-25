// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:cinemax/screens/hero_photoview.dart';
import 'package:cinemax/screens/player.dart';
import 'package:cinemax/screens/movie_video_loader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:startapp_sdk/startapp.dart';
import '../provider/adultmode_provider.dart';
import '../provider/imagequality_provider.dart';
import '../provider/mixpanel_provider.dart';
import '/constants/app_constants.dart';
import '/models/social_icons_icons.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import '/screens/cast_detail.dart';
import '/screens/streaming_services_movies.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/models/function.dart';
import '/models/movie.dart';
import '/api/endpoints.dart';
import '/models/genres.dart';
import '/constants/api_constants.dart';
import '/screens/movie_detail.dart';
import '/models/credits.dart';
import 'collection_detail.dart';
import 'crew_detail.dart';
import '/models/images.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'genremovies.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'movie_stream_select.dart';
import 'package:provider/provider.dart';
import 'common_widgets.dart';

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay> {
  var startAppSdk = StartAppSdk();
  var startAppSdk1 = StartAppSdk();
  var startAppSdk2 = StartAppSdk();

  StartAppBannerAd? bannerAd0;
  StartAppBannerAd? bannerAd1;
  StartAppBannerAd? bannerAd2;

  @override
  void initState() {
    super.initState();
    getBannerADForMainMovieDisplay();
  }

  void getBannerADForMainMovieDisplay() {
    startAppSdk
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAd0 = bannerAd;
      });
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
      setState(() {
        bannerAd1 = bannerAd;
      });
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
      setState(() {
        bannerAd2 = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool includeAdult = Provider.of<AdultmodeProvider>(context).isAdult;
    return Container(
      child: ListView(
        children: [
          DiscoverMovies(
            includeAdult: includeAdult,
          ),
          bannerAd0 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StartAppBanner(bannerAd0!),
                )
              : Container(),
          ScrollingMovies(
            title: 'Popular',
            api: Endpoints.popularMoviesUrl(1),
            discoverType: 'popular',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: 'Trending this week',
            api: Endpoints.trendingMoviesUrl(1, includeAdult),
            discoverType: 1,
            isTrending: true,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: 'Top Rated',
            api: Endpoints.topRatedUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          bannerAd1 != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: StartAppBanner(bannerAd1!),
                )
              : Container(),
          ScrollingMovies(
            title: 'Now playing',
            api: Endpoints.nowPlayingMoviesUrl(1),
            discoverType: 'now_playing',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: 'Upcoming',
            api: Endpoints.upcomingMoviesUrl(1),
            discoverType: 'upcoming',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          GenreListGrid(api: Endpoints.movieGenresUrl()),
          const MoviesFromWatchProviders(),
          bannerAd2 != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: StartAppBanner(bannerAd2!),
                )
              : Container(),
        ],
      ),
    );
  }
}

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies({Key? key, required this.includeAdult})
      : super(key: key);
  final bool includeAdult;
  @override
  DiscoverMoviesState createState() => DiscoverMoviesState();
}

class DiscoverMoviesState extends State<DiscoverMovies>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  late double deviceHeight;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchMovies(
            '${Endpoints.discoverMoviesUrl(1)}&inculde_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
          height: 350,
          // height: deviceHeight * 0.417,
          child: moviesList == null
              ? discoverMoviesAndTVShimmer(isDark)
              : requestFailed == true
                  ? retryWidget()
                  : CarouselSlider.builder(
                      options: CarouselOptions(
                        disableCenter: true,
                        viewportFraction: 0.6,
                        enlargeCenterPage: true,
                        autoPlay: true,
                      ),
                      itemBuilder:
                          (BuildContext context, int index, pageViewIndex) {
                        return Container(
                          child: GestureDetector(
                            onTap: () {
                              mixpanel.track('Most viewed movie pages',
                                  properties: {
                                    'Movie name':
                                        '${moviesList![index].originalTitle}',
                                    'Movie id': '${moviesList![index].id}'
                                  });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId:
                                              '${moviesList![index].id}discover')));
                            },
                            child: Hero(
                              tag: '${moviesList![index].id}discover',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: TMDB_BASE_IMAGE_URL +
                                      imageQuality +
                                      moviesList![index].posterPath!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      discoverImageShimmer(isDark),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: moviesList!.length,
                    ),
        ),
      ],
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
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
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
                });
                getData();
              },
              child: const Text('Retry')),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingMovies extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;
  final bool? includeAdult;

  const ScrollingMovies({
    Key? key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
    required this.includeAdult,
  }) : super(key: key);
  @override
  ScrollingMoviesState createState() => ScrollingMoviesState();
}

class ScrollingMoviesState extends State<ScrollingMovies>
    with AutomaticKeepAliveClientMixin {
  late int index;
  List<Movie>? moviesList;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;
  bool requestFailed = false;

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
                "$TMDB_API_BASE_URL/movie/${widget.discoverType}?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/movie/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=${widget.includeAdult}&page=$pageNum"),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [];
        });
      }
    });
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
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
          child: moviesList == null || widget.includeAdult == null
              ? scrollingMoviesAndTVShimmer(isDark)
              : requestFailed == true
                  ? retryWidget()
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: moviesList!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    mixpanel.track('Most viewed movie pages',
                                        properties: {
                                          'Movie name':
                                              '${moviesList![index].originalTitle}',
                                          'Movie id':
                                              '${moviesList![index].id}',
                                          'Is Movie adult?':
                                              '${moviesList![index].adult}'
                                        });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MovieDetailPage(
                                                movie: moviesList![index],
                                                heroId:
                                                    '${moviesList![index].id}${widget.title}')));
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Hero(
                                            tag:
                                                '${moviesList![index].id}${widget.title}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: moviesList![index]
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
                                                          const Duration(
                                                              milliseconds:
                                                                  700),
                                                      fadeInCurve:
                                                          Curves.easeIn,
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              moviesList![index]
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
                                                      placeholder: (context,
                                                              url) =>
                                                          scrollingImageShimmer(
                                                              isDark),
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
                                              moviesList![index].title!,
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
                        Visibility(
                          visible: isLoading,
                          child: SizedBox(
                            width: 110,
                            child: horizontalLoadMoreShimmer(isDark),
                          ),
                        ),
                      ],
                    ),
        ),
        Divider(
          color: !isDark ? Colors.black54 : Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
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
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
                });
                getData();
              },
              child: const Text('Retry')),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  ScrollingArtistsState createState() => ScrollingArtistsState();
}

class ScrollingArtistsState extends State<ScrollingArtists> {
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
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
                            'There are no casts available for this movie',
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
              ? detailCastShimmer(isDark)
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
                                child: Hero(
                                  tag: '${credits!.cast![index].id}',
                                  child: SizedBox(
                                    width: 75,
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
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
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
                                                  detailCastImageShimmer(
                                                      isDark),
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
}

class MovieSocialLinks extends StatefulWidget {
  final String? api;
  const MovieSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  MovieSocialLinksState createState() => MovieSocialLinksState();
}

class MovieSocialLinksState extends State<MovieSocialLinks> {
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
                  ? socialMediaShimmer(isDark)
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? const Center(
                          child: Text(
                            'This movie doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? Colors.transparent
                                : const Color(0xFFDFDEDE),
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

class BelongsToCollectionWidget extends StatefulWidget {
  final String? api;
  const BelongsToCollectionWidget({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  BelongsToCollectionWidgetState createState() =>
      BelongsToCollectionWidgetState();
}

class BelongsToCollectionWidgetState extends State<BelongsToCollectionWidget> {
  BelongsToCollection? belongsToCollection;
  @override
  void initState() {
    super.initState();
    fetchBelongsToCollection(widget.api!).then((value) {
      setState(() {
        belongsToCollection = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return belongsToCollection == null
        ? Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            highlightColor:
                isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        : belongsToCollection?.id == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: belongsToCollection!.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                    )
                                  : FadeInImage(
                                      fit: BoxFit.fill,
                                      placeholder: const AssetImage(
                                          'assets/images/loading.gif'),
                                      image: NetworkImage(
                                          '${TMDB_BASE_IMAGE_URL}w500/${belongsToCollection!.backdropPath!}')),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Belongs to the ${belongsToCollection!.name!}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          backgroundColor: Color(0xFFF57C00)),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0x26F57C00)),
                                          maximumSize:
                                              MaterialStateProperty.all(
                                                  const Size(200, 40)),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: const BorderSide(
                                                      color: Color(0xFFF57C00))))),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CollectionDetailsWidget(
                                              belongsToCollection:
                                                  belongsToCollection!);
                                        }));
                                      },
                                      child: const Text(
                                        'View the collection',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    )),
              );
  }
}

class CollectionOverviewWidget extends StatefulWidget {
  final String? api;
  const CollectionOverviewWidget({Key? key, this.api}) : super(key: key);

  @override
  CollectionOverviewWidgetState createState() =>
      CollectionOverviewWidgetState();
}

class CollectionOverviewWidgetState extends State<CollectionOverviewWidget> {
  CollectionDetails? collectionDetails;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchCollectionDetails(widget.api!).then((value) {
      setState(() {
        collectionDetails = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (collectionDetails == null) {
        setState(() {
          requestFailed = true;
          collectionDetails = CollectionDetails();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Container(
      child: collectionDetails == null
          ? Shimmer.fromColors(
              baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              highlightColor:
                  isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              direction: ShimmerDirection.ltr,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 20),
                  ),
                  Container(
                      color: Colors.white, width: double.infinity, height: 20)
                ],
              ),
            )
          : requestFailed == true
              ? retryWidget(isDark)
              : Text(collectionDetails!.overview!),
    );
  }

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      collectionDetails = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }
}

class PartsList extends StatefulWidget {
  final String? api;
  final String? title;
  const PartsList({Key? key, this.api, this.title}) : super(key: key);

  @override
  PartsListState createState() => PartsListState();
}

class PartsListState extends State<PartsList> {
  List<Movie>? collectionMovieList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchCollectionMovies(widget.api!).then((value) {
      setState(() {
        collectionMovieList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (collectionMovieList == null) {
        setState(() {
          requestFailed = true;
          collectionMovieList = [Movie()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
          child: collectionMovieList == null
              ? Row(
                  children: [
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        highlightColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade100,
                        direction: ShimmerDirection.ltr,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 105,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 30),
                                        child: Container(
                                          width: 110.0,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : requestFailed == true
                  ? retryWidget(isDark)
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: collectionMovieList!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    mixpanel.track('Most viewed movie pages',
                                        properties: {
                                          'Movie name':
                                              '${collectionMovieList![index].originalTitle}',
                                          'Movie id':
                                              '${collectionMovieList![index].id}',
                                          'Is Movie adult?':
                                              '${collectionMovieList![index].adult}'
                                        });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MovieDetailPage(
                                                movie:
                                                    collectionMovieList![index],
                                                heroId:
                                                    '${collectionMovieList![index].id}')));
                                  },
                                  child: SizedBox(
                                    width: 105,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Hero(
                                            tag:
                                                '${collectionMovieList![index].id}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: collectionMovieList![index]
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
                                                          const Duration(
                                                              milliseconds:
                                                                  700),
                                                      fadeInCurve:
                                                          Curves.easeIn,
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              collectionMovieList![
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
                                              collectionMovieList![index]
                                                  .title!,
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

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      collectionMovieList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }
}

class SocialIconWidget extends StatelessWidget {
  const SocialIconWidget({
    Key? key,
    this.url,
    this.icon,
    this.isNull,
  }) : super(key: key);

  final String? url;
  final Widget? icon;
  final bool? isNull;

  @override
  Widget build(BuildContext context) {
    return isNull == true
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(url!),
                    mode: LaunchMode.externalApplication);
              },
              child: Container(
                height: 50,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: icon,
              ),
            ),
          );
  }
}

class MovieImagesDisplay extends StatefulWidget {
  final String? api, title;
  const MovieImagesDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  MovieImagesState createState() => MovieImagesState();
}

class MovieImagesState extends State<MovieImagesDisplay> {
  Images? movieImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        movieImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        movieImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: movieImages == null
                ? detailImageShimmer(isDark)
                : movieImages!.backdrop!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                            'This movie doesn\'t have an image provided',
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
                                child: movieImages!.backdrop![index].filePath ==
                                        null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        fadeOutDuration:
                                            const Duration(milliseconds: 300),
                                        fadeOutCurve: Curves.easeOut,
                                        fadeInDuration:
                                            const Duration(milliseconds: 700),
                                        fadeInCurve: Curves.easeIn,
                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                            imageQuality +
                                            movieImages!
                                                .backdrop![index].filePath!,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        HeroPhotoView(
                                                            imageProvider:
                                                                imageProvider,
                                                            heroId: TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                movieImages!
                                                                    .backdrop![
                                                                        index]
                                                                    .filePath!))));
                                          },
                                          child: Hero(
                                            tag: TMDB_BASE_IMAGE_URL +
                                                imageQuality +
                                                movieImages!
                                                    .backdrop![index].filePath!,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            detailImageImageSimmer(isDark),
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
                        itemCount: movieImages!.backdrop!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class MovieVideosDisplay extends StatefulWidget {
  final String? api, title;
  const MovieVideosDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  MovieVideosState createState() => MovieVideosState();
}

class MovieVideosState extends State<MovieVideosDisplay> {
  Videos? movieVideos;

  @override
  void initState() {
    super.initState();
    fetchVideos(widget.api!).then((value) {
      setState(() {
        movieVideos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        movieVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: movieVideos == null
                ? detailVideoShimmer(isDark)
                : movieVideos!.result!.isEmpty
                    ? const SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                              'This movie doesn\'t have a video provided',
                              textAlign: TextAlign.center),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
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
                                  launchUrl(
                                      Uri.parse(YOUTUBE_BASE_URL +
                                          movieVideos!
                                              .result![index].videoLink!),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: SizedBox(
                                  height: 205,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 200,
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
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        '$YOUTUBE_THUMBNAIL_URL${movieVideos!.result![index].videoLink!}/hqdefault.jpg',
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
                                                    placeholder: (context,
                                                            url) =>
                                                        detailVideoImageShimmer(
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_square.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        playButtonVisibility,
                                                    child: const SizedBox(
                                                      height: 90,
                                                      width: 90,
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 90,
                                                      ),
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
                                          movieVideos!.result![index].name!,
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
                          itemCount: movieVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.adult,
  }) : super(key: key);
  final String? movieName;
  final int? movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;

  @override
  WatchNowButtonState createState() => WatchNowButtonState();
}

class WatchNowButtonState extends State<WatchNowButton> {
  MovieDetails? movieDetails;
  bool? isVisible = false;
  double? buttonWidth = 150;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Container(
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor:
                MaterialStateProperty.all(const Color(0xFFF57C00))),
        onPressed: () async {
          mixpanel.track('Most viewed movies', properties: {
            'Movie name': '${widget.movieName}',
            'Movie id': '${widget.movieId}',
            'Is Movie adult?': '${widget.adult}'
          });
          setState(() {
            isVisible = true;
            buttonWidth = 170;
          });
          await fetchMovieDetails(widget.api!).then((value) {
            setState(() {
              movieDetails = value;
            });
          });
          setState(() {
            isVisible = false;
            buttonWidth = 150;
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MovieVideoLoader(imdbID: movieDetails!.imdbId!);
          }));
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            const Text(
              'WATCH NOW',
              style: TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: isVisible!,
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                ),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreDisplay extends StatefulWidget {
  final String? api;
  const GenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  GenreDisplayState createState() => GenreDisplayState();
}

class GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    fetchGenre(widget.api!).then((value) {
      setState(() {
        genreList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    super.build(context);
    return Container(
        child: genreList == null
            ? SizedBox(
                height: 80,
                child: detailGenreShimmer(isDark),
              )
            : genreList!.isEmpty
                ? Container()
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: genreList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GenreMovies(
                                            genres: genreList![index],
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
                                genreList![index].genreName!,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                // style: widget.themeData.textTheme.bodyText1,
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFF2b2c30)
                                  : const Color(0xFFDFDEDE),
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

class MovieInfoTable extends StatefulWidget {
  final String? api;
  const MovieInfoTable({Key? key, this.api}) : super(key: key);

  @override
  MovieInfoTableState createState() => MovieInfoTableState();
}

class MovieInfoTableState extends State<MovieInfoTable> {
  MovieDetails? movieDetails;
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    fetchMovieDetails(widget.api!).then((value) {
      setState(() {
        movieDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
      children: [
        const Text(
          'Movie Info',
          style: kTextHeaderStyle,
        ),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: movieDetails == null
                  ? detailInfoTableShimmer(isDark)
                  : DataTable(dataRowHeight: 40, columns: [
                      const DataColumn(
                          label: Text(
                        'Original Title',
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      )),
                      DataColumn(
                        label: Text(
                          movieDetails!.originalTitle!,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ], rows: [
                      DataRow(cells: [
                        const DataCell(Text('Status')),
                        DataCell(Text(movieDetails!.status!.isEmpty
                            ? 'unknown'
                            : movieDetails!.status!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Runtime')),
                        DataCell(Text(movieDetails!.runtime! == 0
                            ? 'N/A'
                            : '${movieDetails!.runtime!} mins')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Spoken language')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: movieDetails!.spokenLanguages!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      movieDetails!.spokenLanguages!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(movieDetails!
                                              .spokenLanguages!.isEmpty
                                          ? 'N/A'
                                          : '${movieDetails!.spokenLanguages![index].englishName},'),
                                    );
                                  },
                                ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Budget')),
                        DataCell(movieDetails!.budget == 0
                            ? const Text('-')
                            : Text(formatCurrency
                                .format(movieDetails!.budget!)
                                .toString())),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Revenue')),
                        DataCell(movieDetails!.budget == 0
                            ? const Text('-')
                            : Text(formatCurrency
                                .format(movieDetails!.revenue!)
                                .toString())),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Tagline')),
                        DataCell(
                          Text(
                            movieDetails!.tagline!.isEmpty
                                ? '-'
                                : movieDetails!.tagline!,
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
                          child: movieDetails!.productionCompanies!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      movieDetails!.productionCompanies!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(movieDetails!
                                              .productionCompanies!.isEmpty
                                          ? 'N/A'
                                          : '${movieDetails!.productionCompanies![index].name},'),
                                    );
                                  },
                                ),
                        )
                            // movieDetails!.productionCompanies!.isEmpty
                            //     ? const Text('-')
                            //     : Text(
                            //         movieDetails!.productionCompanies![0].name!),
                            ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production countries')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: movieDetails!.productionCountries!.isEmpty
                              ? const Text('-')
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      movieDetails!.productionCountries!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: Text(movieDetails!
                                              .productionCountries!.isEmpty
                                          ? 'N/A'
                                          : '${movieDetails!.productionCountries![index].name},'),
                                    );
                                  },
                                ),
                        )
                            // movieDetails!.productionCompanies!.isEmpty
                            //     ? const Text('-')
                            //     : Text(
                            //         movieDetails!.productionCountries![0].name!),
                            ),
                      ]),
                    ]),
            ),
          ),
        ),
      ],
    );
  }
}

class CastTab extends StatefulWidget {
  final String? api;
  const CastTab({Key? key, this.api}) : super(key: key);

  @override
  CastTabState createState() => CastTabState();
}

class CastTabState extends State<CastTab>
    with AutomaticKeepAliveClientMixin<CastTab> {
  Credits? credits;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });

    Future.delayed(const Duration(seconds: 11), () {
      if (credits == null) {
        setState(() {
          requestFailed = true;
          credits = Credits(cast: [Cast()]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    super.build(context);
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return credits == null
        ? movieCastAndCrewTabShimmer(isDark)
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('There is no cast available for this movie'),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                    child: ListView.builder(
                        itemCount: credits!.cast!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              mixpanel.track('Most viewed person pages',
                                  properties: {
                                    'Person name':
                                        '${credits!.cast![index].name}',
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
                              color: isDark
                                  ? const Color(0xFF202124)
                                  : const Color(0xFFFFFFFF),
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
                                                  '${credits!.cast![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
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
                                                                milliseconds:
                                                                    300),
                                                        fadeOutCurve:
                                                            Curves.easeOut,
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    700),
                                                        fadeInCurve:
                                                            Curves.easeIn,
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                credits!
                                                                    .cast![
                                                                        index]
                                                                    .profilePath!,
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
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer(
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
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
                        }));
  }

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      credits = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CrewTab extends StatefulWidget {
  final String? api;
  const CrewTab({Key? key, this.api}) : super(key: key);

  @override
  CrewTabState createState() => CrewTabState();
}

class CrewTabState extends State<CrewTab>
    with AutomaticKeepAliveClientMixin<CrewTab> {
  Credits? credits;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (credits == null) {
        setState(() {
          requestFailed = true;
          credits = Credits(crew: [Crew()]);
        });
      }
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
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            child: movieCastAndCrewTabShimmer(isDark))
        : credits!.crew!.isEmpty
            ? Container(
                color: const Color(0xFF202124),
                child: const Center(
                  child:
                      Text('There is no data available for this TV show cast'),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                    child: ListView.builder(
                        itemCount: credits!.crew!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              mixpanel.track('Most viewed person pages',
                                  properties: {
                                    'Person name':
                                        '${credits!.crew![index].name}',
                                    'Person id': '${credits!.crew![index].id}'
                                  });
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CrewDetailPage(
                                    crew: credits!.crew![index],
                                    heroId:
                                        '${credits!.crew![index].creditId}');
                              }));
                            },
                            child: Container(
                              color: isDark
                                  ? const Color(0xFF202124)
                                  : const Color(0xFFFFFFFF),
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
                                                  '${credits!.crew![index].creditId}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
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
                                                                milliseconds:
                                                                    300),
                                                        fadeOutCurve:
                                                            Curves.easeOut,
                                                        fadeInDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    700),
                                                        fadeInCurve:
                                                            Curves.easeIn,
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                credits!
                                                                    .crew![
                                                                        index]
                                                                    .profilePath!,
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
                                                        placeholder: (context,
                                                                url) =>
                                                            castAndCrewTabImageShimmer(
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
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
                        }));
  }

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      credits = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MovieRecommendationsTab extends StatefulWidget {
  final String api;
  final int movieId;
  final bool? includeAdult;
  const MovieRecommendationsTab(
      {Key? key,
      required this.api,
      required this.movieId,
      required this.includeAdult})
      : super(key: key);

  @override
  MovieRecommendationsTabState createState() => MovieRecommendationsTabState();
}

class MovieRecommendationsTabState extends State<MovieRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  var startAppSdkMovieRecommendation = StartAppSdk();
  StartAppBannerAd? bannerAdMovieRecommendation;
  int pageNum = 2;
  bool isLoading = false;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getBannerADForMovieRecommendation();
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        movieList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (movieList == null) {
        setState(() {
          requestFailed = true;
          movieList = [Movie()];
        });
      }
    });
  }

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse(
            '$TMDB_API_BASE_URL/movie/${widget.movieId}/recommendations?api_key=$TMDB_API_KEY'
            '&language=en-US&include_adult=${widget.includeAdult}'
            '&page=$pageNum'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => Movie.fromJson(i))
              .toList();
          movieList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  void getBannerADForMovieRecommendation() {
    startAppSdkMovieRecommendation
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdMovieRecommendation = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return movieList == null
        ? Container(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            child: detailsRecommendationsAndSimilarShimmer(isDark,
                _scrollController, bannerAdMovieRecommendation, isLoading))
        : movieList!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                    'There are no recommendations available for this movie',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: movieList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    mixpanel.track('Most viewed movie pages',
                                        properties: {
                                          'Movie name':
                                              '${movieList![index].originalTitle}',
                                          'Movie id': '${movieList![index].id}',
                                          'Is Movie adult?':
                                              '${movieList![index].adult}'
                                        });

                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MovieDetailPage(
                                        movie: movieList![index],
                                        heroId: '${movieList![index].id}',
                                      );
                                    }));
                                  },
                                  child: Container(
                                    color: isDark
                                        ? const Color(0xFF202124)
                                        : const Color(0xFFFFFFFF),
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
                                                    tag:
                                                        '${movieList![index].id}',
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: movieList![index]
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
                                                                  Curves
                                                                      .easeOut,
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          700),
                                                              fadeInCurve:
                                                                  Curves.easeIn,
                                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  movieList![
                                                                          index]
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
                                                                  recommendationAndSimilarTabImageShimmer(
                                                                      isDark),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      movieList![index].title!,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                          fontSize: 15,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                        Text(
                                                          movieList![index]
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
                        Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )),
                        bannerAdMovieRecommendation != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: StartAppBanner(
                                    bannerAdMovieRecommendation!,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ));
  }

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      movieList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarMoviesTab extends StatefulWidget {
  final String api;
  final int movieId;
  final bool? includeAdult;
  const SimilarMoviesTab(
      {Key? key,
      required this.api,
      required this.movieId,
      required this.includeAdult})
      : super(key: key);

  @override
  SimilarMoviesTabState createState() => SimilarMoviesTabState();
}

class SimilarMoviesTabState extends State<SimilarMoviesTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  var startAppSdkMovieSimilars = StartAppSdk();
  StartAppBannerAd? bannerAdMovieSimilars;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getBannerADForMovieSimilars();
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        movieList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (movieList == null) {
        setState(() {
          requestFailed = true;
          movieList = [Movie()];
        });
      }
    });
  }

  void getBannerADForMovieSimilars() {
    startAppSdkMovieSimilars
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdMovieSimilars = bannerAd;
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

        var response = await http.get(Uri.parse(
            '$TMDB_API_BASE_URL/movie/${widget.movieId}/similar?api_key=$TMDB_API_KEY'
            '&language=en-US&include_adult=${widget.includeAdult}'
            '&page=$pageNum'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => Movie.fromJson(i))
              .toList();
          movieList!.addAll(newlistMovies);
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
    return movieList == null
        ? Container(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            child: detailsRecommendationsAndSimilarShimmer(
                isDark, _scrollController, bannerAdMovieSimilars, isLoading))
        : movieList!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('There are no similars available for this movie'),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: movieList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    mixpanel.track('Most viewed movie pages',
                                        properties: {
                                          'Movie name':
                                              '${movieList![index].originalTitle}',
                                          'Movie id': '${movieList![index].id}',
                                          'Is Movie adult?':
                                              '${movieList![index].adult}'
                                        });

                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MovieDetailPage(
                                        movie: movieList![index],
                                        heroId: '${movieList![index].id}',
                                      );
                                    }));
                                  },
                                  child: Container(
                                    color: isDark
                                        ? const Color(0xFF202124)
                                        : const Color(0xFFFFFFFF),
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
                                                    tag:
                                                        '${movieList![index].id}',
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: movieList![index]
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
                                                                  Curves
                                                                      .easeOut,
                                                              fadeInDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          700),
                                                              fadeInCurve:
                                                                  Curves.easeIn,
                                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                                  imageQuality +
                                                                  movieList![
                                                                          index]
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
                                                                  recommendationAndSimilarTabImageShimmer(
                                                                      isDark),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      movieList![index].title!,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                          fontSize: 15,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                        Text(
                                                          movieList![index]
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
                        Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )),
                        bannerAdMovieSimilars != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: StartAppBanner(
                                    bannerAdMovieSimilars!,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ));
  }

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      movieList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreMovies extends StatefulWidget {
  final String api;
  final int genreId;
  final bool? includeAdult;
  const ParticularGenreMovies(
      {Key? key,
      required this.api,
      required this.genreId,
      required this.includeAdult})
      : super(key: key);
  @override
  ParticularGenreMoviesState createState() => ParticularGenreMoviesState();
}

class ParticularGenreMoviesState extends State<ParticularGenreMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  var startAppSdkMovieGenre = StartAppSdk();
  StartAppBannerAd? bannerAdMovieGenre;
  bool requestFailed = false;

  void getBannerADForGenreMovie() {
    startAppSdkMovieGenre
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdMovieGenre = bannerAd;
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
            Uri.parse('$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
                '&language=en-US'
                '&sort_by=popularity.desc'
                '&include_adult=${widget.includeAdult}'
                '&include_video=false'
                '&watch_region=US'
                '&page=$pageNum'
                '&with_genres=${widget.genreId}'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => Movie.fromJson(i))
              .toList();
          moviesList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getBannerADForGenreMovie();
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [Movie()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return moviesList == null
        ? mainPageVerticalScrollShimmer(
            bannerAdMovieGenre, isDark, isLoading, _scrollController)
        : moviesList!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text('Oops! movies for this genre doesn\'t exist :('),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
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
                                      itemCount: moviesList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            mixpanel.track(
                                                'Most viewed movie pages',
                                                properties: {
                                                  'Movie name':
                                                      '${moviesList![index].originalTitle}',
                                                  'Movie id':
                                                      '${moviesList![index].id}',
                                                  'Is Movie adult?':
                                                      '${moviesList![index].adult}'
                                                });
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return MovieDetailPage(
                                                movie: moviesList![index],
                                                heroId:
                                                    '${moviesList![index].id}',
                                              );
                                            }));
                                          },
                                          child: Container(
                                            color: isDark
                                                ? const Color(0xFF202124)
                                                : const Color(0xFFFFFFFF),
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
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10.0),
                                                        child: SizedBox(
                                                          width: 85,
                                                          height: 130,
                                                          child: Hero(
                                                            tag:
                                                                '${moviesList![index].id}',
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              child: moviesList![
                                                                              index]
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
                                                                              milliseconds: 300),
                                                                      fadeOutCurve:
                                                                          Curves
                                                                              .easeOut,
                                                                      fadeInDuration:
                                                                          const Duration(
                                                                              milliseconds: 700),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .easeIn,
                                                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                                                          imageQuality +
                                                                          moviesList![index]
                                                                              .posterPath!,
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          mainPageVerticalScrollImageShimmer(
                                                                              isDark),
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
                                                              moviesList![index]
                                                                  .title!,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'PoppinsSB',
                                                                  fontSize: 15,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                const Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xFFF57C00)),
                                                                Text(
                                                                  moviesList![
                                                                          index]
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
                        bannerAdMovieGenre != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: StartAppBanner(
                                    bannerAdMovieGenre!,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ));
  }

  Widget retryWidget(isDark) {
    return Container(
      color: isDark ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
      child: Center(
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
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
                });
                getData();
              },
              child: const Text('Retry')),
        ],
      )),
    );
  }
}

class ParticularStreamingServiceMovies extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  const ParticularStreamingServiceMovies({
    Key? key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
  }) : super(key: key);
  @override
  ParticularStreamingServiceMoviesState createState() =>
      ParticularStreamingServiceMoviesState();
}

class ParticularStreamingServiceMoviesState
    extends State<ParticularStreamingServiceMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  var startAppSdkMovieProviders = StartAppSdk();
  StartAppBannerAd? bannerAdMovieProviders;
  bool requestFailed = false;

  void getBannerADForMovieProviders() {
    startAppSdkMovieProviders
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdMovieProviders = bannerAd;
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
            '/discover/movie?api_key='
            '$TMDB_API_KEY'
            '&language=en-US&sort_by=popularity'
            '.desc&include_adult=${widget.includeAdult}&include_video=false&page=$pageNum'
            '&with_watch_providers=${widget.providerID}'
            '&watch_region=US'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => Movie.fromJson(i))
              .toList();
          moviesList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getBannerADForMovieProviders();
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [Movie()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return moviesList == null
        ? Container(
            color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
            child: mainPageVerticalScrollShimmer(
                bannerAdMovieProviders, isDark, isLoading, _scrollController))
        : moviesList!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
                child: const Center(
                  child: Text(
                      'Oops! movies for this watch provider doesn\'t exist :('),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
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
                                      itemCount: moviesList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            mixpanel.track(
                                                'Most viewed movie pages',
                                                properties: {
                                                  'Movie name':
                                                      '${moviesList![index].originalTitle}',
                                                  'Movie id':
                                                      '${moviesList![index].id}',
                                                  'Is Movie adult?':
                                                      '${moviesList![index].adult}'
                                                });
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return MovieDetailPage(
                                                movie: moviesList![index],
                                                heroId:
                                                    '${moviesList![index].id}',
                                              );
                                            }));
                                          },
                                          child: Container(
                                            color: isDark
                                                ? const Color(0xFF202124)
                                                : const Color(0xFFFFFFFF),
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
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 10.0),
                                                        child: SizedBox(
                                                          width: 85,
                                                          height: 130,
                                                          child: Hero(
                                                            tag:
                                                                '${moviesList![index].id}',
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              child: moviesList![
                                                                              index]
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
                                                                              milliseconds: 300),
                                                                      fadeOutCurve:
                                                                          Curves
                                                                              .easeOut,
                                                                      fadeInDuration:
                                                                          const Duration(
                                                                              milliseconds: 700),
                                                                      fadeInCurve:
                                                                          Curves
                                                                              .easeIn,
                                                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                                                          imageQuality +
                                                                          moviesList![index]
                                                                              .posterPath!,
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          mainPageVerticalScrollImageShimmer(
                                                                              isDark),
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
                                                              moviesList![index]
                                                                  .title!,
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'PoppinsSB',
                                                                  fontSize: 15,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            ),
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                const Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xFFF57C00)),
                                                                Text(
                                                                  moviesList![
                                                                          index]
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
                        bannerAdMovieProviders != null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: StartAppBanner(
                                    bannerAdMovieProviders!,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ));
  }

  Widget retryWidget(isDark) {
    return Container(
      color: isDark ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
      child: Center(
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
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
                });
                getData();
              },
              child: const Text('Retry')),
        ],
      )),
    );
  }
}

class StreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const StreamingServicesWidget({
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
          return StreamingServicesMovies(
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
                child: Text(title, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenreListGrid extends StatefulWidget {
  final String api;
  const GenreListGrid({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  GenreListGridState createState() => GenreListGridState();
}

class GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<Genres>? genreList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchGenre(widget.api).then((value) {
      setState(() {
        genreList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (genreList == null) {
        setState(() {
          requestFailed = true;
          genreList = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Column(
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
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: genreList == null
                ? genreListGridShimmer(isDark)
                : requestFailed == true
                    ? retryWidget()
                    : Row(
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
                                        return GenreMovies(
                                            genres: genreList![index]);
                                      }));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 125,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF57C00),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Text(
                                          genreList![index].genreName!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget retryWidget() {
    return Center(
      child: Container(
          child: Row(
        children: [
          Image.asset('assets/images/network-signal.png',
              width: 50, height: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      genreList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          ),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TopButton extends StatefulWidget {
  final String buttonText;
  const TopButton({
    Key? key,
    required this.buttonText,
  }) : super(key: key);

  @override
  TopButtonState createState() => TopButtonState();
}

class TopButtonState extends State<TopButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0x26F57C00)),
            maximumSize: MaterialStateProperty.all(const Size(200, 60)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: Color(0xFFF57C00))))),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          widget.buttonText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class WatchProvidersButton extends StatefulWidget {
  final Function()? onTap;
  final String api;
  const WatchProvidersButton({
    Key? key,
    this.onTap,
    required this.api,
  }) : super(key: key);

  @override
  State<WatchProvidersButton> createState() => _WatchProvidersButtonState();
}

class _WatchProvidersButtonState extends State<WatchProvidersButton> {
  WatchProviders? watchProviders;
  @override
  void initState() {
    super.initState();
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0x26F57C00)),
            maximumSize: MaterialStateProperty.all(const Size(200, 60)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: Color(0xFFF57C00))))),
        onPressed: () {
          widget.onTap!();
        },
        child: const Text(
          'Watch providers',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class WatchProvidersDetails extends StatefulWidget {
  final String api;
  const WatchProvidersDetails({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<WatchProvidersDetails> createState() => _WatchProvidersDetailsState();
}

class _WatchProvidersDetailsState extends State<WatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;
  bool requestFailed = false;

  @override
  void initState() {
    super.initState();
    getData();
    tabController = TabController(length: 4, vsync: this);
  }

  void getData() {
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (watchProviders == null) {
        setState(() {
          requestFailed = true;
          watchProviders = WatchProviders();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    return requestFailed == true
        ? retryWidget(isDark)
        : Container(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2b2c30)
                        : const Color(0xFFDFDEDE),
                  ),
                  child: Center(
                    child: TabBar(
                      controller: tabController,
                      isScrollable: true,
                      indicatorColor: const Color(0xFFF57C00),
                      indicatorWeight: 3,
                      unselectedLabelColor: Colors.white54,
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
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: watchProviders == null
                        ? [
                            watchProvidersShimmer(isDark),
                            watchProvidersShimmer(isDark),
                            watchProvidersShimmer(isDark),
                            watchProvidersShimmer(isDark),
                          ]
                        : [
                            watchProvidersTabData(
                                isDark: isDark,
                                imageQuality: imageQuality,
                                noOptionMessage:
                                    'This movie doesn\'t have an option to buy yet',
                                watchOptions: watchProviders!.buy),
                            watchProvidersTabData(
                                isDark: isDark,
                                imageQuality: imageQuality,
                                noOptionMessage:
                                    'This movie doesn\'t have an option to stream yet',
                                watchOptions: watchProviders!.flatRate),
                            watchProvidersTabData(
                                isDark: isDark,
                                imageQuality: imageQuality,
                                noOptionMessage:
                                    'This movie doesn\'t have an option to rent yet',
                                watchOptions: watchProviders!.rent),
                            Container(
                              color: isDark
                                  ? const Color(0xFF202124)
                                  : const Color(0xFFF7F7F7),
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
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

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
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
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      watchProviders = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }
}

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({Key? key}) : super(key: key);

  @override
  MoviesFromWatchProvidersState createState() =>
      MoviesFromWatchProvidersState();
}

class MoviesFromWatchProvidersState extends State<MoviesFromWatchProviders> {
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
                      StreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      StreamingServicesWidget(
                          imagePath: 'assets/images/disney_plus.png',
                          title: 'Disney plus',
                          providerID: 337),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      StreamingServicesWidget(
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

class CollectionMovies extends StatefulWidget {
  final String? api;
  const CollectionMovies({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  CollectionMoviesState createState() => CollectionMoviesState();
}

class CollectionMoviesState extends State<CollectionMovies> {
  List<Movie>? moviesList;
  @override
  void initState() {
    super.initState();
    fetchCollectionMovies(widget.api!).then((value) {
      setState(() {
        moviesList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Container(
      color: const Color(0xFF202124),
      child: moviesList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : moviesList!.isEmpty
              ? const Center(
                  child: Text(
                    'Oops! movies for this watch provider doesn\'t exist :(',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: moviesList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              mixpanel.track('Most viewed movie pages',
                                  properties: {
                                    'Movie name':
                                        '${moviesList![index].originalTitle}',
                                    'Movie id': '${moviesList![index].id}',
                                    'Is Movie adult?':
                                        '${moviesList![index].adult}'
                                  });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId: '${moviesList![index].id}')));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${moviesList![index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: moviesList![index]
                                                        .posterPath ==
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
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 700),
                                                    fadeInCurve: Curves.easeIn,
                                                    imageUrl:
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            moviesList![index]
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
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                moviesList![index].title!,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    moviesList![index]
                                                        .voteAverage!
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  const Icon(Icons.star,
                                                      color: Color(0xFFF57C00)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
