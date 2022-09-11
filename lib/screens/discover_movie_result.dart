import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/function.dart';
import '../models/movie.dart';
import '../provider/darktheme_provider.dart';
import '../provider/imagequality_provider.dart';
import '../provider/mixpanel_provider.dart';
import 'common_widgets.dart';
import 'movie_detail.dart';

class DiscoverMovieResult extends StatefulWidget {
  const DiscoverMovieResult(
      {required this.api,
      required this.includeAdult,
      required this.page,
      Key? key})
      : super(key: key);
  final String api;
  final bool? includeAdult;
  final int page;

  @override
  State<DiscoverMovieResult> createState() => _DiscoverMovieResultState();
}

class _DiscoverMovieResultState extends State<DiscoverMovieResult> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  var startAppSdkMovieProviders = StartAppSdk();
  StartAppBannerAd? bannerAdMovieDiscover;
  bool requestFailed = false;

  void getBannerADForMovieDiscover() {
    startAppSdkMovieProviders
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdMovieDiscover = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse(widget.api + '&page=$pageNum'));
        print(widget.api + '&page=$pageNum');
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => Movie.fromJson(i))
              .toList();
          moviesList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    getBannerADForMovieDiscover();
    getData();
    print(widget.api);
    getMoreData();
  }

  void getData() {
    fetchMovies(widget.api + '&page=${widget.page}}').then((value) {
      setState(() {
        moviesList = value;
      });
    });
    Future.delayed(const Duration(seconds: 11), () {
      if (moviesList == null) {
        setState(() {
          requestFailed = true;
          moviesList = [Movie()];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    final imageQuality =
        Provider.of<ImagequalityProvider>(context).imageQuality;
    final mixpanel = Provider.of<MixpanelProvider>(context).mixpanel;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Discover movies',
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            child: moviesList == null
                ? Container(
                    color: isDark
                        ? const Color(0xFF202124)
                        : const Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: mainPageVerticalScrollShimmer(
                          bannerAdMovieDiscover,
                          isDark,
                          isLoading,
                          _scrollController),
                    ))
                : moviesList!.isEmpty
                    ? Container(
                        color: isDark
                            ? const Color(0xFF202124)
                            : const Color(0xFFFFFFFF),
                        padding: const EdgeInsets.all(8),
                        child: const Center(
                          child: Text(
                            'Oops! movies for the parameters you specified doesn\'t exist :(',
                            style: kTextHeaderStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : requestFailed == true
                        ? retryWidget(isDark)
                        : Container(
                            color: isDark
                                ? const Color(0xFF202124)
                                : const Color(0xFFFFFFFF),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                              controller: _scrollController,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: moviesList!.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    mixpanel.track(
                                                        'Most viewed movie pages',
                                                        properties: {
                                                          'Movie name':
                                                              '${moviesList![index].originalTitle}',
                                                          'Movie id':
                                                              '${moviesList![index].id}',
                                                          'Is Movie adult?':
                                                              '${moviesList![index].adult}'
                                                        });
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return MovieDetailPage(
                                                        movie:
                                                            moviesList![index],
                                                        heroId:
                                                            '${moviesList![index].id}',
                                                      );
                                                    }));
                                                  },
                                                  child: Container(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF202124)
                                                        : const Color(
                                                            0xFFFFFFFF),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 0.0,
                                                        bottom: 3.0,
                                                        left: 10,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            10.0),
                                                                child: SizedBox(
                                                                  width: 85,
                                                                  height: 130,
                                                                  child: Hero(
                                                                    tag:
                                                                        '${moviesList![index].id}',
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      child: moviesList![index].posterPath ==
                                                                              null
                                                                          ? Image
                                                                              .asset(
                                                                              'assets/images/na_logo.png',
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              fadeOutDuration: const Duration(milliseconds: 300),
                                                                              fadeOutCurve: Curves.easeOut,
                                                                              fadeInDuration: const Duration(milliseconds: 700),
                                                                              fadeInCurve: Curves.easeIn,
                                                                              imageUrl: TMDB_BASE_IMAGE_URL + imageQuality + moviesList![index].posterPath!,
                                                                              imageBuilder: (context, imageProvider) => Container(
                                                                                decoration: BoxDecoration(
                                                                                  image: DecorationImage(
                                                                                    image: imageProvider,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              placeholder: (context, url) => mainPageVerticalScrollImageShimmer(isDark),
                                                                              errorWidget: (context, url, error) => Image.asset(
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
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      moviesList![
                                                                              index]
                                                                          .title!,
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'PoppinsSB',
                                                                          fontSize:
                                                                              15,
                                                                          overflow:
                                                                              TextOverflow.ellipsis),
                                                                    ),
                                                                    Row(
                                                                      children: <
                                                                          Widget>[
                                                                        const Icon(
                                                                            Icons
                                                                                .star,
                                                                            color:
                                                                                Color(0xFFF57C00)),
                                                                        Text(
                                                                          moviesList![index]
                                                                              .voteAverage!
                                                                              .toStringAsFixed(1),
                                                                          style:
                                                                              const TextStyle(fontFamily: 'Poppins'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          Divider(
                                                            color: !isDark
                                                                ? Colors.black54
                                                                : Colors
                                                                    .white54,
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
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: isLoading,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )),
                                bannerAdMovieDiscover != null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: SizedBox(
                                          height: 60,
                                          width: double.infinity,
                                          child: StartAppBanner(
                                            bannerAdMovieDiscover!,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )));
  }

  Widget retryWidget(isDark) {
    return Container(
      color: isDark ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
      child: Center(
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
                  maximumSize: MaterialStateProperty.all(const Size(200, 60)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: const BorderSide(color: Color(0xFFF57C00))))),
              onPressed: () {
                setState(() {
                  requestFailed = false;
                  moviesList = null;
                });
                getData();
              },
              child: const Text('Retry')),
        ],
      )),
    );
  }
}