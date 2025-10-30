// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import '../api/endpoints.dart';
import '../functions/function.dart';
import '../models/credits.dart';
import '../provider/app_dependency_provider.dart';
import '../screens/person/cast_detail.dart';
import '../screens/person/createdby_detail.dart';
import '../screens/person/crew_detail.dart';
import '../screens/person/guest_star_detail.dart';
import '../screens/person/searchedperson.dart';
import '/widgets/common_widgets.dart';
import '/screens/common/hero_photoview.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../provider/settings_provider.dart';
import '/constants/api_constants.dart';
import '../functions/network.dart';
import '/models/images.dart';
import '/models/movie.dart';
import '/models/person.dart';
import '/models/social_icons_icons.dart';
import '/models/tv.dart';
import '/screens/movie/movie_detail.dart';
import '/widgets/movie_widgets.dart';
import '/screens/tv/tv_detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart';
import '/models/credits.dart' as cre;

class PersonImagesDisplay extends StatefulWidget {
  const PersonImagesDisplay({
    super.key,
    required this.api,
    required this.title,
    required this.personName,
  });

  final String api;
  final String title;
  final String personName;

  @override
  State<PersonImagesDisplay> createState() => _PersonImagesDisplayState();
}

class _PersonImagesDisplayState extends State<PersonImagesDisplay>
    with AutomaticKeepAliveClientMixin {
  PersonImages? personImages;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonImages(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personImages = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const LeadingDot(),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: kTextHeaderStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: personImages == null
                ? personImageShimmer(themeMode)
                : personImages!.profile!.isEmpty
                    ? Center(
                        child: Text(tr('no_images_person')),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: personImages!.profile!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 15.0, 8.0),
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                              cacheManager: cacheProp(),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: buildImageUrl(
                                                      TMDB_BASE_IMAGE_URL,
                                                      proxyUrl,
                                                      isProxyEnabled,
                                                      context) +
                                                  imageQuality +
                                                  personImages!.profile![index]
                                                      .filePath!,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: ((context) {
                                                    return HeroPhotoView(
                                                      imageProvider:
                                                          imageProvider,
                                                      currentIndex: index,
                                                      heroId: buildImageUrl(
                                                              TMDB_BASE_IMAGE_URL,
                                                              proxyUrl,
                                                              isProxyEnabled,
                                                              context) +
                                                          imageQuality +
                                                          personImages!
                                                              .profile![index]
                                                              .filePath!,
                                                      name: widget.personName,
                                                    );
                                                  })));
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
                                                  scrollingImageShimmer(
                                                      themeMode),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_rect.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonMovieListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonMovieListWidget(
      {super.key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult});

  @override
  PersonMovieListWidgetState createState() => PersonMovieListWidgetState();
}

class PersonMovieListWidgetState extends State<PersonMovieListWidget>
    with AutomaticKeepAliveClientMixin<PersonMovieListWidget> {
  List<Movie>? personMoviesList;
  List<Movie>? uniqueMov;
  Set<int> seenIds = {};

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonMovies(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personMoviesList = value;
        });
      }
      if (personMoviesList != null) {
        uniqueMov = [];
        for (final Movie mov in personMoviesList!) {
          if (!seenIds.contains(mov.id)) {
            uniqueMov!.add(mov);
            seenIds.add(mov.id!);
          }
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return uniqueMov == null
        ? personMoviesAndTVShowShimmer(themeMode)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    tr('contains_nsfw'),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          tr('person_movie_count', namedArgs: {
                            'count': uniqueMov!.length.toString()
                          }),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  uniqueMov!.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 8.0, top: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                    ),
                                    itemCount: uniqueMov!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MovieDetailPage(
                                                movie: uniqueMov![index],
                                                heroId:
                                                    '${uniqueMov![index].id}');
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Hero(
                                                  tag:
                                                      '${uniqueMov![index].id}',
                                                  child: Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: uniqueMov![index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity)
                                                              : CachedNetworkImage(
                                                                  cacheManager:
                                                                      cacheProp(),
                                                                  fadeOutDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                  fadeOutCurve:
                                                                      Curves
                                                                          .easeOut,
                                                                  fadeInDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              700),
                                                                  fadeInCurve:
                                                                      Curves
                                                                          .easeIn,
                                                                  imageUrl: buildImageUrl(
                                                                          TMDB_BASE_IMAGE_URL,
                                                                          proxyUrl,
                                                                          isProxyEnabled,
                                                                          context) +
                                                                      imageQuality +
                                                                      uniqueMov![
                                                                              index]
                                                                          .posterPath!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
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
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      scrollingImageShimmer(
                                                                          themeMode),
                                                                  errorWidget: (context, url, error) => Image.asset(
                                                                      'assets/images/na_logo.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                      height: double
                                                                          .infinity),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: 50,
                                                            height: 25,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: themeMode ==
                                                                            'dark' ||
                                                                        themeMode ==
                                                                            'amoled'
                                                                    ? Colors
                                                                        .black45
                                                                    : Colors
                                                                        .white38),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .star_rounded,
                                                                ),
                                                                Text(uniqueMov![
                                                                        index]
                                                                    .voteAverage!
                                                                    .toStringAsFixed(
                                                                        1))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    uniqueMov![index].title!,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                ],
              );
  }
}

class PersonTVListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonTVListWidget(
      {super.key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult});

  @override
  PersonTVListWidgetState createState() => PersonTVListWidgetState();
}

class PersonTVListWidgetState extends State<PersonTVListWidget>
    with AutomaticKeepAliveClientMixin<PersonTVListWidget> {
  List<TV>? personTVList;
  List<TV>? uniqueTV;
  Set<int> seenIds = {};
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonTV(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personTVList = value;
        });
      }
      if (personTVList != null) {
        uniqueTV = [];
        for (final TV tv in personTVList!) {
          if (!seenIds.contains(tv.id)) {
            uniqueTV!.add(tv);
            seenIds.add(tv.id!);
          }
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return uniqueTV == null
        ? personMoviesAndTVShowShimmer(themeMode)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    tr('contains_nsfw'),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          tr('person_tv_count', namedArgs: {
                            'count': uniqueTV!.length.toString()
                          }),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  uniqueTV!.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10.0, top: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 150,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                    ),
                                    itemCount: uniqueTV!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return TVDetailPage(
                                                tvSeries: uniqueTV![index],
                                                heroId:
                                                    '${uniqueTV![index].id}');
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Hero(
                                                  tag: '${uniqueTV![index].id}',
                                                  child: Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: uniqueTV![
                                                                          index]
                                                                      .posterPath ==
                                                                  null
                                                              ? Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  height: double
                                                                      .infinity)
                                                              : CachedNetworkImage(
                                                                  cacheManager:
                                                                      cacheProp(),
                                                                  fadeOutDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              300),
                                                                  fadeOutCurve:
                                                                      Curves
                                                                          .easeOut,
                                                                  fadeInDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              700),
                                                                  fadeInCurve:
                                                                      Curves
                                                                          .easeIn,
                                                                  imageUrl: buildImageUrl(
                                                                          TMDB_BASE_IMAGE_URL,
                                                                          proxyUrl,
                                                                          isProxyEnabled,
                                                                          context) +
                                                                      imageQuality +
                                                                      uniqueTV![
                                                                              index]
                                                                          .posterPath!,
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
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
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      scrollingImageShimmer(
                                                                          themeMode),
                                                                  errorWidget: (context, url, error) => Image.asset(
                                                                      'assets/images/na_logo.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                      height: double
                                                                          .infinity),
                                                                ),
                                                        ),
                                                        Positioned(
                                                          top: 0,
                                                          left: 0,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: 50,
                                                            height: 25,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: themeMode ==
                                                                            'dark' ||
                                                                        themeMode ==
                                                                            'amoled'
                                                                    ? Colors
                                                                        .black45
                                                                    : Colors
                                                                        .white60),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .star_rounded,
                                                                ),
                                                                Text(uniqueTV![
                                                                        index]
                                                                    .voteAverage!
                                                                    .toStringAsFixed(
                                                                        1))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    uniqueTV![index]
                                                        .originalName!,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                ],
              );
  }
}

class PersonAboutWidget extends StatefulWidget {
  final String api;
  const PersonAboutWidget({
    super.key,
    required this.api,
  });

  @override
  State<PersonAboutWidget> createState() => _PersonAboutWidgetState();
}

class _PersonAboutWidgetState extends State<PersonAboutWidget>
    with AutomaticKeepAliveClientMixin {
  PersonDetails? personDetails;

  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonDetails(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personDetails = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return personDetails == null
        ? personAboutSimmer(themeMode)
        : Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: Row(
                            children: [
                              const LeadingDot(),
                              Expanded(
                                child: Text(
                                  tr('biography'),
                                  style: kTextHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ReadMoreText(
                    personDetails?.biography != ''
                        ? personDetails!.biography!
                        : tr('no_biography_person'),
                    trimLines: 4,
                    style: kTextSmallAboutBodyStyle,
                    colorClickableText: Theme.of(context).colorScheme.primary,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: tr('read_more'),
                    trimExpandedText: tr('read_less'),
                    lessStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    moreStyle: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonSocialLinks extends StatefulWidget {
  final String? api;
  const PersonSocialLinks({
    super.key,
    this.api,
  });

  @override
  PersonSocialLinksState createState() => PersonSocialLinksState();
}

class PersonSocialLinksState extends State<PersonSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchSocialLinks(widget.api!, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          externalLinks = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LeadingDot(),
                Expanded(
                  child: Text(
                    tr('social_media_links'),
                    style: kTextHeaderStyle,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? socialMediaShimmer(themeMode)
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            tr('no_social_link_person'),
                            textAlign: TextAlign.center,
                            style: kTextSmallBodyStyle,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: themeMode == 'dark' || themeMode == 'amoled'
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

class PersonDataTable extends StatefulWidget {
  const PersonDataTable({required this.api, super.key});
  final String api;

  @override
  State<PersonDataTable> createState() => _PersonDataTableState();
}

class _PersonDataTableState extends State<PersonDataTable> {
  PersonDetails? personDetails;
  @override
  void initState() {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    fetchPersonDetails(widget.api, isProxyEnabled, proxyUrl).then((value) {
      if (mounted) {
        setState(() {
          personDetails = value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: personDetails == null
              ? personDetailInfoTableShimmer(themeMode)
              : DataTable(dataRowMinHeight: 40, columns: [
                  DataColumn(
                      label: personDetails!.deathday != null &&
                              personDetails!.birthday != null
                          ? Text(
                              tr('died_aged'),
                              style: kTableLeftStyle,
                            )
                          : Text(
                              tr('age'),
                              style: kTableLeftStyle,
                            )),
                  DataColumn(
                    label: personDetails!.deathday != null &&
                            personDetails!.birthday != null
                        ? Text(
                            '${DateTime.parse(personDetails!.deathday.toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}')
                        : Text(personDetails?.birthday != null
                            ? '${DateTime.parse(DateTime.now().toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}'
                            : '-'),
                  ),
                ], rows: [
                  DataRow(cells: [
                    DataCell(Text(
                      tr('born_on'),
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(personDetails?.birthday != null
                          ? '${DateTime.parse(personDetails!.birthday!).day} ${DateFormat.MMMM().format(DateTime.parse(personDetails!.birthday!))}, ${DateTime.parse(personDetails!.birthday!.toString()).year}'
                          : '-'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(Text(
                      tr('from'),
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(
                        personDetails?.birthPlace != null
                            ? personDetails!.birthPlace!
                            : '-',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ]),
                ]),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CastDetailAbout extends StatefulWidget {
  CastDetailAbout(
      {super.key,
      required this.cast,
      required this.selectedIndex,
      required this.tabController});
  int selectedIndex;
  final cre.Cast? cast;
  final TabController tabController;

  @override
  State<CastDetailAbout> createState() => _CastDetailAboutState();
}

class _CastDetailAboutState extends State<CastDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(tr('about'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('movies'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('tv_shows'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.cast!.id!, lang)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.cast!.id!, lang),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.cast!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.cast!.id!,
                                          ),
                                          title: tr('images'),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.cast!.id!, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.cast!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.cast!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.cast!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.cast!.id!, lang)),
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
    );
  }
}

class CastDetailQuickInfo extends StatelessWidget {
  const CastDetailQuickInfo({
    super.key,
    required this.widget,
    required this.imageQuality,
  });

  final CastDetailPage widget;

  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
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
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.cast!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_rect.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_rect.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.cast!.profilePath!,
                                    ),
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
                        Text(
                          widget.cast!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'FigtreeSB'),
                        ),
                        Text(
                          widget.cast!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Figtree'),
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

class CreatedByQuickInfo extends StatelessWidget {
  const CreatedByQuickInfo({
    super.key,
    required this.widget,
    required this.imageQuality,
  });

  final CreatedByPersonDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
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
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.createdBy!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.createdBy!.profilePath!,
                                    ),
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
                        Text(
                          widget.createdBy!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'FigtreeSB'),
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

// ignore: must_be_immutable
class CreatedByAbout extends StatefulWidget {
  CreatedByAbout(
      {super.key,
      required this.createdBy,
      required this.selectedIndex,
      required this.tabController});
  int selectedIndex;
  final CreatedBy? createdBy;
  final TabController tabController;

  @override
  State<CreatedByAbout> createState() => _CreatedByAboutState();
}

class _CreatedByAboutState extends State<CreatedByAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(tr('about'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('movies'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('tv_shows'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.createdBy!.id!, lang)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.createdBy!.id!, lang),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.createdBy!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.createdBy!.id!,
                                          ),
                                          title: tr('images'),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.createdBy!.id!, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.createdBy!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.createdBy!.id!, lang)),
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
    );
  }
}

class CrewDetailQuickInfo extends StatelessWidget {
  const CrewDetailQuickInfo({
    super.key,
    required this.widget,
    required this.imageQuality,
  });

  final CrewDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
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
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.crew!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.crew!.profilePath!,
                                    ),
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
                        Text(
                          widget.crew!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'FigtreeSB'),
                        ),
                        Text(
                          widget.crew!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Figtree'),
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

// ignore: must_be_immutable
class CrewDetailAbout extends StatefulWidget {
  CrewDetailAbout(
      {super.key,
      required this.crew,
      required this.selectedIndex,
      required this.tabController});

  int selectedIndex;
  final TabController tabController;
  final cre.Crew? crew;

  @override
  State<CrewDetailAbout> createState() => _CrewDetailAboutState();
}

class _CrewDetailAboutState extends State<CrewDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(tr('about'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('movies'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('tv_shows'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.crew!.id!, lang)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.crew!.id!, lang),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.crew!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.crew!.id!,
                                          ),
                                          title: tr('images'),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.crew!.id!, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.crew!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.crew!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.crew!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.crew!.id!, lang)),
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
    );
  }
}

class GuestStarDetailQuickInfo extends StatelessWidget {
  const GuestStarDetailQuickInfo({
    super.key,
    required this.widget,
    required this.imageQuality,
  });

  final GuestStarDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
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
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.cast!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.cast!.profilePath!,
                                    ),
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
                        Text(
                          widget.cast!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'FigtreeSB'),
                        ),
                        Text(
                          widget.cast!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Figtree'),
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

// ignore: must_be_immutable
class GuestStarDetailAbout extends StatefulWidget {
  GuestStarDetailAbout(
      {super.key,
      required this.cast,
      required this.selectedIndex,
      required this.tabController});
  int selectedIndex;
  final TabController tabController;
  final TVEpisodeGuestStars? cast;

  @override
  State<GuestStarDetailAbout> createState() => _GuestStarDetailAboutState();
}

class _GuestStarDetailAboutState extends State<GuestStarDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(tr('about'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('movies'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('tv_shows'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.cast!.id!, lang)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.cast!.id!, lang),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.cast!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.cast!.id!,
                                          ),
                                          title: tr('images'),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.cast!.id!, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.cast!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.cast!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.cast!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.cast!.id!, lang)),
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
    );
  }
}

class SearchedPersonQuickInfo extends StatelessWidget {
  const SearchedPersonQuickInfo({
    super.key,
    required this.widget,
    required this.imageQuality,
  });

  final SearchedPersonDetailPage widget;
  final String imageQuality;
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final isProxyEnabled = Provider.of<SettingsProvider>(context).enableProxy;
    final proxyUrl = Provider.of<AppDependencyProvider>(context).tmdbProxy;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
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
                    tag: widget.heroId,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: widget.person!.profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: cacheProp(),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          scrollingImageShimmer(themeMode),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/na_logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                      imageUrl: buildImageUrl(
                                              TMDB_BASE_IMAGE_URL,
                                              proxyUrl,
                                              isProxyEnabled,
                                              context) +
                                          imageQuality +
                                          widget.person!.profilePath!,
                                    ),
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
                        Text(
                          widget.person!.name!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 25, fontFamily: 'FigtreeSB'),
                        ),
                        Text(
                          widget.person!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Figtree'),
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

// ignore: must_be_immutable
class SearchedPersonAbout extends StatefulWidget {
  SearchedPersonAbout(
      {super.key,
      required this.person,
      required this.selectedIndex,
      required this.tabController});
  int selectedIndex;
  final TabController tabController;
  final Person? person;

  @override
  State<SearchedPersonAbout> createState() => _SearchedPersonAboutState();
}

class _SearchedPersonAboutState extends State<SearchedPersonAbout> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0))),
        child: Column(
          children: [
            Column(
              children: [
                TabBar(
                  onTap: ((value) {
                    setState(() {
                      widget.selectedIndex = value;
                    });
                  }),
                  isScrollable: true,
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(tr('about'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('movies'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                    Tab(
                      child: Text(tr('tv_shows'),
                          style: TextStyle(
                              fontFamily: 'Figtree',
                              color:
                                  themeMode == 'dark' || themeMode == 'amoled'
                                      ? Colors.white
                                      : Colors.black)),
                    ),
                  ],
                  controller: widget.tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(1.6, 0, 1.6, 3),
                      child: IndexedStack(
                        index: widget.selectedIndex,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.person!.id!, lang)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.person!.id!, lang),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.person!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.person!.id!,
                                          ),
                                          title: tr('images'),
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.person!.id!, lang),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.person!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.person!.id!, lang),
                            ),
                          ),
                          Container(
                            child: PersonTVListWidget(
                                isPersonAdult: widget.person!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.person!.id!, lang)),
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
    );
  }
}
