import 'package:cached_network_image/cached_network_image.dart';

import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../constants/app_constants.dart';
import '/models/tv.dart';
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

import 'movie_widgets.dart';

class SeasonsDetail extends StatefulWidget {
  final Seasons seasons;
  final String heroId;
  final int? tvId;
  final String? seriesName;
  final TVDetails tvDetails;

  const SeasonsDetail({
    Key? key,
    required this.seasons,
    required this.heroId,
    required this.tvDetails,
    this.seriesName,
    this.tvId,
  }) : super(key: key);

  @override
  _SeasonsDetailState createState() => _SeasonsDetailState();
}

class _SeasonsDetailState extends State<SeasonsDetail>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SeasonsDetail> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
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
                    widget.tvDetails.backdropPath == null
                        ? Image.asset(
                            'assets/images/na_logo.png',
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeOutCurve: Curves.easeOut,
                            fadeInDuration: Duration(milliseconds: 700),
                            fadeInCurve: Curves.easeIn,
                            imageUrl: TMDB_BASE_IMAGE_URL +
                                'original/' +
                                widget.tvDetails.backdropPath!,
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
                    child: const TopButton(
                      buttonText: 'Open show',
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          widget.seasons.airDate == null ||
                                                  widget.seasons.airDate == ""
                                              ? widget.seasons.name!
                                              : '${widget.seasons.name!} (${DateTime.parse(widget.seasons.airDate!).year})',
                                          style: kTextSmallHeaderStyle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                widget.tvDetails.originalTitle!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: TabBar(
                                    isScrollable: true,
                                    indicatorColor: const Color(0xFFF57C00),
                                    indicatorWeight: 3,
                                    unselectedLabelColor: Colors.white54,
                                    labelColor: Colors.white,
                                    tabs: const [
                                      Tab(
                                        child: Text('About',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                      ),
                                      Tab(
                                        child: Text('Episodes',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                      ),
                                      Tab(
                                        child: Text('Cast',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                      ),
                                      Tab(
                                        child: Text('Crew',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                      ),
                                    ],
                                    controller: tabController,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(1, 0, 1, 3),
                                    child: TabBarView(
                                      physics: const PageScrollPhysics(),
                                      children: [
                                        SingleChildScrollView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: Container(
                                            color: const Color(0xFF202124),
                                            child: Column(
                                              children: <Widget>[
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
                                                  child: ReadMoreText(
                                                    widget.seasons.overview!
                                                            .isEmpty
                                                        ? 'This season doesn\'t have an overview'
                                                        : widget
                                                            .seasons.overview!,
                                                    trimLines: 4,
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                    colorClickableText:
                                                        const Color(0xFFF57C00),
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        'read more',
                                                    trimExpandedText:
                                                        'read less',
                                                    lessStyle: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFFF57C00),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    moreStyle: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFFF57C00),
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                        widget.seasons
                                                                    .airDate ==
                                                                null
                                                            ? 'First episode air date: N/A'
                                                            : 'First episode air date:  ${DateTime.parse(widget.seasons.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.seasons.airDate!))}, ${DateTime.parse(widget.seasons.airDate!).year}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ScrollingTVArtists(
                                                  api: Endpoints
                                                      .getTVSeasonCreditsUrl(
                                                          widget.tvDetails.id!,
                                                          widget.seasons
                                                              .seasonNumber!),
                                                  title: 'Cast',
                                                ),
                                                TVSeasonImagesDisplay(
                                                  title: 'Images',
                                                  api: Endpoints
                                                      .getTVSeasonImagesUrl(
                                                          widget.tvDetails.id!,
                                                          widget.seasons
                                                              .seasonNumber!),
                                                ),
                                                TVVideosDisplay(
                                                  api: Endpoints
                                                      .getTVSeasonVideosUrl(
                                                          widget.tvDetails.id!,
                                                          widget.seasons
                                                              .seasonNumber!),
                                                  title: 'Videos',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        EpisodeListWidget(
                                          seriesName: widget.seriesName,
                                          tvId: widget.tvDetails.id,
                                          api: Endpoints.getSeasonDetails(
                                              widget.tvDetails.id!,
                                              widget.seasons.seasonNumber!),
                                        ),
                                        TVCastTab(
                                          api: Endpoints
                                              .getFullTVSeasonCreditsUrl(
                                                  widget.tvDetails.id!,
                                                  widget.seasons.seasonNumber!),
                                        ),
                                        TVCrewTab(
                                          api: Endpoints
                                              .getFullTVSeasonCreditsUrl(
                                                  widget.tvDetails.id!,
                                                  widget.seasons.seasonNumber!),
                                        ),
                                      ],
                                      controller: tabController,
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
                              child: widget.seasons.posterPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          'w500/' +
                                          widget.tvDetails.backdropPath!,
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
}
