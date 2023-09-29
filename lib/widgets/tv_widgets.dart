// ignore_for_file: avoid_unnecessary_containers
import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:readmore/readmore.dart';
import '../controllers/bookmark_database_controller.dart';
import '../controllers/recently_watched_database_controller.dart';
import '../models/recently_watched.dart';
import '../provider/recently_watched_provider.dart';
import '../screens/tv/tv_video_loader.dart';
import '../screens/tv/tvdetail_castandcrew.dart';
import '../screens/tv/tvepisode_castandcrew.dart';
import '../screens/tv/tvseason_castandcrew.dart';
import '../ui_components/tv_ui_components.dart';
import '/models/dropdown_select.dart';
import '/models/filter_chip.dart';
import '/provider/settings_provider.dart';
import '/screens/person/guest_star_detail.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '/api/endpoints.dart';
import '/constants/api_constants.dart';
import '../constants/app_constants.dart';
import '/models/credits.dart';
import '/models/function.dart';
import '/models/genres.dart';
import '/models/images.dart';
import '/models/movie.dart';
import '/models/social_icons_icons.dart';
import '/models/tv.dart';
import '/models/videos.dart';
import '/models/watch_providers.dart';
import '/screens/person/cast_detail.dart';
import '/screens/person/createdby_detail.dart';
import '/screens/tv/episode_detail.dart';
import '/screens/tv/seasons_detail.dart';
import '/screens/tv/streaming_services_tvshows.dart';
import '/screens/tv/tv_detail.dart';
import '/screens/tv/genre_tv.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '/screens/person/crew_detail.dart';
import '/screens/common/photoview.dart';
import '/screens/tv/main_tv_list.dart';
import 'movie_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/widgets/common_widgets.dart';

class MainTVDisplay extends StatefulWidget {
  const MainTVDisplay({
    Key? key,
  }) : super(key: key);

  @override
  State<MainTVDisplay> createState() => _MainTVDisplayState();
}

class _MainTVDisplayState extends State<MainTVDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rEpisodes = Provider.of<RecentProvider>(context).episodes;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      child: ListView(
        children: [
          DiscoverTV(
              includeAdult: Provider.of<SettingsProvider>(context).isAdult),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("popular"),
            api: Endpoints.popularTVUrl(1, lang),
            discoverType: 'popular',
            isTrending: false,
          ),
          rEpisodes.isEmpty
              ? Container()
              : ScrollingRecentEpisodes(episodesList: rEpisodes),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("trending_this_week"),
            api: Endpoints.trendingTVUrl(1, lang),
            discoverType: 'trending',
            isTrending: true,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("top_rated"),
            api: Endpoints.topRatedTVUrl(1, lang),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("airing_today"),
            api: Endpoints.airingTodayUrl(1, lang),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            includeAdult: Provider.of<SettingsProvider>(context).isAdult,
            title: tr("on_the_air"),
            api: Endpoints.onTheAirUrl(1, lang),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          TVGenreListGrid(api: Endpoints.tvGenresUrl(lang)),
          const TVShowsFromWatchProviders(),
        ],
      ),
    );
  }
}

class DiscoverTV extends StatefulWidget {
  final bool includeAdult;
  const DiscoverTV({required this.includeAdult, Key? key}) : super(key: key);
  @override
  DiscoverTVState createState() => DiscoverTVState();
}

class DiscoverTVState extends State<DiscoverTV>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;
  List<TV>? tvList;
  YearDropdownData yearDropdownData = YearDropdownData();
  TVGenreFilterChipData tvGenreFilterChipData = TVGenreFilterChipData();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    List<String> years = yearDropdownData.yearsList.getRange(1, 25).toList();
    List<TVGenreFilterChipWidget> genres = tvGenreFilterChipData.tvGenreList;
    years.shuffle();
    genres.shuffle();
    fetchTV('$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY&sort_by=popularity.desc&watch_region=US&first_air_date_year=${years.first}&with_genres=${genres.first.genreValue}')
        .then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tr("featured_tv_shows"),
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 350,
          child: tvList == null
              ? discoverMoviesAndTVShimmer(isDark)
              : tvList!.isEmpty
                  ? Center(
                      child: Text(
                        tr("wow_odd"),
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
                                      builder: (context) => TVDetailPage(
                                          tvSeries: tvList![index],
                                          heroId: '${tvList![index].id}')));
                            },
                            child: Hero(
                              tag: '${tvList![index].id}',
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
                                  imageUrl: tvList![index].posterPath == null
                                      ? ''
                                      : TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          tvList![index].posterPath!,
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
                                      discoverImageShimmer(isDark),
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
                      itemCount: tvList!.length,
                    ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTV extends StatefulWidget {
  final String api, title;
  final dynamic discoverType;
  final bool isTrending;
  final bool? includeAdult;
  const ScrollingTV({
    Key? key,
    required this.api,
    required this.title,
    this.discoverType,
    required this.isTrending,
    required this.includeAdult,
  }) : super(key: key);
  @override
  ScrollingTVState createState() => ScrollingTVState();
}

class ScrollingTVState extends State<ScrollingTV>
    with AutomaticKeepAliveClientMixin {
  late int index;
  List<TV>? tvList;
  final ScrollController _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.title,
                    style: kTextHeaderStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MainTVList(
                          api: widget.api,
                          discoverType: widget.discoverType,
                          isTrending: widget.isTrending,
                          includeAdult: widget.includeAdult,
                          title: widget.title);
                    }));
                  },
                  style: ButtonStyle(
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(tr("view_all")),
                  ),
                )),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: tvList == null
              ? scrollingMoviesAndTVShimmer(isDark)
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tvList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TVDetailPage(
                                            tvSeries: tvList![index],
                                            heroId:
                                                '${tvList![index].id}${widget.title}')));
                              },
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${tvList![index].id}${widget.title}',
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: tvList![index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_rect.png',
                                                        fit: BoxFit.cover,
                                                      )
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
                                                        imageUrl: tvList![index]
                                                                    .posterPath ==
                                                                null
                                                            ? ''
                                                            : TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvList![index]
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
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_rect.png',
                                                          fit: BoxFit.cover,
                                                        ),
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
                                                      color: isDark
                                                          ? Colors.black45
                                                          : Colors.white60),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                      ),
                                                      Text(tvList![index]
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
                                          tvList![index].name!,
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
                        child: horizontalLoadMoreShimmer(isDark),
                      ),
                    ),
                  ],
                ),
        ),
        Divider(
          color: !isDark ? Colors.black54 : Colors.white54,
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

class ScrollingRecentEpisodes extends StatefulWidget {
  const ScrollingRecentEpisodes({required this.episodesList, Key? key})
      : super(key: key);

  final List<RecentEpisode> episodesList;

  @override
  State<ScrollingRecentEpisodes> createState() =>
      _ScrollingRecentEpisodesState();
}

class _ScrollingRecentEpisodesState extends State<ScrollingRecentEpisodes> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tr("recently_watched"),
                style: kTextHeaderStyle,
              ),
            ),
            // Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: TextButton(
            //       onPressed: () {
            //         Navigator.push(context,
            //             MaterialPageRoute(builder: (context) {
            //           return const TVVideoLoader(download: false, metadata: []);
            //         }));
            //       },
            //       style: ButtonStyle(
            //           maximumSize:
            //               MaterialStateProperty.all(const Size(200, 60)),
            //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
          height: 280,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.episodesList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    final recentEpisodes =
                        Provider.of<RecentProvider>(context, listen: false);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          recentEpisodes.deleteEpisode(
                              widget.episodesList[index].id!,
                              widget.episodesList[index].episodeNum!,
                              widget.episodesList[index].seasonNum!);
                        },
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TVVideoLoader(
                                        download: false,
                                        metadata: [
                                          widget.episodesList[index].id,
                                          widget.episodesList[index].seriesName,
                                          widget
                                              .episodesList[index].episodeName,
                                          widget.episodesList[index].episodeNum,
                                          widget.episodesList[index].seasonNum,
                                          widget
                                              .episodesList[index].totalSeasons,
                                          widget
                                              .episodesList[index].backdropPath,
                                          widget.episodesList[index].posterPath,
                                          widget.episodesList[index].elapsed
                                        ],
                                      )));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 8,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: widget.episodesList[index]
                                                    .posterPath ==
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
                                                imageUrl: widget
                                                            .episodesList[index]
                                                            .posterPath ==
                                                        null
                                                    ? ''
                                                    : TMDB_BASE_IMAGE_URL +
                                                        imageQuality +
                                                        widget
                                                            .episodesList[index]
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
                                                        isDark),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/na_rect.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          alignment: Alignment.center,
                                          width: 70,
                                          height: 22,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.85)),
                                          child: Row(
                                            children: [
                                              Text(
                                                  '${widget.episodesList[index].seasonNum! <= 9 ? 'S0${widget.episodesList[index].seasonNum!}' : 'S${widget.episodesList[index].seasonNum!}'} | '
                                                  '${widget.episodesList[index].episodeNum! <= 9 ? 'E0${widget.episodesList[index].episodeNum!}' : 'E${widget.episodesList[index].episodeNum!}'}'
                                                  '',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withOpacity(0.85)))
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          child: LinearProgressIndicator(
                                            value: (widget.episodesList[index]
                                                    .elapsed! /
                                                (widget.episodesList[index]
                                                        .remaining! +
                                                    widget.episodesList[index]
                                                        .elapsed!)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.episodesList[index].seriesName!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Text(
                                    widget.episodesList[index].episodeName!,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
          color: !isDark ? Colors.black54 : Colors.white54,
          thickness: 1,
          endIndent: 20,
          indent: 10,
        ),
      ],
    );
  }
}

class ScrollingTVArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  final int id;
  final int? episodeNumber;
  final int? seasonNumber;
  final String passedFrom;
  const ScrollingTVArtists(
      {Key? key,
      this.api,
      this.title,
      this.tapButtonText,
      required this.id,
      this.episodeNumber,
      this.seasonNumber,
      required this.passedFrom})
      : super(key: key);
  @override
  ScrollingTVArtistsState createState() => ScrollingTVArtistsState();
}

class ScrollingTVArtistsState extends State<ScrollingTVArtists>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tr("cast"),
                style: kTextHeaderStyle,
              ),
            ),
            TextButton(
                onPressed: () {
                  if (credits != null) {
                    if (widget.passedFrom == 'seasons_detail') {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TVSeasonCastAndCrew(
                          passedFrom: widget.passedFrom,
                          id: widget.id,
                          seasonNumber: widget.seasonNumber!,
                        );
                      }));
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TVDetailCastAndCrew(
                          passedFrom: widget.passedFrom,
                          id: widget.id,
                        );
                      }));
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  maximumSize: MaterialStateProperty.all(const Size(200, 60)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                child: Text(tr("see_all_cast_crew")))
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? detailCastShimmer(isDark)
              : credits!.cast!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Center(
                            child: Text(
                          tr("no_cast_tv"),
                        )),
                      ))
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
                                      '${credits!.cast![index].creditId}'
                                      '${credits!.cast![index].castId}',
                                );
                              }));
                            },
                            child: SizedBox(
                              width: 100,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                      width: 75,
                                      child: Hero(
                                        tag: '${credits!.cast![index].id}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: credits!.cast![index]
                                                      .profilePath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_rect.png',
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
                                                  imageUrl:
                                                      TMDB_BASE_IMAGE_URL +
                                                          imageQuality +
                                                          credits!.cast![index]
                                                              .profilePath!,
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
                                                      detailCastImageShimmer(
                                                          isDark),
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

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeCasts extends StatefulWidget {
  final String? api;
  final int? id;
  final int episodeNumber;
  final int seasonNumber;
  final String passedFrom;
  const ScrollingTVEpisodeCasts({
    Key? key,
    this.api,
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.passedFrom,
  }) : super(key: key);
  @override
  ScrollingTVEpisodeCastsState createState() => ScrollingTVEpisodeCastsState();
}

class ScrollingTVEpisodeCastsState extends State<ScrollingTVEpisodeCasts>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      tr("cast"),
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.cast!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(tr("no_cast_episode"),
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tr("cast"),
                          style: kTextHeaderStyle,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            if (credits != null) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TVEpisodeCastAndCrew(
                                  episodeNumber: widget.episodeNumber,
                                  seasonNumber: widget.seasonNumber,
                                  id: widget.id!,
                                );
                              }));
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                            maximumSize:
                                MaterialStateProperty.all(const Size(200, 60)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                          child: Text(tr("see_all_cast_crew")))
                    ],
                  ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? detailCastShimmer(isDark)
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
                              heroId: '${credits!.cast![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag: '${credits!.cast![index].id}',
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
                                              imageUrl: TMDB_BASE_IMAGE_URL +
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
                                                      isDark),
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

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeGuestStars extends StatefulWidget {
  final String? api;
  const ScrollingTVEpisodeGuestStars({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  ScrollingTVEpisodeGuestStarsState createState() =>
      ScrollingTVEpisodeGuestStarsState();
}

class ScrollingTVEpisodeGuestStarsState
    extends State<ScrollingTVEpisodeGuestStars>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      tr("guest_stars"),
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.episodeGuestStars!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(tr("no_guest_episode"),
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tr("guest_stars"),
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
                  itemCount: credits!.episodeGuestStars!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name':
                                '${credits!.episodeGuestStars![index].name}',
                            'Person id':
                                '${credits!.episodeGuestStars![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return GuestStarDetailPage(
                              cast: credits!.episodeGuestStars![index],
                              heroId:
                                  '${credits!.episodeGuestStars![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag:
                                        '${credits!.episodeGuestStars![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!.episodeGuestStars![index]
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
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!
                                                      .episodeGuestStars![index]
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
                                                  scrollingImageShimmer(isDark),
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
                                    credits!.episodeGuestStars![index].name!,
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

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVEpisodeCrew extends StatefulWidget {
  final String? api;
  const ScrollingTVEpisodeCrew({
    Key? key,
    this.api,
  }) : super(key: key);
  @override
  ScrollingTVEpisodeCrewState createState() => ScrollingTVEpisodeCrewState();
}

class ScrollingTVEpisodeCrewState extends State<ScrollingTVEpisodeCrew>
    with AutomaticKeepAliveClientMixin {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      tr("crew"),
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : credits!.crew!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(tr("no_crew_episode"),
                            textAlign: TextAlign.center)),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tr("crew"),
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
                  itemCount: credits!.crew!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          mixpanel
                              .track('Most viewed person pages', properties: {
                            'Person name': '${credits!.crew![index].name}',
                            'Person id': '${credits!.crew![index].id}'
                          });
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CrewDetailPage(
                              crew: credits!.crew![index],
                              heroId: '${credits!.crew![index].id}',
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: SizedBox(
                                  width: 75,
                                  child: Hero(
                                    tag: '${credits!.crew![index].id}',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: credits!
                                                  .crew![index].profilePath ==
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
                                              imageUrl: TMDB_BASE_IMAGE_URL +
                                                  imageQuality +
                                                  credits!.crew![index]
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
                                                  scrollingImageShimmer(isDark),
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
                                    credits!.crew![index].name!,
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

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVCreators extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingTVCreators({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  ScrollingTVCreatorsState createState() => ScrollingTVCreatorsState();
}

class ScrollingTVCreatorsState extends State<ScrollingTVCreators>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(
                tr("created_by"),
                style: kTextHeaderStyle,
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: tvDetails == null
              ? detailCastShimmer(isDark)
              : tvDetails!.createdBy!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(tr("no_creators"),
                              textAlign: TextAlign.center)),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: tvDetails!.createdBy!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CreatedByPersonDetailPage(
                                  createdBy: tvDetails!.createdBy![index],
                                  heroId: '${tvDetails!.createdBy![index].id}'
                                      '${tvDetails!.createdBy![index].name}',
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
                                      tag:
                                          '${tvDetails!.createdBy![index].id!}',
                                      child: SizedBox(
                                        width: 75,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: tvDetails!.createdBy![index]
                                                      .profilePath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_rect.png',
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
                                                  imageUrl:
                                                      TMDB_BASE_IMAGE_URL +
                                                          imageQuality +
                                                          tvDetails!
                                                              .createdBy![index]
                                                              .profilePath!,
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
                                                      detailCastImageShimmer(
                                                          isDark),
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
                                        tvDetails!.createdBy![index].name!,
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

  @override
  bool get wantKeepAlive => true;
}

class TVImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const TVImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  TVImagesDisplayState createState() => TVImagesDisplayState();
}

class TVImagesDisplayState extends State<TVImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 260,
              child: tvImages == null
                  ? detailImageShimmer(isDark)
                  : CarouselSlider(
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
                                child: tvImages!.poster!.isEmpty
                                    ? SizedBox(
                                        width: 120,
                                        height: 180,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                              alignment: AlignmentDirectional
                                                  .bottomStart,
                                              children: [
                                                SizedBox(
                                                  height: 180,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: tvImages!.poster![0]
                                                                .posterPath ==
                                                            null
                                                        ? Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          )
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
                                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvImages!
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
                                                                        tvImages!
                                                                            .poster!,
                                                                    name: widget
                                                                        .name,
                                                                    imageType:
                                                                        'poster',
                                                                  );
                                                                })));
                                                              },
                                                              child: Hero(
                                                                tag: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    tvImages!
                                                                        .poster![
                                                                            0]
                                                                        .posterPath!,
                                                                child:
                                                                    Container(
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
                                                                    isDark),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color: Colors.black38,
                                                    child: Text(tvImages!
                                                                .poster!
                                                                .length ==
                                                            1
                                                        ? tr("poster_singular",
                                                            namedArgs: {
                                                                "poster": tvImages!
                                                                    .poster!
                                                                    .length
                                                                    .toString()
                                                              })
                                                        : tr("poster_plural",
                                                            namedArgs: {
                                                                "poster": tvImages!
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
                                child: tvImages!.backdrop!.isEmpty
                                    ? SizedBox(
                                        width: 120,
                                        height: 180,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                              alignment: AlignmentDirectional
                                                  .bottomStart,
                                              children: [
                                                SizedBox(
                                                  height: 180,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: tvImages!
                                                                .backdrop![0]
                                                                .filePath ==
                                                            null
                                                        ? Image.asset(
                                                            'assets/images/na_logo.png',
                                                            fit: BoxFit.cover,
                                                          )
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
                                                            imageUrl: TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvImages!
                                                                    .backdrop![
                                                                        0]
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
                                                                        tvImages!
                                                                            .backdrop!,
                                                                    name: widget
                                                                        .name,
                                                                    imageType:
                                                                        'backdrop',
                                                                  );
                                                                })));
                                                              },
                                                              child: Hero(
                                                                tag: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    tvImages!
                                                                        .backdrop![
                                                                            0]
                                                                        .filePath!,
                                                                child:
                                                                    Container(
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
                                                                    isDark),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color: Colors.black38,
                                                    child: Text(tvImages!
                                                                .backdrop!
                                                                .length ==
                                                            1
                                                        ? tr(
                                                            "backdrop_singular",
                                                            namedArgs: {
                                                                "backdrop": tvImages!
                                                                    .backdrop!
                                                                    .length
                                                                    .toString()
                                                              })
                                                        : tr("backdrop_plural",
                                                            namedArgs: {
                                                                "backdrop": tvImages!
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
                            ),
                          ],
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

class TVSeasonImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const TVSeasonImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  TVSeasonImagesDisplayState createState() => TVSeasonImagesDisplayState();
}

class TVSeasonImagesDisplayState extends State<TVSeasonImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: tvImages == null
                ? detailImageShimmer(isDark)
                : tvImages!.poster!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: Center(
                          child: Text(
                            tr("no_season_image"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.4,
                          enlargeCenterPage: false,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                        ),
                        items: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fadeOutDuration:
                                          const Duration(milliseconds: 300),
                                      fadeOutCurve: Curves.easeOut,
                                      fadeInDuration:
                                          const Duration(milliseconds: 700),
                                      fadeInCurve: Curves.easeIn,
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          tvImages!.poster![0].posterPath!,
                                      imageBuilder: (context, imageProvider) =>
                                          GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return HeroPhotoView(
                                              posters: tvImages!.poster!,
                                              name: widget.name,
                                              imageType: 'poster',
                                            );
                                          }));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(isDark),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: Colors.black38,
                                      child: Text(tvImages!.poster!.length == 1
                                          ? tr("poster_singular", namedArgs: {
                                              "poster": tvImages!.poster!.length
                                                  .toString()
                                            })
                                          : tr("poster_plural", namedArgs: {
                                              "poster": tvImages!.poster!.length
                                                  .toString()
                                            })),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

class TVEpisodeImagesDisplay extends StatefulWidget {
  final String? api, title, name;
  const TVEpisodeImagesDisplay({Key? key, this.api, this.name, this.title})
      : super(key: key);

  @override
  TVEpisodeImagesDisplayState createState() => TVEpisodeImagesDisplayState();
}

class TVEpisodeImagesDisplayState extends State<TVEpisodeImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: tvImages == null
                ? detailImageShimmer(isDark)
                : tvImages!.still!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tr("no_images"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : CarouselSlider(
                        options: CarouselOptions(
                            disableCenter: true,
                            viewportFraction: 0.8,
                            enlargeCenterPage: false,
                            autoPlay: true,
                            enableInfiniteScroll: false),
                        items: [
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional.bottomStart,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
                                          imageQuality +
                                          tvImages!.still![0].stillPath!,
                                      imageBuilder: (context, imageProvider) =>
                                          GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return HeroPhotoView(
                                              stills: tvImages!.still!,
                                              name: widget.name,
                                              imageType: 'still',
                                            );
                                          }));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          detailImageImageSimmer(isDark),
                                      errorWidget: (context, url, error) =>
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
                                    child: Text(tvImages!.still!.length == 1
                                        ? tr("still_singular", namedArgs: {
                                            "still": tvImages!.still!.length
                                                .toString()
                                          })
                                        : tr("still_plural", namedArgs: {
                                            "still": tvImages!.still!.length
                                                .toString()
                                          })),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

class TVVideosDisplay extends StatefulWidget {
  final String? api, title, api2;
  const TVVideosDisplay({Key? key, this.api, this.title, this.api2})
      : super(key: key);

  @override
  TVVideosDisplayState createState() => TVVideosDisplayState();
}

class TVVideosDisplayState extends State<TVVideosDisplay> {
  Videos? tvVideos;

  @override
  void initState() {
    super.initState();
    fetchVideos(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvVideos = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool playButtonVisibility = true;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        tvVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(widget.title!,
                        style:
                            kTextHeaderStyle /* style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.title!,
                        style:
                            kTextHeaderStyle /*style: widget.themeData!.textTheme.bodyText1*/
                        ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: tvVideos == null
                ? detailVideoShimmer(isDark)
                : tvVideos!.result!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(tr("no_video"), textAlign: TextAlign.center),
                        )),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
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
                                          tvVideos!.result![index].videoLink!),
                                      mode: LaunchMode.externalApplication);
                                },
                                child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 130,
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
                                                        '$YOUTUBE_THUMBNAIL_URL${tvVideos!.result![index].videoLink!}/hqdefault.jpg',
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
                                                            isDark),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/na_logo.png',
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
                                          tvVideos!.result![index].name!,
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
                          itemCount: tvVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class TVCastTab extends StatefulWidget {
  final String? api;
  const TVCastTab({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  TVCastTabState createState() => TVCastTabState();
}

class TVCastTabState extends State<TVCastTab>
    with AutomaticKeepAliveClientMixin<TVCastTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(child: tvCastAndCrewTabShimmer(isDark))
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Center(
                  child: Text(tr("no_cast_tv"), style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
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
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
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
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
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
                                                        castAndCrewTabImageShimmer(
                                                            isDark),
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
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(credits!.cast![index].roles![0]
                                                  .character!.isEmpty
                                              ? tr("as_empty")
                                              : tr("as", namedArgs: {
                                                  "character": credits!
                                                      .cast![index]
                                                      .roles![0]
                                                      .character!
                                                })),
                                          Text(
                                            credits!.cast![0].roles == null
                                                ? ''
                                                : credits!
                                                            .cast![index]
                                                            .roles![0]
                                                            .episodeCount! ==
                                                        1
                                                    ? tr("single_episode",
                                                        namedArgs: {
                                                            "count": credits!
                                                                .cast![index]
                                                                .roles![0]
                                                                .episodeCount!
                                                                .toString()
                                                          })
                                                    : tr("multi_episode",
                                                        namedArgs: {
                                                            "count": credits!
                                                                .cast![index]
                                                                .roles![0]
                                                                .episodeCount!
                                                                .toString()
                                                          }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
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

class TVSeasonsTab extends StatefulWidget {
  final String? api;
  final int? tvId;
  final String? seriesName;
  final bool? adult;
  const TVSeasonsTab(
      {Key? key, this.api, this.tvId, this.seriesName, required this.adult})
      : super(key: key);

  @override
  TVSeasonsTabState createState() => TVSeasonsTabState();
}

class TVSeasonsTabState extends State<TVSeasonsTab>
    with AutomaticKeepAliveClientMixin<TVSeasonsTab> {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return tvDetails == null
        ? Container(child: tvDetailsSeasonsTabShimmer(isDark))
        : tvDetails!.seasons!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Center(
                  child: Text(tr("no_season_tv"), style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: tvDetails!.seasons!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SeasonsDetail(
                                          seriesName: widget.seriesName,
                                          tvId: widget.tvId,
                                          tvDetails: tvDetails!,
                                          seasons: tvDetails!.seasons![index],
                                          heroId:
                                              '${tvDetails!.seasons![index].seasonId}')));
                            },
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
                                  bottom: 5.0,
                                  left: 15,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 30.0),
                                          child: SizedBox(
                                            width: 85,
                                            height: 130,
                                            child: Hero(
                                              tag:
                                                  '${tvDetails!.seasons![index].seasonId}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: tvDetails!
                                                            .seasons![index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      )
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvDetails!
                                                                    .seasons![
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
                                                            recommendationAndSimilarTabImageShimmer(
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_logo.png',
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
                                                tvDetails!
                                                    .seasons![index].name!,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'PoppinsSB',
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      color: !isDark
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
                  ),
                ],
              ));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVCrewTab extends StatefulWidget {
  final String? api;
  const TVCrewTab({Key? key, this.api}) : super(key: key);

  @override
  TVCrewTabState createState() => TVCrewTabState();
}

class TVCrewTabState extends State<TVCrewTab>
    with AutomaticKeepAliveClientMixin<TVCrewTab> {
  Credits? credits;

  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return credits == null
        ? Container(
            padding: const EdgeInsets.only(top: 8),
            child: movieCastAndCrewTabShimmer(isDark))
        : credits!.crew!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Center(
                  child: Text(tr("no_cast_tv"), style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.crew!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CrewDetailPage(
                                crew: credits!.crew![index],
                                heroId: '${credits!.crew![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
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
                                          tag: '${credits!.crew![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.crew![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
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
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .crew![index]
                                                                .profilePath!,
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
                                                        castAndCrewTabImageShimmer(
                                                            isDark),
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
                                            credits!.crew![index].name!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                          ),
                                          Text(credits!.crew![index].department!
                                                  .isEmpty
                                              ? tr("job_empty")
                                              : tr("job", namedArgs: {
                                                  "job": credits!
                                                      .crew![index].department!
                                                })),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
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

class TVRecommendationsTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  const TVRecommendationsTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult})
      : super(key: key);

  @override
  TVRecommendationsTabState createState() => TVRecommendationsTabState();
}

class TVRecommendationsTabState extends State<TVRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                  child: Text(
                    tr("tv_recommendations"),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: kTextHeaderStyle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: tvList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(isDark)
                : tvList!.isEmpty
                    ? Text(
                        tr("no_recommendations_tv"),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingTVList(
                                scrollController: _scrollController,
                                tvList: tvList,
                                imageQuality: imageQuality,
                                isDark: isDark),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer(isDark),
                            ),
                          ),
                        ],
                      ),
          ),
          Divider(
            color: !isDark ? Colors.black54 : Colors.white54,
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

class SimilarTVTab extends StatefulWidget {
  final String api;
  final int tvId;
  final bool? includeAdult;
  final String tvName;
  const SimilarTVTab(
      {Key? key,
      required this.api,
      required this.tvId,
      required this.includeAdult,
      required this.tvName})
      : super(key: key);

  @override
  SimilarTVTabState createState() => SimilarTVTabState();
}

class SimilarTVTabState extends State<SimilarTVTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
                  child: Text(
                    tr("tv_similar_with", namedArgs: {"show": widget.tvName}),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: kTextHeaderStyle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: tvList == null || widget.includeAdult == null
                ? scrollingMoviesAndTVShimmer(isDark)
                : tvList!.isEmpty
                    ? Text(
                        tr("no_similars_tv"),
                        textAlign: TextAlign.center,
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: HorizontalScrollingTVList(
                                scrollController: _scrollController,
                                tvList: tvList,
                                imageQuality: imageQuality,
                                isDark: isDark),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: SizedBox(
                              width: 110,
                              child: horizontalLoadMoreShimmer(isDark),
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

class TVGenreDisplay extends StatefulWidget {
  final String? api;
  const TVGenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  TVGenreDisplayState createState() => TVGenreDisplayState();
}

class TVGenreDisplayState extends State<TVGenreDisplay>
    with AutomaticKeepAliveClientMixin<TVGenreDisplay> {
  List<Genres>? genres;
  @override
  void initState() {
    super.initState();
    fetchGenre(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          genres = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Container(
        child: genres == null
            ? SizedBox(
                height: 80,
                child: detailGenreShimmer(isDark),
              )
            : genres!.isEmpty
                ? Container()
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: genres!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TVGenre(
                                            genres: genres![index],
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
                                genres![index].genreName!,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                // style: widget.themeData.textTheme.bodyText1,
                              ),
                              backgroundColor: isDark
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

class ParticularGenreTV extends StatefulWidget {
  final String api;
  final int genreId;
  final bool? includeAdult;
  const ParticularGenreTV(
      {Key? key,
      required this.api,
      required this.genreId,
      required this.includeAdult})
      : super(key: key);
  @override
  ParticularGenreTVState createState() => ParticularGenreTVState();
}

class ParticularGenreTVState extends State<ParticularGenreTV> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : tvList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    isLoading: isLoading,
                    scrollController: _scrollController))
            : tvList!.isEmpty
                ? Container(
                    child: Center(
                      child: Text(tr("no_genre_tv")),
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
                                    ? TVGridView(
                                        tvList: tvList,
                                        imageQuality: imageQuality,
                                        isDark: isDark,
                                        scrollController: _scrollController,
                                      )
                                    : TVListView(
                                        scrollController: _scrollController,
                                        tvList: tvList,
                                        isDark: isDark,
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

class TVInfoTable extends StatefulWidget {
  final String? api;
  const TVInfoTable({Key? key, this.api}) : super(key: key);

  @override
  TVInfoTableState createState() => TVInfoTableState();
}

class TVInfoTableState extends State<TVInfoTable> {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("tv_series_info"),
            style: kTextHeaderStyle,
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tvDetails == null
                    ? detailInfoTableShimmer(isDark)
                    : DataTable(dataRowMinHeight: 40, columns: [
                        DataColumn(
                            label: Text(
                          tr("original_title"),
                          style: kTableLeftStyle,
                        )),
                        DataColumn(
                          label: Text(
                            tvDetails!.originalTitle!,
                            style: kTableLeftStyle,
                          ),
                        ),
                      ], rows: [
                        DataRow(cells: [
                          DataCell(Text(
                            tr("status"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.status!.isEmpty
                              ? tr("unknown")
                              : tvDetails!.status!)),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("runtime"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.runtime!.isEmpty
                              ? '-'
                              : tvDetails!.runtime![0] == 0
                                  ? tr("not_available")
                                  : tr("runtime_mins", namedArgs: {
                                      "mins": tvDetails!.runtime![0].toString()
                                    }))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("spoken_language"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.spokenLanguages!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.spokenLanguages!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .spokenLanguages!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.spokenLanguages![index].englishName},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("total_seasons"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.numberOfSeasons! == 0
                              ? '-'
                              : '${tvDetails!.numberOfSeasons!}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("total_episodes"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(Text(tvDetails!.numberOfEpisodes! == 0
                              ? '-'
                              : '${tvDetails!.numberOfEpisodes!}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("tagline"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(
                            Text(
                              tvDetails!.tagline!.isEmpty
                                  ? '-'
                                  : tvDetails!.tagline!,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("production_companies"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.productionCompanies!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.productionCompanies!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .productionCompanies!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.productionCompanies![index].name},'),
                                      );
                                    },
                                  ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            tr("production_countries"),
                            style: kTableLeftStyle,
                          )),
                          DataCell(SizedBox(
                            height: 20,
                            width: 200,
                            child: tvDetails!.productionCountries!.isEmpty
                                ? const Text('-')
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        tvDetails!.productionCountries!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Text(tvDetails!
                                                .productionCountries!.isEmpty
                                            ? tr("not_available")
                                            : '${tvDetails!.productionCountries![index].name},'),
                                      );
                                    },
                                  ),
                          )),
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

class TVSocialLinks extends StatefulWidget {
  final String? api;
  const TVSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  TVSocialLinksState createState() => TVSocialLinksState();
}

class TVSocialLinksState extends State<TVSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    fetchSocialLinks(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("social_media_links"),
              style: kTextHeaderStyle,
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? socialMediaShimmer(isDark)
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            tr("no_social_link_tv"),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
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

class SeasonsList extends StatefulWidget {
  final String? api;
  final String? title;
  final int? tvId;
  final String? seriesName;

  const SeasonsList({
    Key? key,
    this.api,
    this.title,
    this.tvId,
    this.seriesName,
  }) : super(key: key);

  @override
  SeasonsListState createState() => SeasonsListState();
}

class SeasonsListState extends State<SeasonsList> {
  TVDetails? tvDetails;
  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
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
          child: tvDetails == null
              ? horizontalScrollingSeasonsList(isDark)
              : tvDetails!.seasons!.isEmpty
                  ? Container(
                      color: const Color(0xFF000000),
                      child: Center(
                        child: Text(tr("no_season_tv"),
                            textAlign: TextAlign.center),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: tvDetails!.seasons!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SeasonsDetail(
                                                tvId: widget.tvId,
                                                seriesName: widget.seriesName,
                                                tvDetails: tvDetails!,
                                                seasons:
                                                    tvDetails!.seasons![index],
                                                heroId:
                                                    '${tvDetails!.seasons![index].seasonNumber}')));
                                  },
                                  child: SizedBox(
                                    width: 105,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: Hero(
                                            tag:
                                                '${tvDetails!.seasons![index].seasonNumber}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: tvDetails!.seasons![index]
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
                                                      imageUrl:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              tvDetails!
                                                                  .seasons![
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
                                                              isDark),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              tvDetails!.seasons![index].name!,
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

class EpisodeListWidget extends StatefulWidget {
  final int? tvId;
  final String? api;
  final String? seriesName;
  final String? posterPath;
  const EpisodeListWidget({
    Key? key,
    this.api,
    this.tvId,
    this.seriesName,
    required this.posterPath,
  }) : super(key: key);

  @override
  EpisodeListWidgetState createState() => EpisodeListWidgetState();
}

class EpisodeListWidgetState extends State<EpisodeListWidget>
    with AutomaticKeepAliveClientMixin {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          tvDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
        child: tvDetails == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      tr("episodes"),
                      style: kTextHeaderStyle,
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0.0,
                              bottom: 8.0,
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                  highlightColor: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade100,
                                  direction: ShimmerDirection.ltr,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          color: Colors.white,
                                          width: 10,
                                          height: 15),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, left: 5.0),
                                        child: Container(
                                          height: 56.4,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Container(
                                                  color: Colors.white,
                                                  height: 19,
                                                  width: 150),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Container(
                                                  color: Colors.white,
                                                  height: 19,
                                                  width: 110),
                                            ),
                                            Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 3.0),
                                                child: Container(
                                                    color: Colors.white,
                                                    height: 20,
                                                    width: 20),
                                              ),
                                              Container(
                                                  color: Colors.white,
                                                  height: 20,
                                                  width: 25),
                                            ]),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Theme.of(context).colorScheme.primary,
                                  thickness: 1.5,
                                  endIndent: 30,
                                  indent: 5,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              )
            : tvDetails!.episodes!.isEmpty
                ? Center(
                    child:
                        Text(tr("no_episodes"), style: kTextSmallHeaderStyle),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tr("episodes"),
                          style: kTextHeaderStyle,
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: tvDetails!.episodes!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EpisodeDetailPage(
                                      seriesName: widget.seriesName,
                                      posterPath: widget.posterPath,
                                      tvId: widget.tvId,
                                      episodes: tvDetails!.episodes,
                                      episodeList: tvDetails!.episodes![index]);
                                }));
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0,
                                      bottom: 8.0,
                                      left: 10,
                                      right: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(tvDetails!
                                              .episodes![index].episodeNumber!
                                              .toString()),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0, left: 10.0),
                                            child: SizedBox(
                                              height: 56.4,
                                              width: 100,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                child: tvDetails!
                                                                .episodes![
                                                                    index]
                                                                .stillPath ==
                                                            null ||
                                                        tvDetails!
                                                            .episodes![index]
                                                            .stillPath!
                                                            .isEmpty
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      )
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
                                                        imageUrl:
                                                            TMDB_BASE_IMAGE_URL +
                                                                imageQuality +
                                                                tvDetails!
                                                                    .episodes![
                                                                        index]
                                                                    .stillPath!,
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
                                                            Shimmer.fromColors(
                                                          baseColor: isDark
                                                              ? Colors
                                                                  .grey.shade800
                                                              : Colors.grey
                                                                  .shade300,
                                                          highlightColor: isDark
                                                              ? Colors
                                                                  .grey.shade700
                                                              : Colors.grey
                                                                  .shade100,
                                                          direction:
                                                              ShimmerDirection
                                                                  .ltr,
                                                          child: Container(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
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
                                                    tvDetails!
                                                        .episodes![index].name!,
                                                    style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                                Text(
                                                  tvDetails!.episodes![index]
                                                                  .airDate ==
                                                              null ||
                                                          tvDetails!
                                                              .episodes![index]
                                                              .airDate!
                                                              .isEmpty
                                                      ? tr("air_date_unknown")
                                                      : '${DateTime.parse(tvDetails!.episodes![index].airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(tvDetails!.episodes![index].airDate!))}, ${DateTime.parse(tvDetails!.episodes![index].airDate!).year}',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white54
                                                        : Colors.black54,
                                                  ),
                                                ),
                                                Row(children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 3.0),
                                                    child: Icon(
                                                      Icons.star,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(tvDetails!
                                                      .episodes![index]
                                                      .voteAverage!
                                                      .toStringAsFixed(1))
                                                ]),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        thickness: 1.5,
                                        endIndent: 30,
                                        indent: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  ));
  }

  @override
  bool get wantKeepAlive => true;
}

class TVWatchProvidersDetails extends StatefulWidget {
  final String api;
  final String country;
  const TVWatchProvidersDetails(
      {Key? key, required this.api, required this.country})
      : super(key: key);

  @override
  State<TVWatchProvidersDetails> createState() =>
      _TVWatchProvidersDetailsState();
}

class _TVWatchProvidersDetailsState extends State<TVWatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    fetchWatchProviders(widget.api, widget.country).then((value) {
      if (mounted) {
        setState(() {
          watchProviders = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2b2c30) : const Color(0xFFDFDEDE),
            ),
            child: Center(
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorWeight: 3,
                unselectedLabelColor: Colors.white54,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(tr("buy"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("stream"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("ads"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("rent"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                  Tab(
                    child: Text(tr("free"),
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: watchProviders == null
                  ? [
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                      watchProvidersShimmer(isDark),
                    ]
                  : [
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_buy_tv"),
                          watchOptions: watchProviders!.buy),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_stream_tv"),
                          watchOptions: watchProviders!.flatRate),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_ads_tv"),
                          watchOptions: watchProviders!.ads),
                      watchProvidersTabData(
                          isDark: isDark,
                          imageQuality: imageQuality,
                          noOptionMessage: tr("no_rent_tv"),
                          watchOptions: watchProviders!.rent),
                      Container(
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
                                              'assets/images/loading_5.gif'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          tr("cinemax"),
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

class TVGenreListGrid extends StatefulWidget {
  final String api;
  const TVGenreListGrid({Key? key, required this.api}) : super(key: key);

  @override
  TVGenreListGridState createState() => TVGenreListGridState();
}

class TVGenreListGridState extends State<TVGenreListGrid>
    with AutomaticKeepAliveClientMixin<TVGenreListGrid> {
  List<Genres>? genreList;

  @override
  void initState() {
    super.initState();
    fetchGenre(widget.api).then((value) {
      if (mounted) {
        setState(() {
          genreList = value;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                tr("genres"),
                style: kTextHeaderStyle,
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
                  ? genreListGridShimmer(isDark)
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
                                      return TVGenre(genres: genreList![index]);
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
                                        genreList![index].genreName ?? "Null",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
            )),
      ],
    );
  }
}

class TVShowsFromWatchProviders extends StatefulWidget {
  const TVShowsFromWatchProviders({Key? key}) : super(key: key);

  @override
  TVShowsFromWatchProvidersState createState() =>
      TVShowsFromWatchProvidersState();
}

class TVShowsFromWatchProvidersState extends State<TVShowsFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tr("streaming_services"),
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
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      TVStreamingServicesWidget(
                          imagePath: 'assets/images/disney_plus.png',
                          title: 'Disney plus',
                          providerID: 337),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      TVStreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      TVStreamingServicesWidget(
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

class TVStreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const TVStreamingServicesWidget({
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
          return StreamingServicesTVShows(
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

class ParticularStreamingServiceTVShows extends StatefulWidget {
  final String api;
  final int providerID;
  final bool? includeAdult;
  const ParticularStreamingServiceTVShows({
    Key? key,
    required this.api,
    required this.providerID,
    required this.includeAdult,
  }) : super(key: key);
  @override
  ParticularStreamingServiceTVShowsState createState() =>
      ParticularStreamingServiceTVShowsState();
}

class ParticularStreamingServiceTVShowsState
    extends State<ParticularStreamingServiceTVShows> {
  List<TV>? tvList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        fetchTV('${widget.api}&page=$pageNum&include_adult=${widget.includeAdult}')
            .then((value) {
          if (mounted) {
            setState(() {
              tvList!.addAll(value);
              isLoading = false;
              pageNum++;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTV('${widget.api}&include_adult=${widget.includeAdult}').then((value) {
      if (mounted) {
        setState(() {
          tvList = value;
        });
      }
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return tvList == null && viewType == 'grid'
        ? moviesAndTVShowGridShimmer(isDark)
        : tvList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    isLoading: isLoading,
                    scrollController: _scrollController))
            : tvList!.isEmpty
                ? Container(
                    child: Center(
                      child: Text(tr("no_watchprovider_tv")),
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
                                    ? TVGridView(
                                        tvList: tvList,
                                        imageQuality: imageQuality,
                                        isDark: isDark,
                                        scrollController: _scrollController,
                                      )
                                    : TVListView(
                                        scrollController: _scrollController,
                                        tvList: tvList,
                                        isDark: isDark,
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

class TVEpisodeCastTab extends StatefulWidget {
  final String? api;
  const TVEpisodeCastTab({Key? key, this.api}) : super(key: key);

  @override
  TVEpisodeCastTabState createState() => TVEpisodeCastTabState();
}

class TVEpisodeCastTabState extends State<TVEpisodeCastTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeCastTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(
            padding: const EdgeInsets.only(top: 8),
            child: movieCastAndCrewTabShimmer(isDark))
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Center(
                  child: Text(tr("no_cast"), style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.cast!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CastDetailPage(
                                cast: credits!.cast![index],
                                heroId: '${credits!.cast![index].name}');
                          }));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
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
                                          tag: '${credits!.cast![index].name}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            child: credits!.cast![index]
                                                        .profilePath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_rect.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
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
                                                        TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .cast![index]
                                                                .profilePath!,
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
                                                        castAndCrewTabImageShimmer(
                                                            isDark),
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
                                            credits!.cast![index].name!,
                                            style: const TextStyle(
                                                fontFamily: 'PoppinsSB',
                                                fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(credits!.cast![index].character!
                                                  .isEmpty
                                              ? tr("as_empty")
                                              : tr("as", namedArgs: {
                                                  "character": credits!
                                                      .cast![index].character!
                                                })),
                                          // Text(
                                          //   credits!.cast![index].roles![0]
                                          //               .episodeCount! ==
                                          //           1
                                          //       ? credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episode'
                                          //       : credits!.cast![index]
                                          //               .roles![0].episodeCount!
                                          //               .toString() +
                                          //           ' episodes',
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color:
                                      !isDark ? Colors.black54 : Colors.white54,
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

class TVEpisodeGuestStarsTab extends StatefulWidget {
  final String? api;
  const TVEpisodeGuestStarsTab({Key? key, this.api}) : super(key: key);

  @override
  TVEpisodeGuestStarsTabState createState() => TVEpisodeGuestStarsTabState();
}

class TVEpisodeGuestStarsTabState extends State<TVEpisodeGuestStarsTab>
    with AutomaticKeepAliveClientMixin<TVEpisodeGuestStarsTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      if (mounted) {
        setState(() {
          credits = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    return credits == null
        ? Container(
            padding: const EdgeInsets.all(8),
            child: searchedPersonShimmer(isDark))
        : credits!.cast!.isEmpty
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: Center(
                  child: Text(tr("no_guest_episode"),
                      style: kTextSmallHeaderStyle),
                ),
              )
            : Container(
                child: ListView.builder(
                    itemCount: credits!.episodeGuestStars!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return GuestStarDetailPage(
                                  cast: credits!.episodeGuestStars![index],
                                  heroId:
                                      '${credits!.episodeGuestStars![index].creditId}');
                            }));
                          },
                          child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 5.0,
                                  left: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20.0, left: 10),
                                          child: SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Hero(
                                              tag:
                                                  '${credits!.episodeGuestStars![index].name}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                child: credits!
                                                            .episodeGuestStars![
                                                                index]
                                                            .profilePath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_rect.png',
                                                        fit: BoxFit.cover,
                                                      )
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
                                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                                            imageQuality +
                                                            credits!
                                                                .episodeGuestStars![
                                                                    index]
                                                                .profilePath!,
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
                                                            castAndCrewTabImageShimmer(
                                                                isDark),
                                                        errorWidget: (context,
                                                                url, error) =>
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
                                                credits!
                                                    .episodeGuestStars![index]
                                                    .name!,
                                                style: const TextStyle(
                                                    fontFamily: 'PoppinsSB',
                                                    fontSize: 20),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: !isDark
                                          ? Colors.black54
                                          : Colors.white54,
                                      thickness: 1,
                                      endIndent: 20,
                                      indent: 10,
                                    ),
                                  ],
                                ),
                              )));
                    }));
  }

  Widget searchedPersonShimmer(isDark) => ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 3.0,
            bottom: 3.0,
            left: 15,
          ),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor:
                    isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                direction: ShimmerDirection.ltr,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 140,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                color: !isDark ? Colors.black54 : Colors.white54,
                thickness: 1,
                endIndent: 20,
                indent: 10,
              ),
            ],
          ),
        );
      });

  @override
  bool get wantKeepAlive => true;
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
    final watchCountry = Provider.of<SettingsProvider>(context).defaultCountry;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
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
                              return tvSeries.backdropPath == null
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
                                alignment: appLang == 'ar'
                                    ? Alignment.topLeft
                                    : Alignment.topRight,
                                child: GestureDetector(
                                  child: WatchProvidersButton(
                                    country: watchCountry,
                                    api: Endpoints.getMovieWatchProviders(
                                        tvSeries.id!, appLang),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (builder) {
                                          return WatchProvidersDetails(
                                            country: watchCountry,
                                            api: Endpoints.getTVWatchProviders(
                                                tvSeries.id!, appLang),
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
                                child: tvSeries.posterPath == null
                                    ? Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        cacheManager: cacheProp(),
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            scrollingImageShimmer(isDark),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          'assets/images/na_logo.png',
                                          fit: BoxFit.cover,
                                        ),
                                        imageUrl: TMDB_BASE_IMAGE_URL +
                                            imageQuality +
                                            tvSeries.posterPath!,
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
    if (mounted) {
      setState(() {
        isBookmarked = iB;
      });
    }
    if (isBookmarked == true) {
      tvDatabaseController.updateTV(widget.tvSeries, widget.tvSeries.id!);
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 30,
                  percent: (widget.tvSeries.voteAverage! / 10),
                  curve: Curves.ease,
                  animation: true,
                  animationDuration: 2500,
                  progressColor: Theme.of(context).colorScheme.primary,
                  center: Text(
                    '${widget.tvSeries.voteAverage!.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tr("rating"),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
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
                widget.tvSeries.voteCount!.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                tr("total_ratings"),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 10, right: 8),
          child: Container(
            child: ElevatedButton(
                onPressed: () {
                  if (isBookmarked == false) {
                    tvDatabaseController.insertTV(widget.tvSeries);
                    if (mounted) {
                      setState(() {
                        isBookmarked = true;
                      });
                    }
                  } else if (isBookmarked == true) {
                    tvDatabaseController.deleteTV(widget.tvSeries.id!);
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
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      //  physics: const BouncingScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: <Widget>[
            TVGenreDisplay(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    tr("overview"),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.tvSeries.overview!.isEmpty ||
                      widget.tvSeries.overview == null
                  ? Text(tr("no_overview_tv"))
                  : ReadMoreText(
                      widget.tvSeries.overview!,
                      trimLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      colorClickableText: Theme.of(context).colorScheme.primary,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: tr("read_more"),
                      trimExpandedText: tr("read_less"),
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
                      widget.tvSeries.firstAirDate == null ||
                              widget.tvSeries.firstAirDate!.isEmpty
                          ? tr("first_episode_air_empty")
                          : '${tr("first_episode_air")} ${DateTime.parse(widget.tvSeries.firstAirDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.tvSeries.firstAirDate!))}, ${DateTime.parse(widget.tvSeries.firstAirDate!).year}',
                      style: const TextStyle(
                        fontFamily: 'PoppinsSB',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            ScrollingTVArtists(
              passedFrom: 'tv_detail',
              api: Endpoints.getTVCreditsUrl(widget.tvSeries.id!, lang),
              title: tr("cast"),
              id: widget.tvSeries.id!,
            ),
            ScrollingTVCreators(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
              title: tr("created_by"),
            ),
            SeasonsList(
              tvId: widget.tvSeries.id!,
              seriesName: widget.tvSeries.name!,
              title: tr("seasons"),
              api: Endpoints.getTVSeasons(widget.tvSeries.id!, lang),
            ),
            TVImagesDisplay(
              title: tr("images"),
              api: Endpoints.getTVImages(widget.tvSeries.id!),
              name: widget.tvSeries.originalName,
            ),
            TVVideosDisplay(
              api: Endpoints.getTVVideos(widget.tvSeries.id!),
              api2: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
              title: tr("videos"),
            ),
            TVSocialLinks(
              api: Endpoints.getExternalLinksForTV(widget.tvSeries.id!, lang),
            ),
            TVInfoTable(
              api: Endpoints.tvDetailsUrl(widget.tvSeries.id!, lang),
            ),
            TVRecommendationsTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                api: Endpoints.getTVRecommendations(
                    widget.tvSeries.id!, 1, lang)),
            SimilarTVTab(
                includeAdult: Provider.of<SettingsProvider>(context).isAdult,
                tvId: widget.tvSeries.id!,
                tvName: widget.tvSeries.name!,
                api: Endpoints.getSimilarTV(widget.tvSeries.id!, 1, lang)),
            // DidYouKnow(
            //   api: Endpoints.getExternalLinksForTV(
            //     widget.tvSeries.id!,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class EpisodeAbout extends StatefulWidget {
  const EpisodeAbout({
    Key? key,
    required this.episodeList,
    this.episodes,
    this.tvId,
    required this.posterPath,
    this.seriesName,
  }) : super(key: key);
  final EpisodeList episodeList;
  final List<EpisodeList>? episodes;
  final int? tvId;
  final String? seriesName;
  final String? posterPath;

  @override
  State<EpisodeAbout> createState() => _EpisodeAboutState();
}

class _EpisodeAboutState extends State<EpisodeAbout> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    tr("overview"),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadMoreText(
                widget.episodeList.overview!.isEmpty
                    ? ''
                    : widget.episodeList.overview!,
                trimLines: 4,
                style: const TextStyle(fontFamily: 'Poppins'),
                colorClickableText: Theme.of(context).colorScheme.primary,
                trimMode: TrimMode.Line,
                trimCollapsedText: tr("read_more"),
                trimExpandedText: tr("read_less"),
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
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
                  child: Text(
                    widget.episodeList.airDate == null ||
                            widget.episodeList.airDate!.isEmpty
                        ? tr("episode_air_empty")
                        : '${tr("episode_air")}  ${DateTime.parse(widget.episodeList.airDate!).day} ${DateFormat("MMMM").format(DateTime.parse(widget.episodeList.airDate!))}, ${DateTime.parse(widget.episodeList.airDate!).year}',
                    style: const TextStyle(
                      fontFamily: 'PoppinsSB',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            WatchNowButton(
              episodeList: widget.episodeList,
              seriesName: widget.seriesName!,
              tvId: widget.tvId!,
              posterPath: widget.posterPath!,
            ),
            const SizedBox(height: 15),
            ScrollingTVEpisodeCasts(
              passedFrom: 'episode_detail',
              seasonNumber: widget.episodeList.seasonNumber!,
              episodeNumber: widget.episodeList.episodeNumber!,
              id: widget.tvId,
              api: Endpoints.getEpisodeCredits(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!,
                  lang),
            ),
            TVEpisodeImagesDisplay(
              title: tr("images"),
              name: '${widget.seriesName}_${widget.episodeList.name}',
              api: Endpoints.getTVEpisodeImagesUrl(
                  widget.tvId!,
                  widget.episodeList.seasonNumber!,
                  widget.episodeList.episodeNumber!),
            ),
            // TVVideosDisplay(
            //   api: Endpoints.getTVEpisodeVideosUrl(
            //       widget.tvId!,
            //       widget.episodeList.seasonNumber!,
            //       widget.episodeList.episodeNumber!),
            //   title: 'Videos',
            // ),
          ],
        ),
      ),
    );
  }
}

class TVEpisodeQuickInfo extends StatelessWidget {
  const TVEpisodeQuickInfo({
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
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final appLang = Provider.of<SettingsProvider>(context).appLanguage;
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
                              return episodeList.stillPath == null
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
                                          '${TMDB_BASE_IMAGE_URL}original/${episodeList.stillPath!}',
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
                                child: TopButton(buttonText: tr("open_season")),
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
                child: Row(children: [
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  '${episodeList.seasonNumber! <= 9 ? 'S0${episodeList.seasonNumber}' : 'S${episodeList.seasonNumber}'} | '
                                  '${episodeList.episodeNumber! <= 9 ? 'E0${episodeList.episodeNumber}' : 'E${episodeList.episodeNumber}'}'
                                  ''),
                              Text(
                                episodeList.airDate == null ||
                                        episodeList.airDate == ""
                                    ? episodeList.name!
                                    : episodeList.name!,
                                style: kTextSmallHeaderStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Column(
                                  children: [
                                    Text(
                                      seriesName!,
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
    );
  }
}

class TVEpisodeOptions extends StatelessWidget {
  const TVEpisodeOptions({Key? key, required this.episodeList})
      : super(key: key);
  final EpisodeList episodeList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // user score circle percent indicator
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 18, 0),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 30,
                  percent: (episodeList.voteAverage! / 10),
                  curve: Curves.ease,
                  animation: true,
                  animationDuration: 2500,
                  progressColor: Theme.of(context).colorScheme.primary,
                  center: Text(
                    '${episodeList.voteAverage!.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tr("rating"),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              // height: 46,
              // width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                episodeList.voteCount!.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                tr("total_ratings"),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ]),
        ),
        const Expanded(child: SizedBox())
      ],
    );
  }
}

class WatchNowButton extends StatefulWidget {
  const WatchNowButton(
      {Key? key,
      required this.episodeList,
      required this.seriesName,
      required this.tvId,
      required this.posterPath})
      : super(key: key);

  final String seriesName, posterPath;
  final int tvId;
  final EpisodeList episodeList;

  @override
  State<WatchNowButton> createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  bool? isVisible = false;
  double? buttonWidth = 160;
  TVDetails? tvDetails;

  Color _borderColor = Colors.red; // Initial border color
  Timer? _timer;
  Random random = Random();

  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

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
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
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
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(Size(buttonWidth!, 100)),
            minimumSize: MaterialStateProperty.all(Size(buttonWidth!, 50)),
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primary,
            )),
        onPressed: () async {
          mixpanel.track('Most viewed TV series', properties: {
            'TV series name': widget.seriesName,
            'TV series id': '${widget.tvId}',
            'TV series episode name': '${widget.episodeList.name}',
            'TV series season number': '${widget.episodeList.seasonNumber}',
            'TV series episode number': '${widget.episodeList.episodeNumber}'
          });
          setState(() {
            isVisible = true;
            buttonWidth = 200;
          });
          fetchTVDetails(Endpoints.tvDetailsUrl(widget.tvId, lang))
              .then((value) async {
            if (mounted) {
              setState(() {
                tvDetails = value;
                mixpanel.track('Most viewed TV series', properties: {
                  'TV series name': widget.seriesName,
                  'TV series id': '${widget.tvId}',
                  'TV series episode name': '${widget.episodeList.name}',
                  'TV series season number':
                      '${widget.episodeList.seasonNumber}',
                  'TV series episode number':
                      '${widget.episodeList.episodeNumber}'
                });
              });
              var isBookmarked = await recentlyWatchedEpisodeController
                  .contain(widget.episodeList.episodeId!);
              int elapsed = 0;
              if (isBookmarked) {
                if (mounted) {
                  var rEpisodes =
                      Provider.of<RecentProvider>(context, listen: false)
                          .episodes;

                  int index = rEpisodes.indexWhere(
                      (element) => element.id == widget.episodeList.episodeId);
                  setState(() {
                    elapsed = rEpisodes[index].elapsed!;
                  });
                }
              }
              setState(() {
                isVisible = false;
                buttonWidth = 160;
              });
              if (mounted) {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return TVVideoLoader(
                    download: false,
                    metadata: [
                      widget.episodeList.episodeId,
                      widget.seriesName,
                      widget.episodeList.name,
                      widget.episodeList.episodeNumber!,
                      widget.episodeList.seasonNumber!,
                      value.numberOfSeasons!,
                      value.backdropPath,
                      widget.posterPath,
                      elapsed
                    ],
                  );
                })));
              }
            }
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                tr("watch_now"),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Visibility(
              visible: isVisible!,
              child: const Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
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
