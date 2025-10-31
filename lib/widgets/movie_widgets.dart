// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/services/globle_method.dart';
import '../models/movie_stream_metadata.dart';
import '/provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/recently_watched.dart';
import '../provider/recently_watched_provider.dart';
import '../screens/common/update_screen.dart';
import '../screens/movie/movie_castandcrew.dart';
import '../screens/movie/movie_video_loader.dart';
import '../ui_components/movie_ui_components.dart';
import '/models/dropdown_select.dart';
import '/models/filter_chip.dart';
import '/screens/common/photoview.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:readmore/readmore.dart';
import '../controllers/bookmark_database_controller.dart';
import '../provider/settings_provider.dart';
import '/constants/app_constants.dart';
import '/models/social_icons_icons.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import '/screens/person/cast_detail.dart';
import '/screens/movie/streaming_services_movies.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../functions/network.dart';
import '/models/movie.dart';
import '/api/endpoints.dart';
import '/models/genres.dart';
import '/constants/api_constants.dart';
import '/screens/movie/movie_detail.dart';
import '/models/credits.dart';
import '/screens/movie/collection_detail.dart';
import '/screens/person/crew_detail.dart';
import '/models/images.dart';
import 'package:url_launcher/url_launcher.dart';
import '/screens/movie/genremovies.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/screens/movie/main_movies_list.dart';
import 'package:provider/provider.dart';
import 'common_widgets.dart';

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({
    super.key,
  });

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay> {
  @override
  Widget build(BuildContext context) {
    bool includeAdult = Provider.of<SettingsProvider>(context).isAdult;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    var rMovies = Provider.of<RecentProvider>(context).movies;
    return Container(
      child: ListView(
        children: [
          DiscoverMovies(includeAdult: includeAdult, discoverType: 'discover'),
          const UpdateBottom(),
          ScrollingMovies(
            title: tr('popular'),
            api: Endpoints.popularMoviesUrl(lang),
            discoverType: 'popular',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          rMovies.isEmpty
              ? Container()
              : ScrollingRecentMovies(moviesList: rMovies),
          ScrollingMovies(
            title: tr('trending_this_week'),
            api: Endpoints.trendingMoviesUrl(includeAdult, lang),
            discoverType: 'Trending',
            isTrending: true,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('top_rated'),
            api: Endpoints.topRatedUrl(lang),
            discoverType: 'top_rated',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('now_playing'),
            api: Endpoints.nowPlayingMoviesUrl(1, lang),
            discoverType: 'now_playing',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          ScrollingMovies(
            title: tr('upcoming'),
            api: Endpoints.upcomingMoviesUrl(lang),
            discoverType: 'upcoming',
            isTrending: false,
            includeAdult: includeAdult,
          ),
          GenreListGrid(api: Endpoints.movieGenresUrl(lang)),
          const MoviesFromWatchProviders(),
        ],
      ),
    );
  }
}

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies(
      {super.key, required this.includeAdult, required this.discoverType});
  final bool includeAdult;
  final String discoverType;
  @override
  DiscoverMoviesState createState() => DiscoverMoviesState();
}

class DiscoverMoviesState extends State<DiscoverMovies>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  late double deviceHeight;
  YearDropdownData yearDropdownData = YearDropdownData();
  @override
  void initState() {
    super.initState();
    getData();
  }

  List<MovieGenreFilterChipWidget> movieGenreFilterdata =
      <MovieGenreFilterChipWidget>[
    MovieGenreFilterChipWidget(genreName: tr('action'), genreValue: '28'),
    MovieGenreFilterChipWidget(genreName: tr('adventure'), genreValue: '12'),
    MovieGenreFilterChipWidget(genreName: tr('animation'), genreValue: '16'),
    MovieGenreFilterChipWidget(genreName: tr('comedy'), genreValue: '35'),
    MovieGenreFilterChipWidget(genreName: tr('crime'), genreValue: '80'),
    MovieGenreFilterChipWidget(genreName: tr('documentary'), genreValue: '99'),
    MovieGenreFilterChipWidget(genreName: tr('drama'), genreValue: '18'),
    MovieGenreFilterChipWidget(genreName: tr('family'), genreValue: '10751'),
    MovieGenreFilterChipWidget(genreName: tr('fantasy'), genreValue: '14'),
    MovieGenreFilterChipWidget(genreName: tr('history'), genreValue: '36'),
    MovieGenreFilterChipWidget(genreName: tr('horror'), genreValue: '27'),
    MovieGenreFilterChipWidget(genreName: tr('music'), genreValue: '10402'),
    MovieGenreFilterChipWidget(genreName: tr('mystery'), genreValue: '9648'),
    MovieGenreFilterChipWidget(genreName: tr('romance'), genreValue: '10749'),
    MovieGenreFilterChipWidget(
        genreName: tr('science_fiction'), genreValue: '878'),
    MovieGenreFilterChipWidget(genreName: tr('tv_movie'), genreValue: '10770'),
    MovieGenreFilterChipWidget(genreName: tr('thriller'), genreValue: '53'),
    MovieGenreFilterChipWidget(genreName: tr('war'), genreValue: '10752'),
    MovieGenreFilterChipWidget(genreName: tr('western'), genreValue: '37'),
  ];

  void getData() {
    List<String> years = yearDropdownData.yearsList.getRange(1, 26).toList();
    List<MovieGenreFilterChipWidget> genres = movieGenreFilterdata;
    years.shuffle();
    genres.shuffle();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies(
            '$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&include_adult=${widget.includeAdult}&primary_release_year=${years.first}&with_genres=${genres.first.genreValue}',
            isProxyEnabled,
            proxyUrl)
        .then((value) async {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr('featured_movies'),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 350,
          // height: deviceHeight * 0.417,
          child: moviesList == null
              ? discoverMoviesAndTVShimmer(themeMode)
              : moviesList!.isEmpty
                  ? Center(
                      child: Text(
                        tr('wow_odd'),
                        style: kTextSmallBodyStyle,
                      ),
                    )
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId:
                                              '${moviesList![index].id}-${widget.discoverType}')));
                            },
                            child: Hero(
                              tag:
                                  '${moviesList![index].id}-${widget.discoverType}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  cacheManager: cacheProp(),
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl:
                                      moviesList![index].posterPath == null
                                          ? ''
                                          : buildImageUrl(
                                                  TMDB_BASE_IMAGE_URL,
                                                  proxyUrl,
                                                  isProxyEnabled,
                                                  context) +
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
                                      discoverImageShimmer(themeMode),
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

  @override
  bool get wantKeepAlive => true;
}

class ScrollingMovies extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;
  final bool? includeAdult;

  const ScrollingMovies({
    super.key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
    required this.includeAdult,
  });
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

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
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
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(widget.title,
                          style: kTextHeaderStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainMoviesList(
                        title: widget.title,
                        api: widget.api,
                        includeAdult: widget.includeAdult,
                        discoverType: widget.discoverType.toString(),
                        isTrending: widget.isTrending,
                      );
                    }));
                  },
                  style: ButtonStyle(
                      maximumSize: WidgetStateProperty.all(const Size(200, 60)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(tr('view_all')),
                  ),
                )),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: moviesList == null || widget.includeAdult == null
              ? scrollingMoviesAndTVShimmer(themeMode)
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieDetailPage(
                                            movie: moviesList![index],
                                            heroId:
                                                '${moviesList![index].id}${widget.title}-${widget.discoverType}')));
                              },
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${moviesList![index].id}${widget.title}-${widget.discoverType}',
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: moviesList![index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity)
                                                    : CachedNetworkImage(
                                                        cacheManager:
                                                            cacheProp(),
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
                                                        imageUrl: moviesList![
                                                                        index]
                                                                    .posterPath ==
                                                                null
                                                            ? ''
                                                            : buildImageUrl(
                                                                    TMDB_BASE_IMAGE_URL,
                                                                    proxyUrl,
                                                                    isProxyEnabled,
                                                                    context) +
                                                                imageQuality +
                                                                moviesList![
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
                                                        placeholder: (context,
                                                                url) =>
                                                            scrollingImageShimmer(
                                                                themeMode),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity),
                                                      ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(3),
                                                  alignment: Alignment.topLeft,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 3),
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color:
                                                          themeMode == 'dark' ||
                                                                  themeMode ==
                                                                      'amoled'
                                                              ? Colors.black45
                                                              : Colors.white60),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                      ),
                                                      Text(moviesList![index]
                                                                      .voteAverage! %
                                                                  1 ==
                                                              0
                                                          ? moviesList![index]
                                                              .voteAverage!
                                                              .toInt()
                                                              .toString()
                                                          : moviesList![index]
                                                              .voteAverage!
                                                              .toStringAsFixed(
                                                                  1))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
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
                        child: horizontalLoadMoreShimmer(themeMode),
                      ),
                    ),
                  ],
                ),
        ),
        Divider(
          color: themeMode == 'light' ? Colors.black54 : Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingRecentMovies extends StatefulWidget {
  const ScrollingRecentMovies({required this.moviesList, super.key});

  final List<RecentMovie> moviesList;

  @override
  State<ScrollingRecentMovies> createState() => _ScrollingRecentMoviesState();
}

class _ScrollingRecentMoviesState extends State<ScrollingRecentMovies> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr('recently_watched'),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: TextButton(
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) {
            //           return const MovieVideoLoader(
            //               download: false, metadata: []);
            //         }));
            //       },
            //       style: ButtonStyle(
            //           maximumSize:
            //               WidgetStateProperty.all(const Size(200, 60)),
            //           shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            //               RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(20.0),
            //           ))),
            //       child: const Padding(
            //         padding: EdgeInsets.only(left: 8.0, right: 8.0),
            //         child: Text('View all'),
            //       ),
            //     )),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.moviesList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final prv =
                        Provider.of<RecentProvider>(context, listen: false);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          prv.deleteMovie(widget.moviesList[index].id!);
                        },
                        onTap: () async {
                          await checkConnection().then((value) {
                            value
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieVideoLoader(
                                            download: false,
                                            /* return to fetchRoute instead of hard text*/ route:
                                                fetchRoute == 'flixHQ'
                                                    ? StreamRoute.flixHQ
                                                    : StreamRoute.tmDB,
                                            metadata: MovieStreamMetadata(
                                                backdropPath: widget
                                                    .moviesList[index]
                                                    .backdropPath,
                                                elapsed: widget
                                                    .moviesList[index].elapsed,
                                                isAdult: null,
                                                movieId:
                                                    widget.moviesList[index].id,
                                                movieName: widget
                                                    .moviesList[index].title,
                                                posterPath: widget
                                                    .moviesList[index]
                                                    .posterPath,
                                                releaseYear: widget
                                                    .moviesList[index]
                                                    .releaseYear,
                                                releaseDate: null))))
                                : GlobalMethods.showCustomScaffoldMessage(
                                    SnackBar(
                                      content: Text(
                                        tr('check_connection'),
                                        maxLines: 3,
                                        style: kTextSmallBodyStyle,
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                    context);
                          });
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Material(
                                type: MaterialType.transparency,
                                child: SizedBox(
                                  height: 155,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: widget.moviesList[index]
                                                    .posterPath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_logo.png',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity)
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: widget
                                                            .moviesList[index]
                                                            .posterPath ==
                                                        null
                                                    ? ''
                                                    : buildImageUrl(
                                                            TMDB_BASE_IMAGE_URL,
                                                            proxyUrl,
                                                            isProxyEnabled,
                                                            context) +
                                                        imageQuality +
                                                        widget.moviesList[index]
                                                            .posterPath!,
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
                                                    scrollingImageShimmer(
                                                        themeMode),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height:
                                                            double.infinity),
                                              ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          child: LinearProgressIndicator(
                                            value: (widget.moviesList[index]
                                                    .elapsed! /
                                                (widget.moviesList[index]
                                                        .remaining! +
                                                    widget.moviesList[index]
                                                        .elapsed!)),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -15,
                                        right: 8,
                                        child: Container(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              alignment: Alignment.topRight,
                                              onPressed: () async {
                                                prv.deleteMovie(widget
                                                    .moviesList[index].id!);
                                              },
                                              icon: const Icon(
                                                  Icons.bookmark_remove,
                                                  size: 60),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.moviesList[index].title!,
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
        Divider(
          color: themeMode == 'light' ? Colors.black54 : Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}

class SABTN extends StatefulWidget {
  final void Function()? onBack;

  const SABTN({super.key, this.onBack});

  @override
  // ignore: library_private_types_in_public_api
  _SABTNState createState() => _SABTNState();
}

class _SABTNState extends State<SABTN> {
  ScrollPosition? _position;
  bool? _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context).position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1,
      curve: Curves.easeIn,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: themeMode == 'dark' || themeMode == 'amoled'
                  ? Colors.black12
                  : Colors.white38),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

class SABT extends StatefulWidget {
  final Widget child;

  const SABT({
    required this.child,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SABTState createState() => _SABTState();
}

class _SABTState extends State<SABT> {
  ScrollPosition? _position;
  bool? _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context).position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible!,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1,
        curve: Curves.easeIn,
        child: widget.child,
      ),
    );
  }
}

class MovieDetailQuickInfo extends StatelessWidget {
  const MovieDetailQuickInfo({
    super.key,
    required this.movie,
    required this.heroId,
  });

  final Movie movie;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final watchCountry = Provider.of<SettingsProvider>(context).defaultCountry;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 310,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.black,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.transparent)),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemBuilder: (context, index) {
                              return movie.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/loading_5.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl:
                                          '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context)}original/${movie.backdropPath!}',
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    );
                            },
                          ),
                          Positioned(
                            top: -10,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SafeArea(
                              child: Container(
                                alignment: appLang == 'ar'
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                child: GestureDetector(
                                  child: WatchProvidersButton(
                                    api: Endpoints.getMovieWatchProviders(
                                        movie.id!, appLang),
                                    country: watchCountry,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (builder) {
                                          return WatchProvidersDetails(
                                            api: Endpoints
                                                .getMovieWatchProviders(
                                                    movie.id!, appLang),
                                            country: watchCountry,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // poster and title movie details
          Positioned(
            bottom: 0.0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // poster
                  Hero(
                    tag: heroId,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 94,
                                height: 140,
                                child: movie.posterPath == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            scrollingImageShimmer(themeMode),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                        imageUrl: buildImageUrl(
                                                TMDB_BASE_IMAGE_URL,
                                                proxyUrl,
                                                isProxyEnabled,
                                                context) +
                                            imageQuality +
                                            movie.posterPath!,
                                      ),
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(width: 16),
                  //  titles
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            // _utilityController.toggleTitleVisibility();
                          },
                          child: Text(
                            movie.releaseDate == null
                                ? movie.title!
                                : movie.releaseDate == ''
                                    ? movie.title!
                                    : '${movie.title!} (${DateTime.parse(movie.releaseDate!).year})',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontFamily: 'FigtreeSB'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailOptions extends StatefulWidget {
  const MovieDetailOptions({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailOptions> createState() => _MovieDetailOptionsState();
}

class _MovieDetailOptionsState extends State<MovieDetailOptions> {
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  bool visible = false;
  bool? isBookmarked;

  @override
  void initState() {
    bookmarkChecker();
    super.initState();
  }

  void bookmarkChecker() async {
    var iB = await movieDatabaseController.contain(widget.movie.id!);
    if (mounted) {
      setState(() {
        isBookmarked = iB;
      });
    }
    if (isBookmarked == true) {
      movieDatabaseController.updateMovie(widget.movie, widget.movie.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user score circle percent indicator
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularPercentIndicator(
                    radius: 30,
                    percent: (widget.movie.voteAverage! / 10),
                    curve: Curves.ease,
                    animation: true,
                    animationDuration: 2500,
                    progressColor: Theme.of(context).colorScheme.primary,
                    center: Text(
                      '${widget.movie.voteAverage!.toStringAsFixed(1).endsWith('0') ? widget.movie.voteAverage!.toStringAsFixed(0) : widget.movie.voteAverage!.toStringAsFixed(1)}/10',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr('rating'),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                // height: 46,
                // width: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.movie.voteCount!.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tr('total_ratings'),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 8),
            child: Container(
              child: ElevatedButton(
                  onPressed: () {
                    if (isBookmarked == false) {
                      movieDatabaseController.insertMovie(widget.movie);
                      if (mounted) {
                        setState(() {
                          isBookmarked = true;
                        });
                      }
                    } else if (isBookmarked == true) {
                      movieDatabaseController.deleteMovie(widget.movie.id!);
                      if (mounted) {
                        setState(() {
                          isBookmarked = false;
                        });
                      }
                    }
                  },
                  child: Row(
                    children: [
                      isBookmarked == false
                          ? const Icon(Icons.bookmark_add)
                          : const Icon(Icons.bookmark_remove),
                      Visibility(
                          visible: visible,
                          child: const CircularProgressIndicator())
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

class MovieAbout extends StatefulWidget {
  const MovieAbout({required this.movie, super.key});
  final Movie movie;

  @override
  State<MovieAbout> createState() => _MovieAboutState();
}

class _MovieAboutState extends State<MovieAbout> {
  bool? isVisible = false;
  double? buttonWidth = 150;
  late AppDependencyProvider appDependency =
      Provider.of<AppDependencyProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            GenreDisplay(
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const LeadingDot(),
                        Expanded(
                          child: Text(
                            tr('overview'),
                            style: kTextHeaderStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.movie.overview == null ||
                      widget.movie.overview!.isEmpty
                  ? Text(tr('no_overview_movie'))
                  : ReadMoreText(
                      widget.movie.overview!,
                      trimLines: 4,
                      style: const TextStyle(fontFamily: 'Figtree'),
                      colorClickableText: Theme.of(context).colorScheme.primary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: tr('read_more'),
                      trimExpandedText: tr('read_less'),
                      lessStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                      moreStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, bottom: 4.0, right: 8.0),
                    child: Text(
                      widget.movie.releaseDate == null ||
                              widget.movie.releaseDate!.isEmpty
                          ? tr('no_release_date')
                          : '${tr("release_date")} : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                      style: const TextStyle(fontFamily: 'FigtreeSB'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.movie.releaseDate!.isNotEmpty &&
                        appDependency.displayWatchNowButton
                    ? WatchNowButton(
                        releaseYear:
                            DateTime.parse(widget.movie.releaseDate!).year,
                        movieId: widget.movie.id!,
                        movieName: widget.movie.title,
                        adult: widget.movie.adult,
                        posterPath: widget.movie.posterPath,
                        backdropPath: widget.movie.backdropPath,
                        api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
                        releaseDate: widget.movie.releaseDate,
                      )
                    : Container()
                // const SizedBox(
                //   width: 15,
                // ),
                // DownloadMovie(
                //   releaseYear: DateTime.parse(widget.movie.releaseDate!).year,
                //   movieId: widget.movie.id!,
                //   movieName: widget.movie.title,
                //   adult: widget.movie.adult,
                //   thumbnail: widget.movie.backdropPath,
                //   api: Endpoints.movieDetailsUrl(widget.movie.id!),
                // )
              ],
            ),
            const SizedBox(height: 15),
            ScrollingArtists(
              api: Endpoints.getCreditsUrl(widget.movie.id!, lang),
              title: tr('cast'),
            ),
            MovieImagesDisplay(
              title: tr('images'),
              api: Endpoints.getImages(widget.movie.id!),
              name: widget.movie.title,
            ),
            MovieVideosDisplay(
              api: Endpoints.getVideos(widget.movie.id!),
              title: tr('videos'),
            ),
            MovieSocialLinks(
              api: Endpoints.getExternalLinksForMovie(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            BelongsToCollectionWidget(
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            MovieInfoTable(
              api: Endpoints.movieDetailsUrl(widget.movie.id!, lang),
            ),
            const SizedBox(
              height: 10,
            ),
            MovieRecommendationsTab(
              includeAdult: Provider.of<SettingsProvider>(context).isAdult,
              api: Endpoints.getMovieRecommendations(widget.movie.id!, 1, lang),
              movieId: widget.movie.id!,
            ),
            SimilarMoviesTab(
                movieName: widget.movie.title!,
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                movieId: widget.movie.id!,
                api: Endpoints.getSimilarMovies(widget.movie.id!, 1, lang)),
            // DidYouKnow(
            //   api: Endpoints.getExternalLinksForMovie(
            //     widget.movie.id!,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class DownloadMovie extends StatelessWidget {
  const DownloadMovie({
    super.key,
    required this.adult,
    required this.api,
    required this.movieId,
    this.movieImdbId,
    required this.movieName,
    required this.releaseYear,
    required this.thumbnail,
  });

  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    bool? isVisible = false;
    double? buttonWidth = 150;
    return Container(
      child: TextButton(
        style: ButtonStyle(
          maximumSize: WidgetStateProperty.all(Size(buttonWidth, 50)),
        ).copyWith(
            backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.primary,
        )),
        onPressed: () async {
          // await checkConnection().then((value) {
          //   value
          //       ? Navigator.push(context,
          //           MaterialPageRoute(builder: ((context) {
          //           return MovieVideoLoader(
          //             download: true,
          //             route: fetchRoute == "flixHQ"
          //                 ? StreamRoute.flixHQ
          //                 : StreamRoute.tmDB,
          //             metadata: [
          //               movieId,
          //               movieName,
          //               thumbnail,
          //               releaseYear,
          //               0.0
          //             ],
          //           );
          //         })))
          //       : ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(
          //               tr("check_connection"),
          //               maxLines: 3,
          //               style: kTextSmallBodyStyle,
          //             ),
          //             duration: const Duration(seconds: 3),
          //           ),
          //         );
          // });
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.download_rounded,
                color: Colors.white,
              ),
            ),
            Text(
              tr('download'),
              style: const TextStyle(color: Colors.white),
            ),
            Visibility(
              visible: isVisible,
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

class ScrollingArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingArtists({
    super.key,
    this.api,
    this.title,
    this.tapButtonText,
  });
  @override
  ScrollingArtistsState createState() => ScrollingArtistsState();
}

class ScrollingArtistsState extends State<ScrollingArtists> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCredits(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        credits == null
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(
                              tr('cast'),
                              style: kTextHeaderStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : credits!.cast!.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const LeadingDot(),
                            Expanded(
                              child: Text(
                                tr('cast'),
                                style: kTextHeaderStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                          child: Text(tr('no_cast_movie'),
                              textAlign: TextAlign.center)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr('cast'),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (credits != null) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MovieCastAndCrew(credits: credits!);
                            }));
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          maximumSize:
                              WidgetStateProperty.all(const Size(200, 60)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                        child: Text(tr('see_all_cast_crew')),
                      )
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? detailCastShimmer(themeMode)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.cast!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                              cast: credits!.cast![index],
                              heroId: '${credits!.cast![index].id}'
                                  '${credits!.cast![index].creditId}',
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
                                              'assets/images/na_rect.png',
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              cacheManager: cacheProp(),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: buildImageUrl(
                                                      TMDB_BASE_IMAGE_URL,
                                                      proxyUrl,
                                                      isProxyEnabled,
                                                      context) +
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
                                                      themeMode),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_rect.png',
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
    super.key,
    this.api,
  });

  @override
  MovieSocialLinksState createState() => MovieSocialLinksState();
}

class MovieSocialLinksState extends State<MovieSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchSocialLinks(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('social_media_links'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? socialMediaShimmer(themeMode)
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            tr('no_social_link_movie'),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: themeMode == 'dark' || themeMode == 'amoled'
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
    super.key,
    this.api,
  });

  @override
  BelongsToCollectionWidgetState createState() =>
      BelongsToCollectionWidgetState();
}

class BelongsToCollectionWidgetState extends State<BelongsToCollectionWidget> {
  BelongsToCollection? belongsToCollection;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchBelongsToCollection(widget.api!, isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          belongsToCollection = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return belongsToCollection == null
        ? ShimmerBase(
            themeMode: themeMode,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.grey.shade600,
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
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
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
                                          'assets/images/loading_5.gif'),
                                      image: NetworkImage(
                                          '${buildImageUrl(TMDB_BASE_IMAGE_URL, proxyUrl, isProxyEnabled, context)}w500/${belongsToCollection!.backdropPath!}')),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      tr('belongs_to_the', namedArgs: {
                                        'collection': belongsToCollection!.name!
                                      }),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.3),
                                          ),
                                          maximumSize: WidgetStateProperty.all(
                                              const Size(200, 40)),
                                          shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )))),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CollectionDetailsWidget(
                                              belongsToCollection:
                                                  belongsToCollection!);
                                        }));
                                      },
                                      child: Text(
                                        tr('view_collection'),
                                        style: const TextStyle(
                                            color: Colors.white),
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
  const CollectionOverviewWidget({super.key, this.api});

  @override
  CollectionOverviewWidgetState createState() =>
      CollectionOverviewWidgetState();
}

class CollectionOverviewWidgetState extends State<CollectionOverviewWidget> {
  CollectionDetails? collectionDetails;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionDetails(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          collectionDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Container(
      child: collectionDetails == null
          ? ShimmerBase(
              themeMode: themeMode,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                        color: Colors.grey.shade600,
                        width: double.infinity,
                        height: 20),
                  ),
                  Container(
                      color: Colors.grey.shade600,
                      width: double.infinity,
                      height: 20)
                ],
              ),
            )
          : Text(collectionDetails!.overview!),
    );
  }
}

class PartsList extends StatefulWidget {
  final String? api;
  final String? title;
  const PartsList({super.key, this.api, this.title});

  @override
  PartsListState createState() => PartsListState();
}

class PartsListState extends State<PartsList> {
  List<Movie>? collectionMovieList;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionMovies(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          collectionMovieList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
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
                      child: ShimmerBase(
                        themeMode: themeMode,
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
                                          color: Colors.grey.shade600,
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
                                              color: Colors.grey.shade600),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieDetailPage(
                                            movie: collectionMovieList![index],
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
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: collectionMovieList![
                                                                index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity)
                                                    : CachedNetworkImage(
                                                        cacheManager:
                                                            cacheProp(),
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
                                                        imageUrl: buildImageUrl(
                                                                TMDB_BASE_IMAGE_URL,
                                                                proxyUrl,
                                                                isProxyEnabled,
                                                                context) +
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
                                                        placeholder: (context,
                                                                url) =>
                                                            scrollingImageShimmer(
                                                                themeMode),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity),
                                                      ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(3),
                                                  alignment: Alignment.topLeft,
                                                  width: 50,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color:
                                                          themeMode == 'dark' ||
                                                                  themeMode ==
                                                                      'amoled'
                                                              ? Colors.black45
                                                              : Colors.white60),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                      ),
                                                      Text(collectionMovieList![
                                                              index]
                                                          .voteAverage!
                                                          .toStringAsFixed(1))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          collectionMovieList![index].title!,
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

class SocialIconWidget extends StatelessWidget {
  const SocialIconWidget({
    super.key,
    this.url,
    this.icon,
    this.isNull,
  });

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
  final String? api, title, name;
  const MovieImagesDisplay({super.key, this.api, this.name, this.title});

  @override
  MovieImagesState createState() => MovieImagesState();
}

class MovieImagesState extends State<MovieImagesDisplay> {
  Images? movieImages;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchImages(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          movieImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          widget.title!,
                          style:
                              kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: movieImages == null
                  ? detailImageShimmer(themeMode)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                          viewportFraction: 1,
                        ),
                        items: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                          alignment:
                                              AlignmentDirectional.bottomStart,
                                          children: [
                                            SizedBox(
                                              height: 180,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: movieImages!
                                                        .poster!.isEmpty
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                        height: double.infinity,
                                                        width: double.infinity)
                                                    : CachedNetworkImage(
                                                        cacheManager:
                                                            cacheProp(),
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
                                                        imageUrl: buildImageUrl(
                                                                TMDB_BASE_IMAGE_URL,
                                                                proxyUrl,
                                                                isProxyEnabled,
                                                                context) +
                                                            imageQuality +
                                                            movieImages!
                                                                .poster![0]
                                                                .posterPath!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        ((context) {
                                                              return HeroPhotoView(
                                                                posters:
                                                                    movieImages!
                                                                        .poster!,
                                                                name:
                                                                    widget.name,
                                                                imageType:
                                                                    'poster',
                                                              );
                                                            })));
                                                          },
                                                          child: Hero(
                                                            tag: buildImageUrl(
                                                                    TMDB_BASE_IMAGE_URL,
                                                                    proxyUrl,
                                                                    isProxyEnabled,
                                                                    context) +
                                                                imageQuality +
                                                                movieImages!
                                                                    .poster![0]
                                                                    .posterPath!,
                                                            child: Container(
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
                                                          ),
                                                        ),
                                                        placeholder: (context,
                                                                url) =>
                                                            detailImageImageSimmer(
                                                                themeMode),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: double
                                                                    .infinity,
                                                                width: double
                                                                    .infinity),
                                                      ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                color: Colors.black38,
                                                child: Text(movieImages!
                                                            .poster!.length ==
                                                        1
                                                    ? tr('poster_singular',
                                                        namedArgs: {
                                                            'poster':
                                                                movieImages!
                                                                    .poster!
                                                                    .length
                                                                    .toString()
                                                          })
                                                    : tr('poster_plural',
                                                        namedArgs: {
                                                            'poster':
                                                                movieImages!
                                                                    .poster!
                                                                    .length
                                                                    .toString()
                                                          })),
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomStart,
                                        children: [
                                          SizedBox(
                                            height: 180,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: movieImages!
                                                      .backdrop!.isEmpty
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      cacheManager: cacheProp(),
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
                                                      imageUrl: buildImageUrl(
                                                              TMDB_BASE_IMAGE_URL,
                                                              proxyUrl,
                                                              isProxyEnabled,
                                                              context) +
                                                          imageQuality +
                                                          movieImages!
                                                              .backdrop![0]
                                                              .filePath!,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      ((context) {
                                                            return HeroPhotoView(
                                                              backdrops:
                                                                  movieImages!
                                                                      .backdrop!,
                                                              name: widget.name,
                                                              imageType:
                                                                  'backdrop',
                                                            );
                                                          })));
                                                        },
                                                        child: Hero(
                                                          tag: buildImageUrl(
                                                                  TMDB_BASE_IMAGE_URL,
                                                                  proxyUrl,
                                                                  isProxyEnabled,
                                                                  context) +
                                                              imageQuality +
                                                              movieImages!
                                                                  .backdrop![0]
                                                                  .filePath!,
                                                          child: Container(
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
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          detailImageImageSimmer(
                                                              themeMode),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              color: Colors.black38,
                                              child: Text(movieImages!
                                                          .backdrop!.length ==
                                                      1
                                                  ? tr('backdrop_singular',
                                                      namedArgs: {
                                                          'backdrop':
                                                              movieImages!
                                                                  .backdrop!
                                                                  .length
                                                                  .toString()
                                                        })
                                                  : tr('backdrop_plural',
                                                      namedArgs: {
                                                          'backdrop':
                                                              movieImages!
                                                                  .backdrop!
                                                                  .length
                                                                  .toString()
                                                        })),
                                            ),
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieVideosDisplay extends StatefulWidget {
  final String? api, title;
  const MovieVideosDisplay({super.key, this.api, this.title});

  @override
  MovieVideosState createState() => MovieVideosState();
}

class MovieVideosState extends State<MovieVideosDisplay> {
  Videos? movieVideos;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchVideos(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          movieVideos = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Column(
      children: [
        movieVideos == null
            ? Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(
                              widget.title!,
                              style:
                                  kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LeadingDot(),
                          Expanded(
                            child: Text(
                              widget.title!,
                              style:
                                  kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: movieVideos == null
                ? detailVideoShimmer(themeMode)
                : movieVideos!.result!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(tr('no_video_movie'),
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
                                                    cacheManager: cacheProp(),
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
                                                            themeMode),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_rect.png',
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
    super.key,
    required this.posterPath,
    required this.movieId,
    this.movieName,
    this.movieImdbId,
    this.api,
    required this.releaseYear,
    required this.backdropPath,
    required this.releaseDate,
    this.adult,
  });
  final String? movieName;
  final int movieId;
  final int? movieImdbId;
  final bool? adult;
  final String? api;
  final int releaseYear;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;

  @override
  WatchNowButtonState createState() => WatchNowButtonState();
}

class WatchNowButtonState extends State<WatchNowButton> {
  bool? isVisible = false;
  double? buttonWidth = 160;

  Color _borderColor = Colors.red; // Initial border color
  Timer? _timer;
  Random random = Random();

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Generate random RGB values between 0 and 255
        int red = random.nextInt(256);
        int green = random.nextInt(256);
        int blue = random.nextInt(256);

        _borderColor = Color.fromRGBO(red, green, blue, 1.0);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fetchRoute = Provider.of<AppDependencyProvider>(context).fetchRoute;
    return AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            // Add an outer box shadow here
            BoxShadow(
              color: _borderColor,
              spreadRadius: 2.5,
              blurRadius: 4.25,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () async {
            await checkConnection().then((value) {
              value
                  ? Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                      return MovieVideoLoader(
                        route: fetchRoute == 'flixHQ'
                            ? StreamRoute.flixHQ
                            : StreamRoute.tmDB,
                        download: false,
                        metadata: MovieStreamMetadata(
                            backdropPath: widget.backdropPath,
                            elapsed: null,
                            isAdult: widget.adult,
                            movieId: widget.movieId,
                            movieName: widget.movieName,
                            posterPath: widget.posterPath,
                            releaseYear: widget.releaseYear,
                            releaseDate: widget.releaseDate),
                      );
                    })))
                  : GlobalMethods.showCustomScaffoldMessage(
                      SnackBar(
                        content: Text(
                          tr('check_connection'),
                          maxLines: 3,
                          style: kTextSmallBodyStyle,
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                      context);
            });
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(tr('watch_now'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ))
              ])),
        ));
  }
}

class GenreDisplay extends StatefulWidget {
  final String? api;
  const GenreDisplay({super.key, this.api});

  @override
  GenreDisplayState createState() => GenreDisplayState();
}

class GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchGenre(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  // void getGenreWithoutData() {
  //   genreList = [];
  //   for (int i = 0; i < widget.movieGenres!.length; i++) {
  //     print(i);
  //     for (int k = 0; k < genreData.movieGenres.length; k++) {
  //       if (widget.movieGenres![i] == genreData.movieGenres[k].genreValue) {
  //         setState(() {
  //           genreList!.add(Genres(
  //               genreID: genreData.movieGenres[k].genreValue,
  //               genreName: genreData.movieGenres[k].genreName));
  //         });
  //       } else {
  //         print('inv: ${widget.movieGenres![i]}');
  //       }
  //     }
  //   }
  //   print(genreList);
  // }

  // void genreGet() {
  //   print(widget.movieGenres);
  //   widget.movieGenres == null
  //       ? fetchGenre(widget.api!).then((value) {
  //           if (mounted) {
  //             setState(() {
  //               genreList = value;
  //             });
  //           }
  //         })
  //       : getGenreWithoutData();
  // }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    super.build(context);
    return Container(
        child: genreList == null
            ? SizedBox(
                height: 80,
                child: detailGenreShimmer(themeMode),
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
                                side: BorderSide(
                                  width: 2,
                                  style: BorderStyle.solid,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              label: Text(
                                genreList![index].genreName!,
                                style: const TextStyle(fontFamily: 'Figtree'),
                                // style: widget.themeData.textTheme.bodyText1,
                              ),
                              backgroundColor:
                                  themeMode == 'dark' || themeMode == 'amoled'
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
  const MovieInfoTable({super.key, this.api});

  @override
  MovieInfoTableState createState() => MovieInfoTableState();
}

class MovieInfoTableState extends State<MovieInfoTable> {
  MovieDetails? movieDetails;
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovieDetails(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          movieDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LeadingDot(),
              Expanded(
                child: Text(
                  tr('movie_info'),
                  style: kTextHeaderStyle,
                ),
              ),
            ],
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: movieDetails == null
                    ? detailInfoTableShimmer(themeMode)
                    : DataTable(dataRowMinHeight: 40, columns: [
                        DataColumn(
                            label: Text(
                          tr('original_title'),
                          style: kTableLeftStyle,
                        )),
                        DataColumn(
                          label: Text(
                            movieDetails!.originalTitle!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ], rows: [
                        DataRow(cells: [
                          DataCell(Text(
                            tr('status'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.status!.isEmpty
                              ? tr('unknown')
                              : movieDetails!.status!)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr('runtime'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(movieDetails!.runtime! == 0
                              ? tr('not_available')
                              : tr('runtime_mins', namedArgs: {
                                  'mins': movieDetails!.runtime!.toString()
                                }))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr('spoken_language'),
                            style: kTableLeftStyle,
                          )),
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
                                            ? tr('not_available')
                                            : '${movieDetails!.spokenLanguages![index].englishName},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr('budget'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.budget!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr('revenue'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(movieDetails!.budget == 0
                              ? const Text('-')
                              : Text(formatCurrency
                                  .format(movieDetails!.revenue!)
                                  .toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr('tagline'),
                            style: kTableLeftStyle,
                          )),
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
                          DataCell(Text(
                            tr('production_companies'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: movieDetails!.productionCompanies!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movieDetails!
                                        .productionCompanies!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(movieDetails!
                                                .productionCompanies!.isEmpty
                                            ? tr('not_available')
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
                          DataCell(Text(
                            tr('production_countries'),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: movieDetails!.productionCountries!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: movieDetails!
                                        .productionCountries!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(movieDetails!
                                                .productionCountries!.isEmpty
                                            ? tr('not_available')
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
      ),
    );
  }
}

class CastTab extends StatefulWidget {
  final Credits credits;
  const CastTab({super.key, required this.credits});

  @override
  CastTabState createState() => CastTabState();
}

class CastTabState extends State<CastTab>
    with AutomaticKeepAliveClientMixin<CastTab> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return widget.credits.cast!.isEmpty
        ? Container(
            child: Center(
              child: Text(tr('no_cast_movie')),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                shrinkWrap: false,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.credits.cast!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CastDetailPage(
                            cast: widget.credits.cast![index],
                            heroId: '${widget.credits.cast![index].creditId}');
                      }));
                    },
                    child: Container(
                      color: Colors.transparent,
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
                                          '${widget.credits.cast![index].creditId}',
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: widget.credits.cast![index]
                                                    .profilePath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: buildImageUrl(
                                                        TMDB_BASE_IMAGE_URL,
                                                        proxyUrl,
                                                        isProxyEnabled,
                                                        context) +
                                                    imageQuality +
                                                    widget.credits.cast![index]
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
                                                    castAndCrewTabImageShimmer(
                                                        themeMode),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
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
                                        widget.credits.cast![index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'FigtreeSB',
                                            fontSize: 20),
                                      ),
                                      Text(widget.credits.cast![index]
                                              .character!.isEmpty
                                          ? tr('as_empty')
                                          : tr('as', namedArgs: {
                                              'character': widget.credits
                                                  .cast![index].character!
                                            })),
                                      Visibility(
                                        visible:
                                            widget.credits.cast![0].roles ==
                                                    null
                                                ? false
                                                : true,
                                        child: Text(
                                          widget.credits.cast![0].roles == null
                                              ? ''
                                              : widget
                                                          .credits
                                                          .cast![index]
                                                          .roles![0]
                                                          .episodeCount! ==
                                                      1
                                                  ? tr('single_episode',
                                                      namedArgs: {
                                                          'count': widget
                                                              .credits
                                                              .cast![index]
                                                              .roles![0]
                                                              .episodeCount!
                                                              .toString()
                                                        })
                                                  : tr('multi_episode',
                                                      namedArgs: {
                                                          'count': widget
                                                              .credits
                                                              .cast![index]
                                                              .roles![0]
                                                              .episodeCount!
                                                              .toString()
                                                        }),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: themeMode == 'light'
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

  @override
  bool get wantKeepAlive => true;
}

class CrewTab extends StatefulWidget {
  const CrewTab({super.key, required this.credits});

  final Credits credits;

  @override
  CrewTabState createState() => CrewTabState();
}

class CrewTabState extends State<CrewTab>
    with AutomaticKeepAliveClientMixin<CrewTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return widget.credits.crew!.isEmpty
        ? Center(
            child: Text(
              tr('no_crew_movie'),
              textAlign: TextAlign.center,
            ),
          )
        : Container(
            padding: const EdgeInsets.only(top: 8),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.credits.crew!.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CrewDetailPage(
                            crew: widget.credits.crew![index],
                            heroId: '${widget.credits.crew![index].creditId}');
                      }));
                    },
                    child: Container(
                      color: Colors.transparent,
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
                                          '${widget.credits.crew![index].creditId}',
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: widget.credits.crew![index]
                                                    .profilePath ==
                                                null
                                            ? Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                cacheManager: cacheProp(),
                                                fadeOutDuration: const Duration(
                                                    milliseconds: 300),
                                                fadeOutCurve: Curves.easeOut,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 700),
                                                fadeInCurve: Curves.easeIn,
                                                imageUrl: buildImageUrl(
                                                        TMDB_BASE_IMAGE_URL,
                                                        proxyUrl,
                                                        isProxyEnabled,
                                                        context) +
                                                    imageQuality +
                                                    widget.credits.crew![index]
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
                                                    castAndCrewTabImageShimmer(
                                                        themeMode),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
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
                                        widget.credits.crew![index].name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontFamily: 'FigtreeSB',
                                            fontSize: 20),
                                      ),
                                      Text(widget.credits.crew![index]
                                              .department!.isEmpty
                                          ? tr('job_empty')
                                          : tr('job', namedArgs: {
                                              'job': widget.credits.crew![index]
                                                  .department!
                                            })),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: themeMode == 'light'
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
      {super.key,
      required this.api,
      required this.movieId,
      required this.includeAdult});

  @override
  MovieRecommendationsTabState createState() => MovieRecommendationsTabState();
}

class MovieRecommendationsTabState extends State<MovieRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                movieList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr('movie_recommendations'),
                          style: kTextHeaderStyle,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(themeMode)
                : movieList!.isEmpty
                    ? Center(
                        child: Text(
                          tr('no_recommendations_movie'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingMoviesList(
                                scrollController: _scrollController,
                                movieList: movieList,
                                imageQuality: imageQuality,
                                themeMode: themeMode),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer(themeMode),
                            ),
                          ),
                        ],
                      ),
          ),
          Divider(
            color: themeMode == 'light' ? Colors.black54 : Colors.white54,
            thickness: 1,
            endIndent: 20,
            indent: 10,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarMoviesTab extends StatefulWidget {
  final String api;
  final int movieId;
  final String movieName;
  final bool? includeAdult;
  const SimilarMoviesTab(
      {super.key,
      required this.api,
      required this.movieId,
      required this.movieName,
      required this.includeAdult});

  @override
  SimilarMoviesTabState createState() => SimilarMoviesTabState();
}

class SimilarMoviesTabState extends State<SimilarMoviesTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          movieList = value;
        });
      }
    });
    getMoreData();
  }

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                movieList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr('movies_similar_with',
                              namedArgs: {'movie': widget.movieName}),
                          style: kTextHeaderStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: movieList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(themeMode)
                : movieList!.isEmpty
                    ? Center(
                        child: Text(
                          tr('no_similars_movie'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                              child: HorizontalScrollingMoviesList(
                            imageQuality: imageQuality,
                            themeMode: themeMode,
                            movieList: movieList,
                            scrollController: _scrollController,
                          )),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer(themeMode),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreMovies extends StatefulWidget {
  final String api;
  final int genreId;
  final String watchRegion;
  final bool? includeAdult;
  const ParticularGenreMovies(
      {super.key,
      required this.api,
      required this.genreId,
      required this.includeAdult,
      required this.watchRegion});
  @override
  ParticularGenreMoviesState createState() => ParticularGenreMoviesState();
}

class ParticularGenreMoviesState extends State<ParticularGenreMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return moviesList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : moviesList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                isLoading: isLoading,
                scrollController: _scrollController)
            : moviesList!.isEmpty
                ? Container(
                    child: Center(
                      child: Text(tr('no_genre_movie')),
                    ),
                  )
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: viewType == 'grid'
                                    ? MovieGridView(
                                        scrollController: _scrollController,
                                        moviesList: moviesList,
                                        imageQuality: imageQuality,
                                        themeMode: themeMode)
                                    : MovieListView(
                                        scrollController: _scrollController,
                                        moviesList: moviesList,
                                        themeMode: themeMode,
                                        imageQuality: imageQuality),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isLoading,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: LinearProgressIndicator()),
                          )),
                    ],
                  ));
  }
}

class ParticularStreamingServiceMovies extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  final String watchRegion;
  const ParticularStreamingServiceMovies({
    super.key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
    required this.watchRegion,
  });
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

  void getMoreData() async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum',
                  isProxyEnabled,
                  proxyUrl)
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}',
            isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return moviesList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(themeMode)
        : moviesList == null && viewType == 'list'
            ? mainPageVerticalScrollShimmer(
                themeMode: themeMode,
                isLoading: isLoading,
                scrollController: _scrollController)
            : moviesList!.isEmpty
                ? Container(
                    child: Center(
                      child: Text(tr('no_watchprovider_movie')),
                    ),
                  )
                : Container(
                    child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Expanded(
                                  child: viewType == 'grid'
                                      ? MovieGridView(
                                          scrollController: _scrollController,
                                          moviesList: moviesList,
                                          imageQuality: imageQuality,
                                          themeMode: themeMode)
                                      : MovieListView(
                                          scrollController: _scrollController,
                                          moviesList: moviesList,
                                          themeMode: themeMode,
                                          imageQuality: imageQuality)),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: isLoading,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: LinearProgressIndicator()),
                          )),
                    ],
                  ));
  }
}

class StreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const StreamingServicesWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.providerID,
  });

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
              color: Theme.of(context).colorScheme.primaryContainer,
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
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
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
    super.key,
    required this.api,
  });

  @override
  GenreListGridState createState() => GenreListGridState();
}

class GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<Genres>? genreList;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchGenre(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const LeadingDot(),
                    Expanded(
                      child: Text(
                        tr('genres'),
                        style: kTextHeaderStyle,
                      ),
                    ),
                  ],
                ),
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
                ? genreListGridShimmer(themeMode)
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Text(
                                      genreList![index].genreName ?? 'Null',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
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

  @override
  bool get wantKeepAlive => true;
}

class TopButton extends StatefulWidget {
  final String buttonText;
  const TopButton({
    super.key,
    required this.buttonText,
  });

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
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            maximumSize: WidgetStateProperty.all(const Size(200, 60)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    )))),
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
  final String country;
  const WatchProvidersButton({
    super.key,
    this.onTap,
    required this.api,
    required this.country,
  });

  @override
  State<WatchProvidersButton> createState() => _WatchProvidersButtonState();
}

class _WatchProvidersButtonState extends State<WatchProvidersButton> {
  WatchProviders? watchProviders;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchWatchProviders(widget.api, widget.country, isProxyEnabled, proxyUrl)
        .then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            maximumSize: WidgetStateProperty.all(const Size(200, 60)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    )))),
        onPressed: () {
          widget.onTap!();
        },
        child: Text(
          tr('watch_providers'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({super.key});

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
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          tr('streaming_services'),
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    super.key,
    this.api,
  });
  @override
  CollectionMoviesState createState() => CollectionMoviesState();
}

class CollectionMoviesState extends State<CollectionMovies> {
  List<Movie>? moviesList;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchCollectionMovies(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return moviesList == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : moviesList!.isEmpty
            ? Center(
                child: Text(
                  tr('no_watchprovider_movie'),
                  style: const TextStyle(fontFamily: 'Figtree'),
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
                                                  cacheManager: cacheProp(),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  fadeOutCurve: Curves.easeOut,
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 700),
                                                  fadeInCurve: Curves.easeIn,
                                                  imageUrl: buildImageUrl(
                                                          TMDB_BASE_IMAGE_URL,
                                                          proxyUrl,
                                                          isProxyEnabled,
                                                          context) +
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
                                                  placeholder: (context, url) =>
                                                      scrollingImageShimmer(
                                                          themeMode),
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
                                                  fontFamily: 'Figtree'),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  moviesList![index]
                                                      .voteAverage!
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                      fontFamily: 'Figtree'),
                                                ),
                                                const Icon(
                                                  Icons.star_rounded,
                                                ),
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
              );
  }
}
