// ignore_for_file: avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '/models/tv.dart';
import '/widgets/tv_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import '/widgets/movie_widgets.dart';
import 'tv_stream.dart';

class EpisodeDetailPage extends StatefulWidget {
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;

  const EpisodeDetailPage({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
  }) : super(key: key);

  @override
  EpisodeDetailPageState createState() => EpisodeDetailPageState();
}

class EpisodeDetailPageState extends State<EpisodeDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<EpisodeDetailPage> {
  bool? isVisible = false;
  double? buttonWidth = 150;
  ExternalLinks? externalLinks;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed episode details', properties: {
      'TV series name': '${widget.seriesName}',
      'TV series episode name': '${widget.episodeList.name}',
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            shadowColor: isDark ? Colors.white : Colors.black,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.episodeList.name!,
              style: const TextStyle(
                color: Color(0xFFF57C00),
              ),
            )),
            expandedHeight: 360,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  SizedBox(
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
                                  ).createShader(Rect.fromLTRB(
                                      0, 0, rect.width, rect.height));
                                },
                                blendMode: BlendMode.dstIn,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.transparent)),
                                  ),
                                  child: SizedBox(
                                    height: 220,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          itemBuilder: (context, index) {
                                            return widget.episodeList
                                                        .stillPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/loading_5.gif',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    imageUrl:
                                                        '${TMDB_BASE_IMAGE_URL}original/${widget.episodeList.stillPath!}',
                                                    errorWidget:
                                                        (context, url, error) =>
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
                                              child: TopButton(
                                                  buttonText: 'Open Season'),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(children: [
                                //  titles
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          // _utilityController.toggleTitleVisibility();
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                '${widget.episodeList.seasonNumber! <= 9 ? 'S0${widget.episodeList.seasonNumber}' : 'S${widget.episodeList.seasonNumber}'} | '
                                                '${widget.episodeList.episodeNumber! <= 9 ? 'E0${widget.episodeList.episodeNumber}' : 'E${widget.episodeList.episodeNumber}'}'
                                                ''),
                                            Text(
                                              widget.episodeList.airDate ==
                                                          null ||
                                                      widget.episodeList
                                                              .airDate ==
                                                          ""
                                                  ? widget.episodeList.name!
                                                  : widget.episodeList.name!,
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
                                                    widget.seriesName!,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: isDark
                                                            ? Colors.white54
                                                            : Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ))
                      ],
                    ),
                  ),
                  Row(
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
                              percent: (widget.episodeList.voteAverage! / 10),
                              curve: Curves.ease,
                              animation: true,
                              animationDuration: 2500,
                              progressColor: Colors.orange,
                              center: Text(
                                '${widget.episodeList.voteAverage!.toStringAsFixed(1)}/10',
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          // height: 46,
                          // width: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF57C00).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.episodeList.voteCount!.toString(),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate.fixed([
            EpisodeAbout(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName,
              tvId: widget.tvId,
            )
          ]))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class EpisodeAbout extends StatefulWidget {
  const EpisodeAbout({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    this.seriesName,
  }) : super(key: key);
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;

  @override
  State<EpisodeAbout> createState() => _EpisodeAboutState();
}

class _EpisodeAboutState extends State<EpisodeAbout> {
  bool? isVisible = false;
  double? buttonWidth = 150;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    return Container(
      color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
              child: ReadMoreText(
                widget.episodeList.overview!.isEmpty
                    ? 'This season doesn\'t have an overview'
                    : widget.episodeList.overview!,
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
                    widget.episodeList.airDate == null ||
                            widget.episodeList.airDate!.isEmpty
                        ? 'Episode air date: N/A'
                        : 'Episode air date:  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: TextButton(
                style: ButtonStyle(
                    maximumSize:
                        MaterialStateProperty.all(Size(buttonWidth!, 50)),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFF57C00))),
                onPressed: () async {
                  mixpanel.track('Most viewed TV series', properties: {
                    'TV series name': '${widget.seriesName}',
                    'TV series id': '${widget.tvId}',
                    'TV series episode name': '${widget.episodeList.name}',
                    'TV series season number':
                        '${widget.episodeList.seasonNumber}',
                    'TV series episode number':
                        '${widget.episodeList.episodeNumber}'
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TVStream(
                      streamUrl:
                          'https://www.2embed.to/embed/tmdb/tv?id=${widget.tvId}&s=${widget.episodeList.seasonNumber}&e=${widget.episodeList.episodeNumber}',
                      tvSeriesName: '${widget.seriesName}',
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
            ),
            ScrollingTVEpisodeCasts(
              passedFrom: 'episode_detail',
              seasonNumber: widget.episodeList.seasonNumber!,
              episodeNumber: widget.episodeList.episodeNumber!,
              id: widget.tvId,
              api: Endpoints.getEpisodeCredits(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
            ),
            TVEpisodeImagesDisplay(
              title: 'Images',
              name: '${widget.seriesName}_${widget.episodeList.name}',
              api: Endpoints.getTVEpisodeImagesUrl(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
            ),
            TVVideosDisplay(
              api: Endpoints.getTVEpisodeVideosUrl(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
              title: 'Videos',
            ),
          ],
        ),
      ),
    );
  }
}
