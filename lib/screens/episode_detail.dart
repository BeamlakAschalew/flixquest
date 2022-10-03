// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:cinemax/screens/tv_stream_select.dart';
import 'package:cinemax/screens/tv_video_loader.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../provider/mixpanel_provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../constants/app_constants.dart';
import '/models/tv.dart';
import '/screens/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'movie_widgets.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final bool? adult;

  const EpisodeDetailPage({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
    required this.adult,
  }) : super(key: key);

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  late TabController tabController;
  bool? isVisible = false;
  double? buttonWidth = 150;
  ExternalLinks? externalLinks;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  void streamSelectBottomSheet(
      {required String mediaType,
      required String imdbId,
      required String videoTitle,
      required int seasonNumber,
      required int episodeNumber,
      required int tvId,
      required String episodeName,
      required String tvSeriesName}) {
    final isDark =
        Provider.of<DarkthemeProvider>(context, listen: false).darktheme;
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
              color: isDark ? const Color(0xFF202124) : const Color(0xFFFFFFFF),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Watch with:',
                          style: kTextSmallHeaderStyle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: ((context) {
                            return TVVideoLoader(
                              imdbID: imdbId,
                              videoTitle: videoTitle,
                              episodeNumber: episodeNumber,
                              seasonNumber: seasonNumber,
                              isDark: isDark,
                            );
                          })));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFF57C00),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Cinemax player. AD free, highly recommended, but without subtitles',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: ((context) {
                            return TVStreamSelect(
                              episodeName: episodeName,
                              seasonNumber: seasonNumber,
                              tvSeriesId: tvId,
                              tvSeriesName: tvSeriesName,
                              tvSeriesImdbId: imdbId,
                              episodeNumber: episodeNumber,
                            );
                          })));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFF57C00),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              '3rd party websites. With ADs, not recommended, with subtitles',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    widget.episodeList.stillPath == null
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
                                '${TMDB_BASE_IMAGE_URL}original/${widget.episodeList.stillPath!}',
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
                actions: const [
                  TopButton(
                    buttonText: 'Open season',
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 0.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${widget.episodeList.seasonNumber! <= 9 ? 'S0${widget.episodeList.seasonNumber}' : 'S${widget.episodeList.seasonNumber}'} | '
                                                '${widget.episodeList.episodeNumber! <= 9 ? 'E0${widget.episodeList.episodeNumber}' : 'E${widget.episodeList.episodeNumber}'}'
                                                '',
                                                style: kTextSmallHeaderStyle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.episodeList.name
                                                          .toString(),
                                                      maxLines: 2,
                                                      style:
                                                          kTextSmallHeaderStyle,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: Text(
                                                        widget.seriesName!,
                                                        style: TextStyle(
                                                            color: isDark
                                                                ? Colors.white54
                                                                : Colors
                                                                    .black54),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
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
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 8.0,
                                                                      right:
                                                                          3.0),
                                                              child: Icon(
                                                                Icons.star,
                                                                size: 15,
                                                                color: Color(
                                                                    0xFFF57C00),
                                                              ),
                                                            ),
                                                            Text(
                                                              widget.episodeList
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
                                                                widget
                                                                    .episodeList
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
                                        child: Text('Guest Stars',
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
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        1.6, 0, 1.6, 3),
                                    child: TabBarView(
                                      controller: tabController,
                                      children: [
                                        Container(
                                          color: isDark
                                              ? const Color(0xFF202124)
                                              : const Color(0xFFFFFFFF),
                                          child: SingleChildScrollView(
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
                                                    widget.episodeList.overview!
                                                            .isEmpty
                                                        ? 'This season doesn\'t have an overview'
                                                        : widget.episodeList
                                                            .overview!,
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
                                                        widget.episodeList
                                                                        .airDate ==
                                                                    null ||
                                                                widget
                                                                    .episodeList
                                                                    .airDate!
                                                                    .isEmpty
                                                            ? 'Episode air date: N/A'
                                                            : 'Episode air date:  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'PoppinsSB',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  child: TextButton(
                                                    style: ButtonStyle(
                                                        maximumSize:
                                                            MaterialStateProperty
                                                                .all(Size(
                                                                    buttonWidth!,
                                                                    50)),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(const Color(
                                                                    0xFFF57C00))),
                                                    onPressed: () async {
                                                      mixpanel.track(
                                                          'Most viewed TV series',
                                                          properties: {
                                                            'TV series name':
                                                                '${widget.seriesName}',
                                                            'TV series id':
                                                                '${widget.tvId}',
                                                            'TV series episode name':
                                                                '${widget.episodeList.name}',
                                                            'TV series season number':
                                                                '${widget.episodeList.seasonNumber}',
                                                            'TV series episode number':
                                                                '${widget.episodeList.episodeNumber}',
                                                            'Is TV series adult?':
                                                                '${widget.adult}'
                                                          });
                                                      setState(() {
                                                        isVisible = true;
                                                        buttonWidth = 170;
                                                      });
                                                      await fetchSocialLinks(Endpoints
                                                              .getExternalLinksForTV(
                                                                  widget.tvId!))
                                                          .then((value) {
                                                        setState(() {
                                                          externalLinks = value;
                                                        });
                                                      });
                                                      setState(() {
                                                        isVisible = false;
                                                        buttonWidth = 150;
                                                      });
                                                      streamSelectBottomSheet(
                                                          mediaType: 'tv',
                                                          imdbId: externalLinks!
                                                              .imdbId!,
                                                          videoTitle:
                                                              '${widget.seriesName} ${widget.episodeList.seasonNumber! <= 9 ? 'S0${widget.episodeList.seasonNumber}' : 'S${widget.episodeList.seasonNumber}'} | '
                                                              '${widget.episodeList.episodeNumber! <= 9 ? 'E0${widget.episodeList.episodeNumber}' : 'E${widget.episodeList.episodeNumber}'}, ${widget.episodeList.name}'
                                                              '',
                                                          episodeNumber: widget
                                                              .episodeList
                                                              .episodeNumber!,
                                                          seasonNumber: widget
                                                              .episodeList
                                                              .seasonNumber!,
                                                          tvId: widget.tvId!,
                                                          episodeName: widget
                                                              .episodeList
                                                              .name!,
                                                          tvSeriesName: widget
                                                              .seriesName!);
                                                      // Navigator.push(context,
                                                      //     MaterialPageRoute(
                                                      //         builder:
                                                      //             (context) {
                                                      //   return StreamOptionSelect(
                                                      //       mediaType: 'tv');

                                                      // return TVVideoLoader(
                                                      //   imdbID: externalLinks!
                                                      //       .imdbId!,
                                                      //   episodeNumber: widget
                                                      //       .episodeList
                                                      //       .episodeNumber!,
                                                      //   seasonNumber: widget
                                                      //       .episodeList
                                                      //       .seasonNumber!,
                                                      //   videoTitle:
                                                      //       '${widget.episodeList.seasonNumber! <= 9 ? 'S0${widget.episodeList.seasonNumber}' : 'S${widget.episodeList.seasonNumber}'} | '
                                                      //       '${widget.episodeList.episodeNumber! <= 9 ? 'E0${widget.episodeList.episodeNumber}' : 'E${widget.episodeList.episodeNumber}'}'
                                                      //       '',
                                                      // );
                                                      // }));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Icon(
                                                            Icons.play_circle,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const Text(
                                                          'WATCH NOW',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Visibility(
                                                          visible: isVisible!,
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 10.0,
                                                            ),
                                                            child: SizedBox(
                                                              height: 16,
                                                              width: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                ScrollingTVEpisodeCasts(
                                                  api: Endpoints
                                                      .getEpisodeCredits(
                                                          widget.tvId!,
                                                          widget.episodeList
                                                              .seasonNumber!,
                                                          widget.episodeList
                                                              .episodeNumber!),
                                                ),
                                                TVEpisodeImagesDisplay(
                                                  title: 'Images',
                                                  name:
                                                      '${widget.seriesName}_${widget.episodeList.name}',
                                                  api: Endpoints
                                                      .getTVEpisodeImagesUrl(
                                                          widget.tvId!,
                                                          widget.episodeList
                                                              .seasonNumber!,
                                                          widget.episodeList
                                                              .episodeNumber!),
                                                ),
                                                TVVideosDisplay(
                                                  api: Endpoints
                                                      .getTVEpisodeVideosUrl(
                                                          widget.tvId!,
                                                          widget.episodeList
                                                              .seasonNumber!,
                                                          widget.episodeList
                                                              .episodeNumber!),
                                                  title: 'Videos',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TVEpisodeCastTab(
                                            api: Endpoints.getEpisodeCredits(
                                                widget.tvId!,
                                                widget
                                                    .episodeList.seasonNumber!,
                                                widget.episodeList
                                                    .episodeNumber!)),
                                        TVCrewTab(
                                            api: Endpoints.getEpisodeCredits(
                                                widget.tvId!,
                                                widget
                                                    .episodeList.seasonNumber!,
                                                widget.episodeList
                                                    .episodeNumber!)),
                                        TVEpisodeGuestStarsTab(
                                            api: Endpoints.getEpisodeCredits(
                                                widget.tvId!,
                                                widget
                                                    .episodeList.seasonNumber!,
                                                widget.episodeList
                                                    .episodeNumber!)),
                                      ],
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
