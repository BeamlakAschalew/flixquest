// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/modals/tv.dart';
import 'package:cinemax/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/modals/credits.dart';
import 'package:cinemax/modals/movie.dart';
import 'package:cinemax/screens/movie_widgets.dart';

class TVDetailPage extends StatefulWidget {
  final TV tvSeries;
  final String heroId;
  final MovieDetails? md;

  const TVDetailPage({
    Key? key,
    required this.tvSeries,
    required this.heroId,
    this.md,
  }) : super(key: key);
  @override
  _TVDetailPageState createState() => _TVDetailPageState();
}

class _TVDetailPageState extends State<TVDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<TVDetailPage> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
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
                    widget.tvSeries.backdropPath == null
                        ? Image.asset(
                            'assets/images/na.jpg',
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            width: double.infinity,
                            height: double.infinity,
                            image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                'original/' +
                                widget.tvSeries.backdropPath!),
                            fit: BoxFit.cover,
                            placeholder:
                                const AssetImage('assets/images/loading_8.gif'),
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
                      api:
                          Endpoints.getMovieWatchProviders(widget.tvSeries.id!),
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
                            color: const Color(0xFF202124),
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
                                          widget.tvSeries.firstAirDate == ""
                                              ? widget.tvSeries.name!
                                              : '${widget.tvSeries.name!} (${DateTime.parse(widget.tvSeries.firstAirDate!).year})',
                                          // style: widget
                                          //     .themeData.textTheme.headline5,
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
                                                            widget.tvSeries
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
                                                              widget.tvSeries
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
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: <Widget>[
                                            TVGenreDisplay(
                                              api: Endpoints.tvDetailsUrl(
                                                  widget.tvSeries.id!),
                                            ),
                                            Row(
                                              children: const <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Text(
                                                    'Overview',
                                                    // style: widget.themeData
                                                    //     .textTheme.bodyText1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                widget.tvSeries.overview!,
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
                                                    widget.tvSeries
                                                                .firstAirDate ==
                                                            null
                                                        ? 'Release date: N/A'
                                                        : 'Release date : ${widget.tvSeries.firstAirDate}',
                                                    // style: widget.themeData
                                                    //     .textTheme.bodyText1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ScrollingTVArtists(
                                              api: Endpoints.getTVCreditsUrl(
                                                  widget.tvSeries.id!),
                                              title: 'Cast',
                                            ),
                                            MovieImagesDisplay(
                                              title: 'Images',
                                              api: Endpoints.getTVImages(
                                                  widget.tvSeries.id!),
                                            ),
                                            MovieVideosDisplay(
                                              api: Endpoints.getTVVideos(
                                                  widget.tvSeries.id!),
                                              title: 'Videos',
                                            ),
                                            MovieInfoTable(
                                              api: Endpoints.movieDetailsUrl(
                                                  widget.tvSeries.id!),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TVCastTab(
                                        api: Endpoints.getTVCreditsUrl(
                                            widget.tvSeries.id!),
                                      ),
                                      TVCrewTab(
                                        api: Endpoints.getTVCreditsUrl(
                                            widget.tvSeries.id!),
                                      ),
                                      TVRecommendationsTab(
                                          api: Endpoints.getTVRecommendations(
                                              widget.tvSeries.id!, 1)),
                                      SimilarTVTab(
                                          api: Endpoints.getSimilarTV(
                                              widget.tvSeries.id!, 1)),
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
                              child: widget.tvSeries.posterPath == null
                                  ? Image.asset(
                                      'assets/images/na.jpg',
                                      fit: BoxFit.cover,
                                    )
                                  : FadeInImage(
                                      image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                          'w500/' +
                                          widget.tvSeries.posterPath!),
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
          api: Endpoints.getMovieWatchProviders(widget.tvSeries.id!),
        );
      },
    );
  }
}
