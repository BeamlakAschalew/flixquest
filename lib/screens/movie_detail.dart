// ignore_for_file: avoid_unnecessary_containers
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemax/modals/function.dart';
import 'package:intl/intl.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '/constants/style_constants.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/modals/movie.dart';
import '/screens/movie_widgets.dart';
import 'cast_detail.dart';
import 'genremovies.dart';
import 'movie_stream_select.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;
  final MovieDetails? md;

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.heroId,
    this.md,
  }) : super(key: key);
  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MovieDetailPage> {
  late TabController tabController;
  FullMovieDetails? fullMovieDetails;
  late Mixpanel mixpanel;
  bool? isVisible = false;
  double? buttonWidth = 150;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);

    initMixpanel();

    fetchFullMovieDetails(Endpoints.advancedMovieDetailsUrl(widget.movie.id!))
        .then((value) {
      setState(() {
        fullMovieDetails = value;
      });
    });
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("c46981e69e00f916418c0dfd0d27f1be",
        optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
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
                        : FadeInImage(
                            width: double.infinity,
                            height: double.infinity,
                            image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                'original/' +
                                widget.movie.backdropPath!),
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage('assets/images/loading_5.gif'),
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
                        color: Colors.black38),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFF57C00),
                      ),
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
                            color: const Color(0xFF2b2c30),
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
                                  unselectedLabelColor: Colors.white54,
                                  labelColor: Colors.white,
                                  tabs: const [
                                    Tab(
                                      child: Text('About',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('Cast',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('Crew',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('Recommendations',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                    Tab(
                                      child: Text('Similar',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ),
                                  ],
                                  controller: tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics: const PageScrollPhysics(),
                                    children: [
                                      SingleChildScrollView(
                                        // physics: const BouncingScrollPhysics(),
                                        child: Container(
                                          color: const Color(0xFF202124),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                  child: fullMovieDetails ==
                                                          null
                                                      ? CircularProgressIndicator()
                                                      : SizedBox(
                                                          height:
                                                              fullMovieDetails ==
                                                                      null
                                                                  ? 0
                                                                  : 80,
                                                          child:
                                                              fullMovieDetails ==
                                                                      null
                                                                  ? Container()
                                                                  : ListView
                                                                      .builder(
                                                                      shrinkWrap:
                                                                          true,
                                                                      physics:
                                                                          const BouncingScrollPhysics(),
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      itemCount: fullMovieDetails!
                                                                          .genres!
                                                                          .length,
                                                                      itemBuilder:
                                                                          (BuildContext context,
                                                                              int index) {
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 4.0),
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => GenreMovies(
                                                                                            genres: fullMovieDetails!.genres![index],
                                                                                          )));
                                                                            },
                                                                            child:
                                                                                Chip(
                                                                              shape: RoundedRectangleBorder(
                                                                                side: const BorderSide(width: 2, style: BorderStyle.solid, color: Color(0xFFad5700)),
                                                                                borderRadius: BorderRadius.circular(20.0),
                                                                              ),
                                                                              label: Text(
                                                                                fullMovieDetails!.genres![index].genreName!,
                                                                                style: const TextStyle(fontFamily: 'Poppins'),
                                                                                // style: widget.themeData.textTheme.bodyText1,
                                                                              ),
                                                                              backgroundColor: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                        )),
                                              // GenreDisplay(
                                              //   api: Endpoints.movieDetailsUrl(
                                              //       widget.movie.id!),
                                              // ),
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
                                                child: widget
                                                        .movie.overview!.isEmpty
                                                    ? const Text(
                                                        'There is no overview for this movie')
                                                    : Text(
                                                        widget.movie.overview!,
                                                        // style: widget
                                                        //     .themeData.textTheme.caption,
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
                                                              null
                                                          ? 'Release date: N/A'
                                                          : 'Release date : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: fullMovieDetails == null
                                                    ? CircularProgressIndicator()
                                                    : TextButton(
                                                        style: ButtonStyle(
                                                            maximumSize:
                                                                MaterialStateProperty
                                                                    .all(Size(
                                                                        buttonWidth!,
                                                                        50)),
                                                            backgroundColor:
                                                                MaterialStateProperty.all(
                                                                    const Color(
                                                                        0xFFF57C00))),
                                                        onPressed: () async {
                                                          mixpanel.track(
                                                              'Most viewed movies',
                                                              properties: {
                                                                'Movie name':
                                                                    '${widget.movie.originalTitle}',
                                                                'Movie id':
                                                                    '${widget.movie.originalTitle}'
                                                              });
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return MovieStreamSelect(
                                                              movieId: widget
                                                                  .movie.id!,
                                                              movieName: widget
                                                                  .movie
                                                                  .originalTitle!,
                                                              movieImdbId:
                                                                  fullMovieDetails!
                                                                      .imdbId!,
                                                            );
                                                          }));
                                                        },
                                                        child: Row(
                                                          children: const [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                              child: Icon(
                                                                Icons
                                                                    .play_circle,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              'WATCH NOW',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  fullMovieDetails == null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: const <
                                                                Widget>[
                                                              Text(
                                                                'Cast',
                                                                style:
                                                                    kTextHeaderStyle,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : fullMovieDetails!
                                                              .cast!.isEmpty
                                                          ? const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                  child: Text(
                                                                      'There are no casts available for this movie',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center)),
                                                            )
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: const <
                                                                  Widget>[
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Text(
                                                                    'Cast',
                                                                    style:
                                                                        kTextHeaderStyle,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 160,
                                                    child:
                                                        fullMovieDetails == null
                                                            ? const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              )
                                                            : ListView.builder(
                                                                physics:
                                                                    const BouncingScrollPhysics(),
                                                                itemCount:
                                                                    fullMovieDetails!
                                                                        .cast!
                                                                        .length,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        mixpanel.track(
                                                                            'Most viewed person pages',
                                                                            properties: {
                                                                              'Person name': '${fullMovieDetails!.cast![index].name}',
                                                                              'Person id': '${fullMovieDetails!.cast![index].id}'
                                                                            });
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder:
                                                                                (context) {
                                                                          return CastDetailPage(
                                                                            cast:
                                                                                fullMovieDetails!.cast![index],
                                                                            heroId:
                                                                                '${fullMovieDetails!.cast![index].id}',
                                                                          );
                                                                        }));
                                                                      },
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            100,
                                                                        child:
                                                                            Column(
                                                                          children: <
                                                                              Widget>[
                                                                            Expanded(
                                                                              flex: 6,
                                                                              child: Hero(
                                                                                tag: '${fullMovieDetails!.cast![index].id}',
                                                                                child: SizedBox(
                                                                                  width: 75,
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(100.0),
                                                                                    child: fullMovieDetails!.cast![index].profilePath == null
                                                                                        ? Image.asset(
                                                                                            'assets/images/na_square.png',
                                                                                            fit: BoxFit.cover,
                                                                                          )
                                                                                        : FadeInImage(
                                                                                            image: NetworkImage(TMDB_BASE_IMAGE_URL + 'w500/' + fullMovieDetails!.cast![index].profilePath!),
                                                                                            fit: BoxFit.cover,
                                                                                            placeholder: const AssetImage('assets/images/loading.gif'),
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
                                                                                  fullMovieDetails!.cast![index].name!,
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
                                              // ScrollingArtists(
                                              //   api: Endpoints.getCreditsUrl(
                                              //       widget.movie.id!),
                                              //   title: 'Cast',
                                              // ),
                                              Column(
                                                children: [
                                                  fullMovieDetails == null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: const <
                                                                Widget>[
                                                              Text(
                                                                'Images',
                                                                style:
                                                                    kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: const <
                                                              Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'Images',
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
                                                      child: fullMovieDetails ==
                                                              null
                                                          ? const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : fullMovieDetails!
                                                                  .backdrops!
                                                                  .isEmpty
                                                              ? const SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 80,
                                                                  child: Center(
                                                                    child: Text(
                                                                      'This movie doesn\'t have an image provided',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                )
                                                              : CarouselSlider
                                                                  .builder(
                                                                  options:
                                                                      CarouselOptions(
                                                                    disableCenter:
                                                                        true,
                                                                    viewportFraction:
                                                                        0.8,
                                                                    enlargeCenterPage:
                                                                        false,
                                                                    autoPlay:
                                                                        true,
                                                                  ),
                                                                  itemBuilder: (BuildContext
                                                                          context,
                                                                      int index,
                                                                      pageViewIndex) {
                                                                    return Container(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              FadeInImage(
                                                                            image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                                                                'w500/' +
                                                                                fullMovieDetails!.backdrops![index].filePath!),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            placeholder:
                                                                                const AssetImage('assets/images/loading.gif'),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  itemCount:
                                                                      fullMovieDetails!
                                                                          .backdrops!
                                                                          .length,
                                                                ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // MovieImagesDisplay(
                                              //   title: 'Images',
                                              //   api: Endpoints.getImages(
                                              //       widget.movie.id!),
                                              // ),
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
                                                api: Endpoints.movieDetailsUrl(
                                                    widget.movie.id!),
                                              ),
                                              MovieInfoTable(
                                                api: Endpoints.movieDetailsUrl(
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
                                        api: Endpoints.getMovieRecommendations(
                                            widget.movie.id!, 1),
                                        movieId: widget.movie.id!,
                                      ),
                                      SimilarMoviesTab(
                                          movieId: widget.movie.id!,
                                          api: Endpoints.getSimilarMovies(
                                              widget.movie.id!, 1)),
                                    ],
                                    controller: tabController,
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
                                  : FadeInImage(
                                      image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                          'w500/' +
                                          widget.movie.posterPath!),
                                      fit: BoxFit.cover,
                                      placeholder: const AssetImage(
                                          'assets/images/loading.gif'),
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
