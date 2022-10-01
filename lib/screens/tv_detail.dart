// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/provider/adultmode_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:startapp_sdk/startapp.dart';
import '../constants/app_constants.dart';
import '../provider/darktheme_provider.dart';
import '../provider/imagequality_provider.dart';
import '/models/tv.dart';
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/screens/movie_widgets.dart';
import 'package:intl/intl.dart';

class TVDetailPage extends StatefulWidget {
  final TV tvSeries;
  final String heroId;

  const TVDetailPage({
    Key? key,
    required this.tvSeries,
    required this.heroId,
  }) : super(key: key);
  @override
  TVDetailPageState createState() => TVDetailPageState();
}

class TVDetailPageState extends State<TVDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<TVDetailPage> {
  late TabController tabController;
  var startAppSdkTVDetail = StartAppSdk();
  var startAppSdkTVDetail1 = StartAppSdk();
  StartAppBannerAd? bannerAdTVDetail;
  StartAppBannerAd? bannerAdTVDetail1;

  void getBannerADForTVDetail() {
    startAppSdkTVDetail
        .loadBannerAd(StartAppBannerType.BANNER)
        .then((bannerAd) {
      setState(() {
        bannerAdTVDetail = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });

    startAppSdkTVDetail1
        .loadBannerAd(StartAppBannerType.BANNER)
        .then((bannerAd) {
      setState(() {
        bannerAdTVDetail1 = bannerAd;
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
    tabController = TabController(length: 6, vsync: this);
    getBannerADForTVDetail();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
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
                            'assets/images/na_logo.png',
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            fadeOutDuration: const Duration(milliseconds: 300),
                            fadeOutCurve: Curves.easeOut,
                            fadeInDuration: const Duration(milliseconds: 700),
                            fadeInCurve: Curves.easeIn,
                            imageUrl:
                                '${TMDB_BASE_IMAGE_URL}original/${widget.tvSeries.backdropPath!}',
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
                                          widget.tvSeries.firstAirDate == ""
                                              ? widget.tvSeries.name!
                                              : widget.tvSeries.firstAirDate ==
                                                      null
                                                  ? widget.tvSeries.name!
                                                  : '${widget.tvSeries.name!} (${DateTime.parse(widget.tvSeries.firstAirDate!).year})',
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
                                      child: Text('Seasons',
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
                                          //  physics: const BouncingScrollPhysics(),
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
                                                        style: kTextHeaderStyle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: widget
                                                              .tvSeries
                                                              .overview!
                                                              .isEmpty ||
                                                          widget.tvSeries
                                                                  .overview ==
                                                              null
                                                      ? const Text(
                                                          'There is no overview for this TV series :(')
                                                      : ReadMoreText(
                                                          widget.tvSeries
                                                              .overview!,
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
                                                        widget.tvSeries.firstAirDate ==
                                                                    null ||
                                                                widget
                                                                    .tvSeries
                                                                    .firstAirDate!
                                                                    .isEmpty
                                                            ? 'First episode air date: N/A'
                                                            : 'First episode air date : ${DateTime.parse(widget.tvSeries.firstAirDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.tvSeries.firstAirDate!))}, ${DateTime.parse(widget.tvSeries.firstAirDate!).year}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                bannerAdTVDetail != null
                                                    ? StartAppBanner(
                                                        bannerAdTVDetail!)
                                                    : Container(),
                                                ScrollingTVArtists(
                                                  api:
                                                      Endpoints.getTVCreditsUrl(
                                                          widget.tvSeries.id!),
                                                  title: 'Cast',
                                                ),
                                                ScrollingTVCreators(
                                                  api: Endpoints.tvDetailsUrl(
                                                      widget.tvSeries.id!),
                                                  title: 'Created by',
                                                ),
                                                SeasonsList(
                                                  tvId: widget.tvSeries.id!,
                                                  seriesName: widget
                                                      .tvSeries.originalName!,
                                                  title: 'Seasons',
                                                  adult: widget.tvSeries.adult,
                                                  api: Endpoints.getTVSeasons(
                                                      widget.tvSeries.id!),
                                                ),
                                                TVImagesDisplay(
                                                  title: 'Images',
                                                  api: Endpoints.getTVImages(
                                                      widget.tvSeries.id!),
                                                  name: widget
                                                      .tvSeries.originalName,
                                                ),
                                                bannerAdTVDetail1 != null
                                                    ? StartAppBanner(
                                                        bannerAdTVDetail1!)
                                                    : Container(),
                                                TVVideosDisplay(
                                                  api: Endpoints.getTVVideos(
                                                      widget.tvSeries.id!),
                                                  api2: Endpoints.tvDetailsUrl(
                                                      widget.tvSeries.id!),
                                                  title: 'Videos',
                                                ),
                                                TVSocialLinks(
                                                  api: Endpoints
                                                      .getExternalLinksForTV(
                                                          widget.tvSeries.id!),
                                                ),
                                                TVInfoTable(
                                                  api: Endpoints.tvDetailsUrl(
                                                      widget.tvSeries.id!),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TVSeasonsTab(
                                          tvId: widget.tvSeries.id!,
                                          adult: widget.tvSeries.adult,
                                          seriesName:
                                              widget.tvSeries.originalName!,
                                          api: Endpoints.getTVSeasons(
                                              widget.tvSeries.id!),
                                        ),
                                        TVCastTab(
                                          api: Endpoints.getFullTVCreditsUrl(
                                              widget.tvSeries.id!),
                                        ),
                                        TVCrewTab(
                                          api: Endpoints.getFullTVCreditsUrl(
                                              widget.tvSeries.id!),
                                        ),
                                        TVRecommendationsTab(
                                            includeAdult:
                                                Provider.of<AdultmodeProvider>(
                                                        context)
                                                    .isAdult,
                                            tvId: widget.tvSeries.id!,
                                            api: Endpoints.getTVRecommendations(
                                                widget.tvSeries.id!, 1)),
                                        SimilarTVTab(
                                            includeAdult:
                                                Provider.of<AdultmodeProvider>(
                                                        context)
                                                    .isAdult,
                                            tvId: widget.tvSeries.id!,
                                            api: Endpoints.getSimilarTV(
                                                widget.tvSeries.id!, 1)),
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
                              child: widget.tvSeries.posterPath == null
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
                                          widget.tvSeries.posterPath!,
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
        return TVWatchProvidersDetails(
          api: Endpoints.getTVWatchProviders(widget.tvSeries.id!),
        );
      },
    );
  }
}
