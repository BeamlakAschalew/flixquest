// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

import '../modals/genres.dart';
import '/constants/style_constants.dart';
import '/modals/social_icons_icons.dart';
import '/modals/videos.dart';
import '/modals/watch_providers.dart';
import '/screens/cast_detail.dart';
import '/screens/streaming_services_movies.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '/modals/function.dart';
import '/modals/movie.dart';
import '/api/endpoints.dart';
import '/modals/genres.dart' as genreold;
import '/constants/api_constants.dart';
import '/screens/movie_detail.dart';
import '/modals/credits.dart' as oldCredits;
import 'collection_detail.dart';
import 'crew_detail.dart';
import '/modals/images.dart'as old_images;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'genremovies.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'movie_stream_select.dart';

class MainMoviesDisplay extends StatefulWidget {
  const MainMoviesDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMoviesDisplay> createState() => _MainMoviesDisplayState();
}

class _MainMoviesDisplayState extends State<MainMoviesDisplay>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView(
        children: [
          const DiscoverMovies(),
          ScrollingMovies(
            title: 'Popular',
            api: Endpoints.popularMoviesUrl(1),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Trending',
            api: Endpoints.trendingMoviesUrl(1),
            discoverType: 1,
            isTrending: true,
          ),
          ScrollingMovies(
            title: 'Top Rated',
            api: Endpoints.topRatedUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Now playing',
            api: Endpoints.nowPlayingMoviesUrl(1),
            discoverType: 'now_playing',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Upcoming',
            api: Endpoints.upcomingMoviesUrl(1),
            discoverType: 'upcoming',
            isTrending: false,
          ),
          GenreListGrid(api: Endpoints.movieGenresUrl()),
          const MoviesFromWatchProviders(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies({Key? key}) : super(key: key);
  @override
  _DiscoverMoviesState createState() => _DiscoverMoviesState();
}

class _DiscoverMoviesState extends State<DiscoverMovies>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  MovieDetails? movieDetails;
  late Mixpanel mixpanel;
  late double deviceHeight;
  @override
  void initState() {
    super.initState();
    fetchMovies(Endpoints.discoverMoviesUrl(1)).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    fetchMovieDetails(Endpoints.discoverMoviesUrl(1)).then((value) {
      setState(() {
        movieDetails = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
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
          //height: 350,
          height: deviceHeight * 0.417,
          child: moviesList == null
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
                          mixpanel
                              .track('Most viewed movie pages', properties: {
                            'Movie name': '${moviesList![index].originalTitle}',
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
                            child: FadeInImage(
                              image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                  'w500/' +
                                  moviesList![index].posterPath!),
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/images/loading.gif'),
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
  final String? api, title;
  final dynamic discoverType;
  final String? watchProviderId;
  final bool isTrending;
  const ScrollingMovies({
    Key? key,
    this.api,
    this.title,
    this.discoverType,
    this.watchProviderId,
    required this.isTrending,
  }) : super(key: key);
  @override
  _ScrollingMoviesState createState() => _ScrollingMoviesState();
}

class _ScrollingMoviesState extends State<ScrollingMovies>
    with AutomaticKeepAliveClientMixin {
  late int index;
  List<Movie>? moviesList;
  MovieDetails? movieDetails;
  late Mixpanel mixpanel;
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
                "$TMDB_API_BASE_URL/movie/${widget.discoverType}?api_key=$TMDB_API_KEY&page=" +
                    pageNum.toString()),
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
                "$TMDB_API_BASE_URL/trending/movie/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=false&page=" +
                    pageNum.toString()),
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
    fetchMovies(widget.api!).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          child: moviesList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
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
                                      'Movie id': '${moviesList![index].id}'
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
                                                  imageUrl:
                                                      TMDB_BASE_IMAGE_URL +
                                                          'w500/' +
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
                                          // : FadeInImage(
                                          //     image: NetworkImage(
                                          //         TMDB_BASE_IMAGE_URL +
                                          //             'w500/' +
                                          //             moviesList![index]
                                          //                 .posterPath!),
                                          //     fit: BoxFit.cover,
                                          //     placeholder: const AssetImage(
                                          //         'assets/images/loading.gif'),
                                          //   ),
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

class ScrollingArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  _ScrollingArtistsState createState() => _ScrollingArtistsState();
}

class _ScrollingArtistsState extends State<ScrollingArtists> {
  Credits? credits;
  late Mixpanel mixpanel;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
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
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return CastDetailPage(
                          //     cast: credits!.cast![index],
                          //     heroId: '${credits!.cast![index].id}',
                          //   );
                          // }));
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
                                      child:
                                          credits!.cast![index].profilePath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_square.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : FadeInImage(
                                                  image: NetworkImage(
                                                      TMDB_BASE_IMAGE_URL +
                                                          'w500/' +
                                                          credits!.cast![index]
                                                              .profilePath!),
                                                  fit: BoxFit.cover,
                                                  placeholder: const AssetImage(
                                                      'assets/images/loading.gif'),
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
  _MovieSocialLinksState createState() => _MovieSocialLinksState();
}

class _MovieSocialLinksState extends State<MovieSocialLinks> {
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
                            'This movie doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
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
                              isNull: externalLinks?.instagramUsername == null,
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
  _BelongsToCollectionWidgetState createState() =>
      _BelongsToCollectionWidgetState();
}

class _BelongsToCollectionWidgetState extends State<BelongsToCollectionWidget> {
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
    return belongsToCollection == null
        ? const Center(child: CircularProgressIndicator())
        : belongsToCollection?.id == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: belongsToCollection!.backdropPath == null
                          ? Image.asset(
                              'assets/images/na_logo.png',
                            )
                          : FadeInImage(
                              placeholder:
                                  const AssetImage('assets/images/loading.gif'),
                              image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                  'w500/' +
                                  belongsToCollection!.backdropPath!)),
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
                                  backgroundColor: Colors.black38),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0x26F57C00)),
                                  maximumSize: MaterialStateProperty.all(
                                      const Size(200, 40)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: const BorderSide(
                                              color: Color(0xFFF57C00))))),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
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
                )),
              );
  }
}

class CollectionOverviewWidget extends StatefulWidget {
  final String? api;
  const CollectionOverviewWidget({Key? key, this.api}) : super(key: key);

  @override
  _CollectionOverviewWidgetState createState() =>
      _CollectionOverviewWidgetState();
}

class _CollectionOverviewWidgetState extends State<CollectionOverviewWidget> {
  CollectionDetails? collectionDetails;
  @override
  void initState() {
    super.initState();
    fetchCollectionDetails(widget.api!).then((value) {
      setState(() {
        collectionDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: collectionDetails == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Text(collectionDetails!.overview!),
    );
  }
}

class PartsList extends StatefulWidget {
  final String? api;
  final String? title;
  const PartsList({Key? key, this.api, this.title}) : super(key: key);

  @override
  _PartsListState createState() => _PartsListState();
}

class _PartsListState extends State<PartsList> {
  List<Movie>? collectionMovieList;
  late Mixpanel mixpanel;
  @override
  void initState() {
    super.initState();
    fetchCollectionMovies(widget.api!).then((value) {
      setState(() {
        collectionMovieList = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
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
              ? const Center(
                  child: CircularProgressIndicator(),
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
                                mixpanel.track('Most viewed movie pages',
                                    properties: {
                                      'Movie name':
                                          '${collectionMovieList![index].originalTitle}',
                                      'Movie id':
                                          '${collectionMovieList![index].id}'
                                    });
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
                                              : FadeInImage(
                                                  image: NetworkImage(
                                                      TMDB_BASE_IMAGE_URL +
                                                          'w500/' +
                                                          collectionMovieList![
                                                                  index]
                                                              .posterPath!),
                                                  fit: BoxFit.cover,
                                                  placeholder: const AssetImage(
                                                      'assets/images/loading.gif'),
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
                launch(url!);
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
  _MovieImagesState createState() => _MovieImagesState();
}

class _MovieImagesState extends State<MovieImagesDisplay> {
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
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
                                child: FadeInImage(
                                  image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                      'w500/' +
                                      movieImages!.backdrop![index].filePath!),
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/images/loading.gif'),
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
  _MovieVideosState createState() => _MovieVideosState();
}

class _MovieVideosState extends State<MovieVideosDisplay> {
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
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
                                  launch(YOUTUBE_BASE_URL +
                                      movieVideos!.result![index].videoLink!);
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
                                                  FadeInImage(
                                                    image: NetworkImage(
                                                        YOUTUBE_THUMBNAIL_URL +
                                                            movieVideos!
                                                                .result![index]
                                                                .videoLink! +
                                                            '/hqdefault.jpg'),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
  }) : super(key: key);
  final String? movieName;
  final int? movieId;
  final int? movieImdbId;
  final String? api;

  @override
  _WatchNowButtonState createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  late Mixpanel mixpanel;
  MovieDetails? movieDetails;
  bool? isVisible = false;
  double? buttonWidth = 150;
  @override
  void initState() {
    super.initState();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor:
                MaterialStateProperty.all(const Color(0xFFF57C00))),
        onPressed: () async {
          mixpanel.track('Most viewed movies', properties: {
            'Movie name': '${widget.movieName}',
            'Movie id': '${widget.movieId}'
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
            return MovieStreamSelect(
              movieId: widget.movieId!,
              movieName: widget.movieName!,
              movieImdbId: movieDetails!.imdbId!,
            );
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
  _GenreDisplayState createState() => _GenreDisplayState();
}

class _GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<MovieGenres>? genreList;
  @override
  void initState() {
    super.initState();
    // fetchGenre(widget.api!).then((value) {
    //   setState(() {
    //     genreList = value;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: SizedBox(
      height: genreList == null ? 0 : 80,
      child: genreList == null
          ? Container()
          : ListView.builder(
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
                            color: Color(0xFFad5700)),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      label: Text(
                        genreList![index].genreName!,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        // style: widget.themeData.textTheme.bodyText1,
                      ),
                      backgroundColor: Colors.transparent,
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
  _MovieInfoTableState createState() => _MovieInfoTableState();
}

class _MovieInfoTableState extends State<MovieInfoTable> {
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
    return movieDetails == null
        ? const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
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
                    child: DataTable(dataRowHeight: 40, columns: [
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
  _CastTabState createState() => _CastTabState();
}

class _CastTabState extends State<CastTab>
    with AutomaticKeepAliveClientMixin<CastTab> {
  Credits? credits;
  late Mixpanel mixpanel;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            color: const Color(0xFF202124),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : credits!.cast!.isEmpty
            ? Container(
                child: const Center(
                  child: Text('There is no cast available for this movie'),
                ),
                color: const Color(0xFF202124),
              )
            : Container(
                color: const Color(0xFF202124),
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
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return CastDetailPage(
                          //       cast: credits!.cast![index],
                          //       heroId: '${credits!.cast![index].name}');
                          // }));
                        },
                        child: Container(
                          color: const Color(0xFF202124),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 15.0,
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      // child: Text(tvDetails!
                                      //     .seasons![index].seasonNumber
                                      //     .toString()),
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
  final String? api;
  const CrewTab({Key? key, this.api}) : super(key: key);

  @override
  _CrewTabState createState() => _CrewTabState();
}

class _CrewTabState extends State<CrewTab>
    with AutomaticKeepAliveClientMixin<CrewTab> {
  Credits? credits;
  late Mixpanel mixpanel;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            color: const Color(0xFF202124),
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
                color: const Color(0xFF202124),
              )
            : Container(
                color: const Color(0xFF202124),
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
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return CrewDetailPage(
                          //       crew: credits!.crew![index],
                          //       heroId: '${credits!.crew![index].creditId}');
                          // }));
                        },
                        child: Container(
                          color: const Color(0xFF202124),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 15.0,
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
                                                BorderRadius.circular(100.0),
                                            child: credits!.crew![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_square.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            credits!
                                                                .crew![index]
                                                                .profilePath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      // child: Text(tvDetails!
                                      //     .seasons![index].seasonNumber
                                      //     .toString()),
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

class MovieRecommendationsTab extends StatefulWidget {
  final String api;
  final int movieId;
  const MovieRecommendationsTab(
      {Key? key, required this.api, required this.movieId})
      : super(key: key);

  @override
  _MovieRecommendationsTabState createState() =>
      _MovieRecommendationsTabState();
}

class _MovieRecommendationsTabState extends State<MovieRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  late Mixpanel mixpanel;
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
            '$TMDB_API_BASE_URL/movie/${widget.movieId}/recommendations?api_key=$TMDB_API_KEY'
            '&language=en-US'
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
  void initState() {
    super.initState();
    fetchMovies(widget.api).then((value) {
      setState(() {
        movieList = value;
      });
    });
    getMoreData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return movieList == null
        ? Container(
            color: const Color(0xFF202124),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : movieList!.isEmpty
            ? Container(
                color: const Color(0xFF202124),
                child: const Center(
                  child: Text(
                      'There is no recommendations available for this movie'),
                ),
              )
            : Container(
                color: const Color(0xFF202124),
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
                                      'Movie id': '${movieList![index].id}'
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
                                color: const Color(0xFF202124),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 8.0,
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
                                                tag: '${movieList![index].id}',
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
                                                      : FadeInImage(
                                                          image: NetworkImage(
                                                              TMDB_BASE_IMAGE_URL +
                                                                  'w500/' +
                                                                  movieList![
                                                                          index]
                                                                      .posterPath!),
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              const AssetImage(
                                                                  'assets/images/loading.gif'),
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
                                                      movieList![index]
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
                                      const Divider(
                                        color: Colors.white,
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
                  ],
                ));
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarMoviesTab extends StatefulWidget {
  final String api;
  final int movieId;

  const SimilarMoviesTab({Key? key, required this.api, required this.movieId})
      : super(key: key);

  @override
  _SimilarMoviesTabState createState() => _SimilarMoviesTabState();
}

class _SimilarMoviesTabState extends State<SimilarMoviesTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  final _scrollController = ScrollController();
  late Mixpanel mixpanel;
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
            '$TMDB_API_BASE_URL/movie/${widget.movieId}/similar?api_key=$TMDB_API_KEY'
            '&language=en-US'
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
  void initState() {
    super.initState();
    fetchMovies(widget.api).then((value) {
      setState(() {
        movieList = value;
      });
    });
    getMoreData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return movieList == null
        ? Container(
            color: const Color(0xFF202124),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : movieList!.isEmpty
            ? Container(
                color: const Color(0xFF202124),
                child: const Center(
                  child: Text('There are no similars available for this movie'),
                ),
              )
            : Container(
                color: const Color(0xFF202124),
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
                                      'Movie id': '${movieList![index].id}'
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
                                color: const Color(0xFF202124),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0.0,
                                    bottom: 8.0,
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
                                                tag: '${movieList![index].id}',
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
                                                      : FadeInImage(
                                                          image: NetworkImage(
                                                              TMDB_BASE_IMAGE_URL +
                                                                  'w500/' +
                                                                  movieList![
                                                                          index]
                                                                      .posterPath!),
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              const AssetImage(
                                                                  'assets/images/loading.gif'),
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
                                                      movieList![index]
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
                                      const Divider(
                                        color: Colors.white,
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
                  ],
                ));
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreMovies extends StatefulWidget {
  final String api;
  final int genreId;
  const ParticularGenreMovies(
      {Key? key, required this.api, required this.genreId})
      : super(key: key);
  @override
  _ParticularGenreMoviesState createState() => _ParticularGenreMoviesState();
}

class _ParticularGenreMoviesState extends State<ParticularGenreMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  late Mixpanel mixpanel;
  int pageNum = 2;
  bool isLoading = false;

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
                '&include_adult=false'
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
    fetchMovies(widget.api).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    return moviesList == null
        ? Container(
            color: const Color(0xFF202124),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : moviesList!.isEmpty
            ? Container(
                color: const Color(0xFF202124),
                child: const Center(
                  child: Text('Oops! movies for this genre doesn\'t exist :('),
                ),
              )
            : Container(
                color: const Color(0xFF202124),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: moviesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  mixpanel.track('Most viewed movie pages',
                                      properties: {
                                        'Movie name':
                                            '${moviesList![index].originalTitle}',
                                        'Movie id': '${moviesList![index].id}'
                                      });
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MovieDetailPage(
                                      movie: moviesList![index],
                                      heroId: '${moviesList![index].id}',
                                    );
                                  }));
                                },
                                child: Container(
                                  color: const Color(0xFF202124),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 8.0,
                                      left: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: SizedBox(
                                                width: 85,
                                                height: 130,
                                                child: Hero(
                                                  tag:
                                                      '${moviesList![index].id}',
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: moviesList![index]
                                                                .posterPath ==
                                                            null
                                                        ? Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          )
                                                        : FadeInImage(
                                                            image: NetworkImage(
                                                                TMDB_BASE_IMAGE_URL +
                                                                    'w500/' +
                                                                    moviesList![
                                                                            index]
                                                                        .posterPath!),
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                const AssetImage(
                                                                    'assets/images/loading.gif'),
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
                                                    moviesList![index].title!,
                                                    style: const TextStyle(
                                                        fontFamily: 'PoppinsSB',
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
                                                        moviesList![index]
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
                                        const Divider(
                                          color: Colors.white,
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
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        )),
                  ],
                ));
  }
}

class ParticularStreamingServiceMovies extends StatefulWidget {
  final String api;
  final int providerID;
  const ParticularStreamingServiceMovies({
    Key? key,
    required this.api,
    required this.providerID,
  }) : super(key: key);
  @override
  _ParticularStreamingServiceMoviesState createState() =>
      _ParticularStreamingServiceMoviesState();
}

class _ParticularStreamingServiceMoviesState
    extends State<ParticularStreamingServiceMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  late Mixpanel mixpanel;
  int pageNum = 2;
  bool isLoading = false;

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
            '.desc&include_adult=false&include_video=false&page=$pageNum'
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
    fetchMovies(widget.api).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    return moviesList == null
        ? Container(
            color: const Color(0xFF202124),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : moviesList!.isEmpty
            ? Container(
                color: const Color(0xFF202124),
                child: const Center(
                  child: Text(
                      'Oops! movies for this watch provider doesn\'t exist :('),
                ),
              )
            : Container(
                color: const Color(0xFF202124),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: moviesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  mixpanel.track('Most viewed movie pages',
                                      properties: {
                                        'Movie name':
                                            '${moviesList![index].originalTitle}',
                                        'Movie id': '${moviesList![index].id}'
                                      });
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MovieDetailPage(
                                      movie: moviesList![index],
                                      heroId: '${moviesList![index].id}',
                                    );
                                  }));
                                },
                                child: Container(
                                  color: const Color(0xFF202124),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 8.0,
                                      left: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: SizedBox(
                                                width: 85,
                                                height: 130,
                                                child: Hero(
                                                  tag:
                                                      '${moviesList![index].id}',
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: moviesList![index]
                                                                .posterPath ==
                                                            null
                                                        ? Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          )
                                                        : FadeInImage(
                                                            image: NetworkImage(
                                                                TMDB_BASE_IMAGE_URL +
                                                                    'w500/' +
                                                                    moviesList![
                                                                            index]
                                                                        .posterPath!),
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                const AssetImage(
                                                                    'assets/images/loading.gif'),
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
                                                    moviesList![index].title!,
                                                    style: const TextStyle(
                                                        fontFamily: 'PoppinsSB',
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
                                                        moviesList![index]
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
                                        const Divider(
                                          color: Colors.white,
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
                    ),
                    Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
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
                child: Text(title),
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
  const GenreListGrid({Key? key, required this.api}) : super(key: key);

  @override
  _GenreListGridState createState() => _GenreListGridState();
}

class _GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<MovieGenres>? movieGenres;
  @override
  void initState() {
    super.initState();
    fetchMovieGenres(Endpoints.movieGenresUrl()).then((value) {
      setState(() {
        movieGenres = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return movieGenres == null
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
                            itemCount: movieGenres!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return GenreMovies(
                                        genres: movieGenres![index]);
                                  }));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 125,
                                    alignment: Alignment.center,
                                    child: Text(movieGenres![index].genreName!),
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

class TopButton extends StatefulWidget {
  final String buttonText;
  const TopButton({
    Key? key,
    required this.buttonText,
  }) : super(key: key);

  @override
  _TopButtonState createState() => _TopButtonState();
}

class _TopButtonState extends State<TopButton> {
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
  @override
  void initState() {
    super.initState();
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return watchProviders == null
        ? const Center(child: CircularProgressIndicator())
        : Container(
            child: Column(
              children: [
                TabBar(
                  controller: tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      child: Text('Buy'),
                    ),
                    Tab(
                      child: Text('Stream'),
                    ),
                    Tab(
                      child: Text('Rent'),
                    ),
                    Tab(
                      child: Text('Free'),
                    )
                  ],
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
                                    'This movie doesn\'t have an option to buy yet'))
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .buy![index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
                                    'This movie doesn\'t have an option to stream yet'))
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .flatRate![
                                                                    index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
                        child: watchProviders?.rent == null
                            ? const Center(
                                child: Text(
                                    'This movie doesn\'t have an option to rent yet'))
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .rent![index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({Key? key}) : super(key: key);

  @override
  _MoviesFromWatchProvidersState createState() =>
      _MoviesFromWatchProvidersState();
}

class _MoviesFromWatchProvidersState extends State<MoviesFromWatchProviders> {
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
  _CollectionMoviesState createState() => _CollectionMoviesState();
}

class _CollectionMoviesState extends State<CollectionMovies> {
  List<Movie>? moviesList;
  late Mixpanel mixpanel;
  @override
  void initState() {
    super.initState();
    fetchCollectionMovies(widget.api!).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
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
                                    'Movie id': '${moviesList![index].id}'
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
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            moviesList![index]
                                                                .posterPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
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
