// ignore_for_file: avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import '../api/endpoints.dart';
import '../models/credits.dart';
import '../screens/person/cast_detail.dart';
import '../screens/person/createdby_detail.dart';
import '../screens/person/crew_detail.dart';
import '../screens/person/guest_star_detail.dart';
import '../screens/person/searchedperson.dart';
import '/widgets/common_widgets.dart';
import '/screens/hero_photoview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../provider/settings_provider.dart';
import '/constants/api_constants.dart';
import '/models/function.dart';
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
    Key? key,
    required this.api,
    required this.title,
    required this.personName,
  }) : super(key: key);

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
    fetchPersonImages(widget.api).then((value) {
      setState(() {
        personImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: personImages == null
                ? personImageShimmer(isDark)
                : personImages!.profile!.isEmpty
                    ? const Center(
                        child: Text('No images available for this person'),
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
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutCurve: Curves.easeOut,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 700),
                                              fadeInCurve: Curves.easeIn,
                                              imageUrl: TMDB_BASE_IMAGE_URL +
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
                                                      heroId:
                                                          TMDB_BASE_IMAGE_URL +
                                                              imageQuality +
                                                              personImages!
                                                                  .profile![
                                                                      index]
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
                                                  scrollingImageShimmer(isDark),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                'assets/images/na_square.png',
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
      {Key? key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult})
      : super(key: key);

  @override
  PersonMovieListWidgetState createState() => PersonMovieListWidgetState();
}

class PersonMovieListWidgetState extends State<PersonMovieListWidget>
    with AutomaticKeepAliveClientMixin<PersonMovieListWidget> {
  List<Movie>? personMoviesList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchPersonMovies(widget.api).then((value) {
      setState(() {
        personMoviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (personMoviesList == null) {
        setState(() {
          requestFailed = true;
          personMoviesList = [Movie()];
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return personMoviesList == null
        ? personMoviesAndTVShowShimmer(isDark)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'This section contains NSFW & 18+ content',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              '${personMoviesList!.length} movies',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      personMoviesList!.isEmpty
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5.0, bottom: 8.0, top: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 150,
                                          childAspectRatio: 0.48,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                        ),
                                        itemCount: personMoviesList!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MovieDetailPage(
                                                    movie: personMoviesList![
                                                        index],
                                                    heroId:
                                                        '${personMoviesList![index].id}');
                                              }));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Hero(
                                                      tag:
                                                          '${personMoviesList![index].id}',
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: personMoviesList![
                                                                        index]
                                                                    .posterPath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : CachedNetworkImage(
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
                                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    personMoviesList![
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
                                                                        isDark),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
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
                                                        personMoviesList![index]
                                                            .originalTitle!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      personMoviesList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }
}

class PersonTVListWidget extends StatefulWidget {
  final String api;
  final bool? isPersonAdult;
  final bool? includeAdult;
  const PersonTVListWidget(
      {Key? key,
      required this.api,
      this.isPersonAdult,
      required this.includeAdult})
      : super(key: key);

  @override
  PersonTVListWidgetState createState() => PersonTVListWidgetState();
}

class PersonTVListWidgetState extends State<PersonTVListWidget>
    with AutomaticKeepAliveClientMixin<PersonTVListWidget> {
  List<TV>? personTVList;
  bool requestFailed = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    fetchPersonTV(widget.api).then((value) {
      setState(() {
        personTVList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (personTVList == null) {
        setState(() {
          requestFailed = true;
          personTVList = [TV()];
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return personTVList == null
        ? personMoviesAndTVShowShimmer(isDark)
        : widget.isPersonAdult == true && widget.includeAdult == false
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'This section contains NSFW & 18+ content',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : requestFailed == true
                ? retryWidget(isDark)
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              '${personTVList!.length} TV shows',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      personTVList!.isEmpty
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 10.0,
                                  bottom: 10.0,
                                  top: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 150,
                                          childAspectRatio: 0.48,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                        ),
                                        itemCount: personTVList!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return TVDetailPage(
                                                    tvSeries:
                                                        personTVList![index],
                                                    heroId:
                                                        '${personTVList![index].id}');
                                              }));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Hero(
                                                      tag:
                                                          '${personTVList![index].id}',
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: personTVList![
                                                                        index]
                                                                    .posterPath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : CachedNetworkImage(
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
                                                                imageUrl: TMDB_BASE_IMAGE_URL +
                                                                    imageQuality +
                                                                    personTVList![
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
                                                                    Image.asset(
                                                                  'assets/images/loading.gif',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                  'assets/images/na_logo.png',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
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
                                                        personTVList![index]
                                                            .originalName!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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

  Widget retryWidget(isDark) {
    return Center(
      child: Container(
          width: double.infinity,
          color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/network-signal.png',
                  width: 60, height: 60),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please connect to the Internet and try again',
                    textAlign: TextAlign.center),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0x0DF57C00)),
                      maximumSize:
                          MaterialStateProperty.all(const Size(200, 60)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              side:
                                  const BorderSide(color: Color(0xFFF57C00))))),
                  onPressed: () {
                    setState(() {
                      requestFailed = false;
                      personTVList = null;
                    });
                    getData();
                  },
                  child: const Text('Retry')),
            ],
          )),
    );
  }
}

class PersonAboutWidget extends StatefulWidget {
  final String api;
  const PersonAboutWidget({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<PersonAboutWidget> createState() => _PersonAboutWidgetState();
}

class _PersonAboutWidgetState extends State<PersonAboutWidget>
    with AutomaticKeepAliveClientMixin {
  PersonDetails? personDetails;

  @override
  void initState() {
    super.initState();
    fetchPersonDetails(widget.api).then((value) {
      setState(() {
        personDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return personDetails == null
        ? personAboutSimmer(isDark)
        : Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, bottom: 8),
                    child: Text(
                      'Biography',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ReadMoreText(
                    personDetails?.biography != ""
                        ? personDetails!.biography!
                        : 'We don\'t have a biography for this person',
                    trimLines: 4,
                    style: kTextSmallAboutBodyStyle,
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
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  PersonSocialLinksState createState() => PersonSocialLinksState();
}

class PersonSocialLinksState extends State<PersonSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    fetchSocialLinks(widget.api!).then((value) {
      setState(() {
        externalLinks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social media links',
              style: TextStyle(fontSize: 20),
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
                      ? const Center(
                          child: Text(
                            'This person doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                            style: kTextSmallBodyStyle,
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
                                  color: Color(0xFFF57C00),
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
                                  color: Color(0xFFF57C00),
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
                                  color: Color(0xFFF57C00),
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
  const PersonDataTable({required this.api, Key? key}) : super(key: key);
  final String api;

  @override
  State<PersonDataTable> createState() => _PersonDataTableState();
}

class _PersonDataTableState extends State<PersonDataTable> {
  PersonDetails? personDetails;
  @override
  void initState() {
    fetchPersonDetails(widget.api).then((value) {
      setState(() {
        personDetails = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: personDetails == null
              ? personDetailInfoTableShimmer(isDark)
              : DataTable(dataRowHeight: 40, columns: [
                  const DataColumn(
                      label: Text(
                    'Age',
                    style: kTableLeftStyle,
                  )),
                  DataColumn(
                    label: Text(personDetails?.birthday != null
                        ? '${DateTime.parse(DateTime.now().toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}'
                        : '-'),
                  ),
                ], rows: [
                  DataRow(cells: [
                    const DataCell(Text(
                      'Born on',
                      style: kTableLeftStyle,
                    )),
                    DataCell(
                      Text(personDetails?.birthday != null
                          ? '${DateTime.parse(personDetails!.birthday!).day} ${DateFormat.MMMM().format(DateTime.parse(personDetails!.birthday!))}, ${DateTime.parse(personDetails!.birthday!.toString()).year}'
                          : '-'),
                    ),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text(
                      'From',
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
      {Key? key,
      required this.cast,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final cre.Cast? cast;
  final TabController tabController;

  @override
  State<CastDetailAbout> createState() => _CastDetailAboutState();
}

class _CastDetailAboutState extends State<CastDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
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
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
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
                              color: isDark
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.cast!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.cast!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.cast!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.cast!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.cast!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.cast!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.cast!.id!),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonTVListWidget(
                                isPersonAdult: widget.cast!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.cast!.id!)),
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
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final CastDetailPage widget;

  final String imageQuality;

  @override
  Widget build(BuildContext context) {
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
                                      fit: BoxFit.cover,
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
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
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                        Text(
                          widget.cast!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Poppins'),
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
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final CreatedByPersonDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
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
                                      fit: BoxFit.cover,
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
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
                              fontSize: 25, fontFamily: 'PoppinsSB'),
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
      {Key? key,
      required this.createdBy,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final CreatedBy? createdBy;
  final TabController tabController;

  @override
  State<CreatedByAbout> createState() => _CreatedByAboutState();
}

class _CreatedByAboutState extends State<CreatedByAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
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
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
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
                              color: isDark
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.createdBy!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.createdBy!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.createdBy!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.createdBy!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.createdBy!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonMovieListWidget(
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.createdBy!.id!),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonTVListWidget(
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.createdBy!.id!)),
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
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final CrewDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
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
                                      fit: BoxFit.cover,
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
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
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                        Text(
                          widget.crew!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Poppins'),
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
      {Key? key,
      required this.crew,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);

  int selectedIndex;
  final TabController tabController;
  final cre.Crew? crew;

  @override
  State<CrewDetailAbout> createState() => _CrewDetailAboutState();
}

class _CrewDetailAboutState extends State<CrewDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
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
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
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
                              color: isDark
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.crew!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.crew!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.crew!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.crew!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.crew!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.crew!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.crew!.id!),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonTVListWidget(
                                isPersonAdult: widget.crew!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.crew!.id!)),
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
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final GuestStarDetailPage widget;
  final String imageQuality;

  @override
  Widget build(BuildContext context) {
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
                                      fit: BoxFit.cover,
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
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
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                        Text(
                          widget.cast!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Poppins'),
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
      {Key? key,
      required this.cast,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final TabController tabController;
  final TVEpisodeGuestStars? cast;

  @override
  State<GuestStarDetailAbout> createState() => _GuestStarDetailAboutState();
}

class _GuestStarDetailAboutState extends State<GuestStarDetailAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
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
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
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
                              color: isDark
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.cast!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.cast!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.cast!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.cast!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.cast!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.cast!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.cast!.id!),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonTVListWidget(
                                isPersonAdult: widget.cast!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.cast!.id!)),
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
    Key? key,
    required this.widget,
    required this.imageQuality,
  }) : super(key: key);

  final SearchedPersonDetailPage widget;
  final String imageQuality;
  @override
  Widget build(BuildContext context) {
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
                                      fit: BoxFit.cover,
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
                                      imageUrl: TMDB_BASE_IMAGE_URL +
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
                              fontSize: 25, fontFamily: 'PoppinsSB'),
                        ),
                        Text(
                          widget.person!.department!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'Poppins'),
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
      {Key? key,
      required this.person,
      required this.selectedIndex,
      required this.tabController})
      : super(key: key);
  int selectedIndex;
  final TabController tabController;
  final Person? person;

  @override
  State<SearchedPersonAbout> createState() => _SearchedPersonAboutState();
}

class _SearchedPersonAboutState extends State<SearchedPersonAbout> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            borderRadius: const BorderRadius.only(
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
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text('About',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('Movies',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
                    ),
                    Tab(
                      child: Text('TV Shows',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white : Colors.black)),
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
                              color: isDark
                                  ? const Color(0xFF000000)
                                  : const Color(0xFFFFFFFF),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10, top: 10.0),
                                    child: Column(
                                      children: [
                                        PersonAboutWidget(
                                            api: Endpoints.getPersonDetails(
                                                widget.person!.id!)),
                                        PersonSocialLinks(
                                          api: Endpoints
                                              .getExternalLinksForPerson(
                                                  widget.person!.id!),
                                        ),
                                        PersonImagesDisplay(
                                          personName: widget.person!.name!,
                                          api: Endpoints.getPersonImages(
                                            widget.person!.id!,
                                          ),
                                          title: 'Images',
                                        ),
                                        PersonDataTable(
                                          api: Endpoints.getPersonDetails(
                                              widget.person!.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonMovieListWidget(
                              isPersonAdult: widget.person!.adult!,
                              includeAdult:
                                  Provider.of<SettingsProvider>(context)
                                      .isAdult,
                              api: Endpoints.getMovieCreditsForPerson(
                                  widget.person!.id!),
                            ),
                          ),
                          Container(
                            color: isDark
                                ? const Color(0xFF000000)
                                : const Color(0xFFFFFFFF),
                            child: PersonTVListWidget(
                                isPersonAdult: widget.person!.adult!,
                                includeAdult:
                                    Provider.of<SettingsProvider>(context)
                                        .isAdult,
                                api: Endpoints.getTVCreditsForPerson(
                                    widget.person!.id!)),
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
