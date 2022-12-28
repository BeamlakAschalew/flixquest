// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:cinemax/provider/mixpanel_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../provider/adultmode_provider.dart';
import '../../provider/imagequality_provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/models/movie.dart';
import '/widgets/movie_widgets.dart';
import 'package:intl/intl.dart';

import '/widgets/new_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<MixpanelProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed movie pages', properties: {
      'Movie name': '${widget.movie.originalTitle}',
      'Movie id': '${widget.movie.id}',
      'Is Movie adult?': '${widget.movie.adult}'
    });
  }

  final scrollController = ScrollController();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    var movieTabs = <Widget>[
      About(isDark: isDark, movie: widget.movie),
      CastTab(
        api: Endpoints.getCreditsUrl(widget.movie.id!),
      ),
      CrewTab(
        api: Endpoints.getCreditsUrl(widget.movie.id!),
      ),
      MovieRecommendationsTab(
        includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
        api: Endpoints.getMovieRecommendations(widget.movie.id!, 1),
        movieId: widget.movie.id!,
      ),
      SimilarMoviesTab(
          includeAdult: Provider.of<AdultmodeProvider>(context).isAdult,
          movieId: widget.movie.id!,
          api: Endpoints.getSimilarMovies(widget.movie.id!, 1)),
    ];
    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0.5,
            forceElevated: true,
            backgroundColor: Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              'Title',
              style: TextStyle(
                color: Colors.blue.withOpacity(0.9),
              ),
            )),
            expandedHeight: 440,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  // slider img/poster/title
                  movieFlexibleSpacebarComponent(
                    height: 200,
                  ),

                  const SizedBox(height: 18),

                  // ratings / lists / bookmark options
                  movieFlexibleSpacebarOptions(),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize:
                  Size(MediaQuery.of(context).size.width, kToolbarHeight),
              child: Container(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: const Color(0xFFF57C00),
                    indicatorWeight: 3,
                    unselectedLabelColor: Colors.white54,
                    labelColor: Colors.white,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                    tabs: [
                      Tab(
                        child: Text('About',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                      Tab(
                        child: Text('Cast',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                      Tab(
                        child: Text('Crew',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                      Tab(
                        child: Text('Recommendations',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                      Tab(
                        child: Text('Similar',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                    ],
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
            ),
          ),

          // body
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                // movieTabs[0],

                IndexedStack(
                  children: movieTabs,
                  index: selectedIndex,
                ),
                // const SizedBox(height: 10),
              ],
            ),
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

var tabMenuItems = <String>[
  "Overview",
  "Cast",
  "Reviews",
  "Recommended",
  "Similar",
];

class About extends StatefulWidget {
  const About({required this.isDark, required this.movie, Key? key})
      : super(key: key);
  final bool isDark;
  final Movie movie;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF202124)
                : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            GenreDisplay(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            Row(
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Overview',
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.movie.overview!.isEmpty
                  ? const Text('There is no overview for this movie')
                  : ReadMoreText(
                      widget.movie.overview!,
                      trimLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      colorClickableText: const Color(0xFFF57C00),
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'read more',
                      trimExpandedText: 'read less',
                      lessStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF57C00),
                          fontWeight: FontWeight.bold),
                      moreStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF57C00),
                          fontWeight: FontWeight.bold),
                    ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Text(
                    widget.movie.releaseDate == null ||
                            widget.movie.releaseDate!.isEmpty
                        ? 'Release date: N/A'
                        : 'Release date : ${DateTime.parse(widget.movie.releaseDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.movie.releaseDate!))}, ${DateTime.parse(widget.movie.releaseDate!).year}',
                    style: const TextStyle(fontFamily: 'PoppinsSB'),
                  ),
                ),
              ],
            ),
            WatchNowButton(
              movieId: widget.movie.id!,
              movieName: widget.movie.originalTitle,
              adult: widget.movie.adult,
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            ScrollingArtists(
              api: Endpoints.getCreditsUrl(widget.movie.id!),
              title: 'Cast',
            ),
            MovieImagesDisplay(
              title: 'Images',
              api: Endpoints.getImages(widget.movie.id!),
              name: widget.movie.originalTitle,
            ),
            MovieVideosDisplay(
              api: Endpoints.getVideos(widget.movie.id!),
              title: 'Videos',
            ),
            MovieSocialLinks(
              api: Endpoints.getExternalLinksForMovie(
                widget.movie.id!,
              ),
            ),
            BelongsToCollectionWidget(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
            MovieInfoTable(
              api: Endpoints.movieDetailsUrl(widget.movie.id!),
            ),
          ],
        ),
      ),
    );
  }
}
