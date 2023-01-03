// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import '/provider/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '/models/tv.dart';
import '/widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '/widgets/movie_widgets.dart';

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
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed TV pages', properties: {
      'TV series name': '${widget.tvSeries.name}',
      'TV series id': '${widget.tvSeries.id}',
      'Is TV series adult?': '${widget.tvSeries.adult}'
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.tvSeries.firstAirDate == ""
                  ? widget.tvSeries.name!
                  : '${widget.tvSeries.name!} (${DateTime.parse(widget.tvSeries.firstAirDate!).year})',
              style: const TextStyle(
                color: Color(0xFFF57C00),
              ),
            )),
            expandedHeight: 380,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  TVDetailQuickInfo(
                      tvSeries: widget.tvSeries, heroId: widget.heroId),
                  const SizedBox(height: 18),

                  // movieDetailQuickInfo(
                  //     imageQuality: imageQuality,
                  //     heroId: widget.heroId,
                  //     movie: widget.movie,
                  //     context: context),

                  // const SizedBox(height: 18),

                  // // ratings / lists / bookmark options
                  TVDetailOptions(tvSeries: widget.tvSeries),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [TVAbout(tvSeries: widget.tvSeries)],
            ),
          ),
        ],
      ),
      // body: Stack(
      //   children: <Widget>[
      //     Column(
      //       children: <Widget>[
      //         Expanded(
      //           child: Stack(
      //             children: <Widget>[
      //               widget.tvSeries.backdropPath == null
      //                   ? Image.asset(
      //                       'assets/images/na_logo.png',
      //                       fit: BoxFit.cover,
      //                     )
      //                   : CachedNetworkImage(
      //                       fadeOutDuration: const Duration(milliseconds: 300),
      //                       fadeOutCurve: Curves.easeOut,
      //                       fadeInDuration: const Duration(milliseconds: 700),
      //                       fadeInCurve: Curves.easeIn,
      //                       imageUrl:
      //                           '${TMDB_BASE_IMAGE_URL}original/${widget.tvSeries.backdropPath!}',
      //                       imageBuilder: (context, imageProvider) => Container(
      //                         decoration: BoxDecoration(
      //                           image: DecorationImage(
      //                             image: imageProvider,
      //                             fit: BoxFit.cover,
      //                           ),
      //                         ),
      //                       ),
      //                       placeholder: (context, url) => Image.asset(
      //                         'assets/images/loading_5.gif',
      //                         fit: BoxFit.cover,
      //                       ),
      //                       errorWidget: (context, url, error) => Image.asset(
      //                         'assets/images/na_logo.png',
      //                         fit: BoxFit.cover,
      //                       ),
      //                     ),
      //               Container(
      //                 decoration: BoxDecoration(
      //                     color: Colors.white,
      //                     gradient: LinearGradient(
      //                         begin: FractionalOffset.bottomCenter,
      //                         end: FractionalOffset.topCenter,
      //                         colors: [
      //                           const Color(0xFFF57C00),
      //                           const Color(0xFFF57C00).withOpacity(0.3),
      //                           const Color(0xFFF57C00).withOpacity(0.2),
      //                           const Color(0xFFF57C00).withOpacity(0.1),
      //                         ],
      //                         stops: const [
      //                           0.0,
      //                           0.25,
      //                           0.5,
      //                           0.75
      //                         ])),
      //               )
      //             ],
      //           ),
      //         ),
      //         Expanded(
      //           child: Container(
      //             color: const Color(0xFFF57C00),
      //           ),
      //         )
      //       ],
      //     ),
      //     Column(
      //       children: <Widget>[
      //         AppBar(
      //           backgroundColor: Colors.transparent,
      //           elevation: 0,
      //           leading: Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Container(
      //               decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(50.0),
      //                   color: isDark ? Colors.black38 : Colors.white38),
      //               child: IconButton(
      //                 icon: const Icon(
      //                   Icons.arrow_back,
      //                   color: Color(0xFFF57C00),
      //                 ),
      //                 onPressed: () {
      //                   Navigator.pop(context);
      //                 },
      //               ),
      //             ),
      //           ),
      //           actions: [
      //             GestureDetector(
      //               child: WatchProvidersButton(
      //                 api:
      //                     Endpoints.getMovieWatchProviders(widget.tvSeries.id!),
      //                 onTap: () {
      //                   modalBottomSheetMenu();
      //                 },
      //               ),
      //             ),
      //           ],
      //         ),
      //         Expanded(
      //           child: Container(
      //             color: Colors.transparent,
      //             child: Stack(
      //               children: <Widget>[
      //                 SizedBox(
      //                   width: double.infinity,
      //                   height: double.infinity,
      //                   child: Padding(
      //                     padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
      //                     child: Card(
      //                       elevation: 5,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(8.0),
      //                       ),
      //                       color: isDark
      //                           ? const Color(0xFF2b2c30)
      //                           : const Color(0xFFDFDEDE),
      //                       child: Column(
      //                         children: <Widget>[
      //                           Padding(
      //                             padding: const EdgeInsets.only(left: 120.0),
      //                             child: Padding(
      //                               padding: const EdgeInsets.all(8.0),
      //                               child: Column(
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.start,
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.start,
      //                                 children: <Widget>[
      //                                   Text(
      //                                     widget.tvSeries.firstAirDate == ""
      //                                         ? widget.tvSeries.name!
      //                                         : widget.tvSeries.firstAirDate ==
      //                                                 null
      //                                             ? widget.tvSeries.name!
      //                                             : '${widget.tvSeries.name!} (${DateTime.parse(widget.tvSeries.firstAirDate!).year})',
      //                                     style: kTextSmallHeaderStyle,
      //                                     maxLines: 2,
      //                                     overflow: TextOverflow.ellipsis,
      //                                   ),
      //                                   Padding(
      //                                     padding: const EdgeInsets.all(8.0),
      //                                     child: Row(
      //                                       children: [
      //                                         Row(
      //                                           children: <Widget>[
      //                                             SizedBox(
      //                                               height: 30,
      //                                               width: 30,
      //                                               child: Image.asset(
      //                                                   'assets/images/tmdb_logo.png'),
      //                                             ),
      //                                             Column(
      //                                               children: [
      //                                                 Row(
      //                                                   children: [
      //                                                     const Padding(
      //                                                       padding:
      //                                                           EdgeInsets.only(
      //                                                               left: 8.0,
      //                                                               right: 3.0),
      //                                                       child: Icon(
      //                                                         Icons.star,
      //                                                         size: 15,
      //                                                         color: Color(
      //                                                             0xFFF57C00),
      //                                                       ),
      //                                                     ),
      //                                                     Text(
      //                                                       widget.tvSeries
      //                                                           .voteAverage!
      //                                                           .toStringAsFixed(
      //                                                               1),
      //                                                     ),
      //                                                   ],
      //                                                 ),
      //                                                 Padding(
      //                                                   padding:
      //                                                       const EdgeInsets
      //                                                               .only(
      //                                                           left: 8.0),
      //                                                   child: Row(
      //                                                     children: [
      //                                                       const Padding(
      //                                                         padding: EdgeInsets
      //                                                             .only(
      //                                                                 right:
      //                                                                     8.0),
      //                                                         child: Icon(
      //                                                             Icons
      //                                                                 .people_alt,
      //                                                             size: 15),
      //                                                       ),
      //                                                       Text(
      //                                                         widget.tvSeries
      //                                                             .voteCount!
      //                                                             .toString(),
      //                                                         style:
      //                                                             const TextStyle(
      //                                                                 fontSize:
      //                                                                     10),
      //                                                       ),
      //                                                     ],
      //                                                   ),
      //                                                 ),
      //                                               ],
      //                                             ),
      //                                           ],
      //                                         ),
      //                                       ],
      //                                     ),
      //                                   ),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                           TabBar(
      //                             isScrollable: true,
      //                             indicatorColor: const Color(0xFFF57C00),
      //                             indicatorWeight: 3,
      //                             unselectedLabelColor: Colors.white54,
      //                             labelColor: Colors.white,
      //                             tabs: [
      //                               Tab(
      //                                 child: Text('About',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                               Tab(
      //                                 child: Text('Seasons',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                               Tab(
      //                                 child: Text('Cast',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                               Tab(
      //                                 child: Text('Crew',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                               Tab(
      //                                 child: Text('Recommendations',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                               Tab(
      //                                 child: Text('Similar',
      //                                     style: TextStyle(
      //                                         fontFamily: 'Poppins',
      //                                         color: isDark
      //                                             ? Colors.white
      //                                             : Colors.black)),
      //                               ),
      //                             ],
      //                             controller: tabController,
      //                             indicatorSize: TabBarIndicatorSize.tab,
      //                           ),
      //                           Expanded(
      //                             child: Padding(
      //                               padding: const EdgeInsets.fromLTRB(
      //                                   1.6, 0, 1.6, 3),
      //                               child: TabBarView(
      //                                 physics: const PageScrollPhysics(),
      //                                 controller: tabController,
      //                                 children: [

      //                                   TVSeasonsTab(
      //                                     tvId: widget.tvSeries.id!,
      //                                     adult: widget.tvSeries.adult,
      //                                     seriesName:
      //                                         widget.tvSeries.originalName!,
      //                                     api: Endpoints.getTVSeasons(
      //                                         widget.tvSeries.id!),
      //                                   ),
      //                                   TVCastTab(
      //                                     api: Endpoints.getFullTVCreditsUrl(
      //                                         widget.tvSeries.id!),
      //                                   ),
      //                                   TVCrewTab(
      //                                     api: Endpoints.getFullTVCreditsUrl(
      //                                         widget.tvSeries.id!),
      //                                   ),
      //
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Positioned(
      //                   top: 0,
      //                   left: 40,
      //                   child: Hero(
      //                     tag: widget.heroId,
      //                     child: SizedBox(
      //                       width: 100,
      //                       height: 150,
      //                       child: ClipRRect(
      //                         borderRadius: BorderRadius.circular(8.0),
      //                         child: widget.tvSeries.posterPath == null
      //                             ? Image.asset(
      //                                 'assets/images/na_logo.png',
      //                                 fit: BoxFit.cover,
      //                               )
      //                             : CachedNetworkImage(
      //                                 fadeOutDuration:
      //                                     const Duration(milliseconds: 300),
      //                                 fadeOutCurve: Curves.easeOut,
      //                                 fadeInDuration:
      //                                     const Duration(milliseconds: 700),
      //                                 fadeInCurve: Curves.easeIn,
      //                                 imageUrl: TMDB_BASE_IMAGE_URL +
      //                                     imageQuality +
      //                                     widget.tvSeries.posterPath!,
      //                                 imageBuilder: (context, imageProvider) =>
      //                                     Container(
      //                                   decoration: BoxDecoration(
      //                                     image: DecorationImage(
      //                                       image: imageProvider,
      //                                       fit: BoxFit.cover,
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 placeholder: (context, url) =>
      //                                     Image.asset(
      //                                   'assets/images/loading.gif',
      //                                   fit: BoxFit.cover,
      //                                 ),
      //                                 errorWidget: (context, url, error) =>
      //                                     Image.asset(
      //                                   'assets/images/na_logo.png',
      //                                   fit: BoxFit.cover,
      //                                 ),
      //                               ),
      //                       ),
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ),
      //         )
      //       ],
      //     ),
      //   ],
      // ),
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

class TVDetailQuickInfo extends StatelessWidget {
  const TVDetailQuickInfo({
    Key? key,
    required this.tvSeries,
    required this.heroId,
  }) : super(key: key);

  final TV tvSeries;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
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
                // Obx(
                //   () =>

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
                              return tvSeries.backdropPath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Image.asset(
                                        'assets/images/loading_5.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl:
                                          '${TMDB_BASE_IMAGE_URL}original/${tvSeries.backdropPath!}',
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
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  child: WatchProvidersButton(
                                    api: Endpoints.getMovieWatchProviders(
                                        tvSeries.id!),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (builder) {
                                          return WatchProvidersDetails(
                                            api: Endpoints.getTVWatchProviders(
                                                tvSeries.id!),
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
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              width: 94,
                              height: 140,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Image.asset(
                                'assets/images/loading.gif',
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/na_logo.png',
                                fit: BoxFit.cover,
                              ),
                              imageUrl: TMDB_BASE_IMAGE_URL +
                                  imageQuality +
                                  tvSeries.posterPath!,
                            ),
                          ),
                        )),
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
                            tvSeries.firstAirDate == ""
                                ? tvSeries.name!
                                : '${tvSeries.name!} (${DateTime.parse(tvSeries.firstAirDate!).year})',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontFamily: 'PoppinsSB'),
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

class TVDetailOptions extends StatefulWidget {
  const TVDetailOptions({Key? key, required this.tvSeries}) : super(key: key);

  final TV tvSeries;

  @override
  State<TVDetailOptions> createState() => _TVDetailOptionsState();
}

class _TVDetailOptionsState extends State<TVDetailOptions> {
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  bool visible = false;
  bool? isBookmarked;

  @override
  void initState() {
    bookmarkChecker();
    super.initState();
  }

  void bookmarkChecker() async {
    var iB = await tvDatabaseController.contain(widget.tvSeries.id!);
    setState(() {
      isBookmarked = iB;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user score circle percent indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 30,
                percent: (widget.tvSeries.voteAverage! / 10),
                curve: Curves.ease,
                animation: true,
                animationDuration: 2500,
                progressColor: Colors.orange,
                center: Text(
                  '${widget.tvSeries.voteAverage!.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'User\nScore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            // height: 46,
            // width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.tvSeries.voteCount!.toString(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Vote\nCounts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Container(
            child: ElevatedButton(
                onPressed: () {
                  if (isBookmarked == false) {
                    tvDatabaseController.insertTV(widget.tvSeries);
                    setState(() {
                      isBookmarked = true;
                    });
                  } else if (isBookmarked == true) {
                    tvDatabaseController.deleteTV(widget.tvSeries.id!);
                    setState(() {
                      isBookmarked = false;
                    });
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
        )
      ],
    );
  }
}

class TVAbout extends StatefulWidget {
  const TVAbout({Key? key, required this.tvSeries}) : super(key: key);

  final TV tvSeries;

  @override
  State<TVAbout> createState() => _TVAboutState();
}

class _TVAboutState extends State<TVAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      //  physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            TVGenreDisplay(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!),
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
              child: widget.tvSeries.overview!.isEmpty ||
                      widget.tvSeries.overview == null
                  ? const Text('There is no overview for this TV series :(')
                  : ReadMoreText(
                      widget.tvSeries.overview!,
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
                    widget.tvSeries.firstAirDate == null ||
                            widget.tvSeries.firstAirDate!.isEmpty
                        ? 'First episode air date: N/A'
                        : 'First episode air date : ${DateTime.parse(widget.tvSeries.firstAirDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.tvSeries.firstAirDate!))}, ${DateTime.parse(widget.tvSeries.firstAirDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            ScrollingTVArtists(
              api: Endpoints.getTVCreditsUrl(widget.tvSeries.id!),
              title: 'Cast',
              id: widget.tvSeries.id!,
            ),
            ScrollingTVCreators(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!),
              title: 'Created by',
            ),
            SeasonsList(
              tvId: widget.tvSeries.id!,
              seriesName: widget.tvSeries.originalName!,
              title: 'Seasons',
              adult: widget.tvSeries.adult,
              api: Endpoints.getTVSeasons(widget.tvSeries.id!),
            ),
            TVImagesDisplay(
              title: 'Images',
              api: Endpoints.getTVImages(widget.tvSeries.id!),
              name: widget.tvSeries.originalName,
            ),
            TVVideosDisplay(
              api: Endpoints.getTVVideos(widget.tvSeries.id!),
              api2: Endpoints.tvDetailsUrl(widget.tvSeries.id!),
              title: 'Videos',
            ),
            TVSocialLinks(
              api: Endpoints.getExternalLinksForTV(widget.tvSeries.id!),
            ),
            TVInfoTable(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!),
            ),
            TVRecommendationsTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                api: Endpoints.getTVRecommendations(widget.tvSeries.id!, 1)),
            SimilarTVTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                api: Endpoints.getSimilarTV(widget.tvSeries.id!, 1)),
          ],
        ),
      ),
    );
  }
}
