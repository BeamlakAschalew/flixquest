// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:startapp_sdk/startapp.dart';
import '../constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../provider/adultmode_provider.dart';
import '../provider/imagequality_provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/movie.dart';
import '/screens/movie_widgets.dart';
import 'package:intl/intl.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.heroId,
  }) : super(key: key);
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MovieDetailPage> {
  late TabController tabController;
  var startAppSdkMovieDetail = StartAppSdk();
  var startAppSdkMovieDetail1 = StartAppSdk();
  StartAppBannerAd? bannerAdMovieDetail;
  StartAppBannerAd? bannerAdMovieDetail1;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    getBannerADForMovieDetail();
  }

  void getBannerADForMovieDetail() {
    startAppSdkMovieDetail
        .loadBannerAd(StartAppBannerType.BANNER)
        .then((bannerAd) {
      setState(() {
        bannerAdMovieDetail = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdkMovieDetail1
        .loadBannerAd(StartAppBannerType.BANNER)
        .then((bannerAd) {
      setState(() {
        bannerAdMovieDetail1 = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    super.build(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    widget.movie.backdropPath == null
                        ? Image.asset(
                            'assets/images/na_logo.png',
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeOutCurve: Curves.easeOut,
                            fadeInDuration: const Duration(milliseconds: 700),
                            fadeInCurve: Curves.easeIn,
                            imageUrl:
                                '${TMDB_BASE_IMAGE_URL}original/${widget.movie.backdropPath!}',
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Image.asset(
                              'assets/images/loading_5.gif',
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/na_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.bottomCenter,
                              end: FractionalOffset.topCenter,
                              colors: [
                                const Color(0xFFF57C00),
                                const Color(0xFFF57C00).withOpacity(0.3),
                                const Color(0xFFF57C00).withOpacity(0.2),
                                const Color(0xFFF57C00).withOpacity(0.1),
                              ],
                              stops: const [
                                0.0,
                                0.25,
                                0.5,
                                0.75
                              ])),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF57C00),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: isDark ? Colors.black38 : Colors.white38),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFFF57C00)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    child: WatchProvidersButton(
                      api: Endpoints.getMovieWatchProviders(widget.movie.id!),
                      onTap: () {
                        modalBottomSheetMenu();
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: isDark
                                ? const Color(0xFF2b2c30)
                                : const Color(0xFFDFDEDE),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 120.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          widget.movie.releaseDate == ""
                                              ? widget.movie.title!
                                              : '${widget.movie.title!} (${DateTime.parse(widget.movie.releaseDate!).year})',
                                          style: kTextSmallHeaderStyle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: Image.asset(
                                                        'assets/images/tmdb_logo.png'),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8.0,
                                                                    right: 3.0),
                                                            child: Icon(
                                                              Icons.star,
                                                              size: 15,
                                                              color: Color(
                                                                  0xFFF57C00),
                                                            ),
                                                          ),
                                                          Text(
                                                            widget.movie
                                                                .voteAverage!
                                                                .toStringAsFixed(
                                                                    1),
                                                            // style: widget.themeData
                                                            //     .textTheme.bodyText1,
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Row(
                                                          children: [
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          8.0),
                                                              child: Icon(
                                                                  Icons
                                                                      .people_alt,
                                                                  size: 15),
                                                            ),
                                                            Text(
                                                              widget.movie
                                                                  .voteCount!
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          10),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TabBar(
                                  isScrollable: true,
                                  indicatorColor: const Color(0xFFF57C00),
                                  indicatorWeight: 3,
                                  tabs: [
                                    Tab(
                                      child: Text('About',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Cast',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Crew',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Recommendations',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                    Tab(
                                      child: Text('Similar',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ],
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        1.6, 0, 1.6, 3),
                                    child: TabBarView(
                                      physics: const PageScrollPhysics(),
                                      controller: tabController,
                                      children: [
                                        SingleChildScrollView(
                                          // physics: const BouncingScrollPhysics(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: isDark
                                                    ? const Color(0xFF202124)
                                                    : const Color(0xFFFFFFFF),
                                                borderRadius: const BorderRadius
                                                        .only(
                                                    bottomLeft:
                                                        Radius.circular(8.0),
                                                    bottomRight:
                                                        Radius.circular(8.0))),
                                            child: Column(
                                              children: <Widget>[
                                                GenreDisplay(
                                                  api:
                                                      Endpoints.movieDetailsUrl(
                                                          widget.movie.id!),
                                                ),
                                                Row(
                                                  children: const <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8.0),
                                                      child: Text(
                                                        'Overview',
                                                        style: kTextHeaderStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: widget.movie.overview!
                                                          .isEmpty
                                                      ? const Text(
                                                          'There is no overview for this movie')
                                                      : ReadMoreText(
                                                          widget
                                                              .movie.overview!,
                                                          trimLines: 4,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins'),
                                                          colorClickableText:
                                                              const Color(
                                                                  0xFFF57C00),
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              'read more',
                                                          trimExpandedText:
                                                              'read less',
                                                          lessStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFFF57C00),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          moreStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFFF57C00),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              bottom: 4.0),
                                                      child: Text(
                                                        widget.movie.releaseDate ==
                                                                    null ||
                                                                widget
                                                                    .movie
                                                                    .releaseDate!
                                                                    .isEmpty
                                                            ? 'Release date: N/A'
                                                            : 'Release date : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'PoppinsSB'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                WatchNowButton(
                                                  movieId: widget.movie.id!,
                                                  movieName: widget
                                                      .movie.originalTitle,
                                                  adult: widget.movie.adult,
                                                  api:
                                                      Endpoints.movieDetailsUrl(
                                                          widget.movie.id!),
                                                ),
                                                bannerAdMovieDetail != null
                                                    ? StartAppBanner(
                                                        bannerAdMovieDetail!)
                                                    : Container(),
                                                ScrollingArtists(
                                                  api: Endpoints.getCreditsUrl(
                                                      widget.movie.id!),
                                                  title: 'Cast',
                                                ),
                                                MovieImagesDisplay(
                                                  title: 'Images',
                                                  api: Endpoints.getImages(
                                                      widget.movie.id!),
                                                ),
                                                bannerAdMovieDetail1 != null
                                                    ? StartAppBanner(
                                                        bannerAdMovieDetail1!)
                                                    : Container(),
                                                MovieVideosDisplay(
                                                  api: Endpoints.getVideos(
                                                      widget.movie.id!),
                                                  title: 'Videos',
                                                ),
                                                MovieSocialLinks(
                                                  api: Endpoints
                                                      .getExternalLinksForMovie(
                                                    widget.movie.id!,
                                                  ),
                                                ),
                                                BelongsToCollectionWidget(
                                                  api:
                                                      Endpoints.movieDetailsUrl(
                                                          widget.movie.id!),
                                                ),
                                                MovieInfoTable(
                                                  api:
                                                      Endpoints.movieDetailsUrl(
                                                          widget.movie.id!),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        CastTab(
                                          api: Endpoints.getCreditsUrl(
                                              widget.movie.id!),
                                        ),
                                        CrewTab(
                                          api: Endpoints.getCreditsUrl(
                                              widget.movie.id!),
                                        ),
                                        MovieRecommendationsTab(
                                          includeAdult:
                                              Provider.of<AdultmodeProvider>(
                                                      context)
                                                  .isAdult,
                                          api:
                                              Endpoints.getMovieRecommendations(
                                                  widget.movie.id!, 1),
                                          movieId: widget.movie.id!,
                                        ),
                                        SimilarMoviesTab(
                                            includeAdult:
                                                Provider.of<AdultmodeProvider>(
                                                        context)
                                                    .isAdult,
                                            movieId: widget.movie.id!,
                                            api: Endpoints.getSimilarMovies(
                                                widget.movie.id!, 1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 40,
                        child: Hero(
                          tag: widget.heroId,
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: widget.movie.posterPath == null
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
                                          widget.movie.posterPath!,
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
                                          Image.asset(
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
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void modalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return WatchProvidersDetails(
          api: Endpoints.getMovieWatchProviders(widget.movie.id!),
        );
      },
    );
  }
}
