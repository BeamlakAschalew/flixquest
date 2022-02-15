// ignore_for_file: avoid_unnecessary_containers, unused_local_variable

import 'dart:convert';
import 'package:cinemax/constants/style_constants.dart';
import 'package:cinemax/modals/person.dart';
import 'package:cinemax/modals/social_icons_icons.dart';
import 'package:cinemax/modals/tv.dart';
import 'package:cinemax/modals/videos.dart';
import 'package:cinemax/modals/watch_providers.dart';
import 'package:cinemax/screens/cast_detail.dart';
import 'package:cinemax/screens/searchedperson.dart';
import 'package:cinemax/screens/streaming_services_movies.dart';
import 'package:cinemax/screens/tv_detail.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '/modals/function.dart';
import '/modals/movie.dart';
import '/api/endpoints.dart';
import '/modals/genres.dart';
import '/constants/api_constants.dart';
import 'package:cinemax/screens/movie_detail.dart';
import 'package:cinemax/modals/credits.dart';
import 'crew_detail.dart';
import 'movie_stream.dart';
import 'package:cinemax/modals/images.dart';
import 'package:http/http.dart' as http;
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'genremovies.dart';
import 'about.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainMoviesDisplay extends StatelessWidget {
  const MainMoviesDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          const DiscoverMovies(),
          ScrollingMovies(
            title: 'Popular',
            api: Endpoints.popularMoviesUrl(1),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Trending',
            api: Endpoints.trendingMoviesUrl(1),
            discoverType: 1,
            isTrending: true,
          ),
          ScrollingMovies(
            title: 'Top Rated',
            api: Endpoints.topRatedUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Now playing',
            api: Endpoints.nowPlayingMoviesUrl(1),
            discoverType: 'now_playing',
            isTrending: false,
          ),
          ScrollingMovies(
            title: 'Upcoming',
            api: Endpoints.upcomingMoviesUrl(1),
            discoverType: 'upcoming',
            isTrending: false,
          ),
          GenreListGrid(api: Endpoints.genresUrl()),
          MoviesFromWatchProviders(),
        ],
      ),
    );
  }
}

class DiscoverMovies extends StatefulWidget {
  const DiscoverMovies({Key? key}) : super(key: key);
  @override
  _DiscoverMoviesState createState() => _DiscoverMoviesState();
}

class _DiscoverMoviesState extends State<DiscoverMovies>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;

  List<Movie>? moviesList;
  MovieDetails? movieDetails;
  @override
  void initState() {
    super.initState();
    fetchMovies(Endpoints.discoverMoviesUrl(1)).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    fetchMovieDetails(Endpoints.discoverMoviesUrl(1)).then((value) {
      setState(() {
        movieDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    deviceAspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Discover',
                style: kTextHeaderStyle,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: deviceHeight * 0.45,
          child: moviesList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: true,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, pageViewIndex) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {
                          // fetchMovieDetails(moviesList![index].id!);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MovieDetailPage(
                                      movie: moviesList![index],
                                      heroId:
                                          '${moviesList![index].id}discover')));
                        },
                        child: Hero(
                          tag: '${moviesList![index].id}discover',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage(
                              image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                  'w500/' +
                                  moviesList![index].posterPath!),
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/images/loading.gif'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: moviesList!.length,
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingMovies extends StatefulWidget {
  final String? api, title;
  final dynamic discoverType;
  final String? watchProviderId;
  final bool isTrending;
  const ScrollingMovies({
    Key? key,
    this.api,
    this.title,
    this.discoverType,
    this.watchProviderId,
    required this.isTrending,
  }) : super(key: key);
  @override
  _ScrollingMoviesState createState() => _ScrollingMoviesState();
}

class _ScrollingMoviesState extends State<ScrollingMovies>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;
  late int index;
  List<Movie>? moviesList;
  MovieDetails? movieDetails;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/movie/${widget.discoverType}?api_key=$TMDB_API_KEY&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/movie/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=false&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => Movie.fromJson(i))
                .toList();
            moviesList!.addAll(newlistMovies);
          });
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchMovies(widget.api!).then((value) {
      setState(() {
        moviesList = value;
      });
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
    double deviceFont = MediaQuery.of(context).textScaleFactor;
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
          child: moviesList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: moviesList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MovieDetailPage(
                                            movie: moviesList![index],
                                            heroId:
                                                '${moviesList![index].id}${widget.title}')));
                              },
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${moviesList![index].id}${widget.title}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    moviesList![index]
                                                        .posterPath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          moviesList![index].title!,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Visibility(
                        child: const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ),
                        visible: isLoading,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  _ScrollingArtistsState createState() => _ScrollingArtistsState();
}

class _ScrollingArtistsState extends State<ScrollingArtists> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Cast',
                      style: kTextHeaderStyle,
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Cast',
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
                              heroId: credits!.cast![index].id.toString(),
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
                                  tag: credits!.cast![index].id!,
                                  child: SizedBox(
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child:
                                          credits!.cast![index].profilePath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : FadeInImage(
                                                  image: NetworkImage(
                                                      TMDB_BASE_IMAGE_URL +
                                                          'w500/' +
                                                          credits!.cast![index]
                                                              .profilePath!),
                                                  fit: BoxFit.cover,
                                                  placeholder: const AssetImage(
                                                      'assets/images/loading.gif'),
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
}

class MovieSocialLinks extends StatefulWidget {
  final String? api;
  const MovieSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  _MovieSocialLinksState createState() => _MovieSocialLinksState();
}

class _MovieSocialLinksState extends State<MovieSocialLinks> {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social media links',
              style: kTextHeaderStyle,
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            'This movie doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
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
                              isNull: externalLinks?.instagramUsername == null,
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
                              isNull: externalLinks?.facebookUsername == null,
                              url: externalLinks?.facebookUsername == null
                                  ? ''
                                  : FACEBOOK_BASE_URL +
                                      externalLinks!.facebookUsername!,
                              icon: const Icon(
                                SocialIcons.globe,
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
          ],
        ),
      ),
    );
  }
}

class SocialIconWidget extends StatelessWidget {
  const SocialIconWidget({
    Key? key,
    this.url,
    this.icon,
    this.isNull,
  }) : super(key: key);

  final String? url;
  final Widget? icon;
  final bool? isNull;

  @override
  Widget build(BuildContext context) {
    return isNull == true
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                launch(url!);
              },
              child: Container(
                height: 50,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: icon,
              ),
            ),
          );
  }
}

class MovieImagesDisplay extends StatefulWidget {
  final String? api, title;
  const MovieImagesDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  _MovieImagesState createState() => _MovieImagesState();
}

class _MovieImagesState extends State<MovieImagesDisplay> {
  Images? movieImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        movieImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    // double deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        movieImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: deviceHeight * 0.20,
            child: movieImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : movieImages!.backdrop!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.10,
                        child: const Center(
                          child: Text(
                            'This movie doesn\'t have an image provided',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: FadeInImage(
                                  image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                      'w500/' +
                                      movieImages!.backdrop![index].filePath!),
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/images/loading.gif'),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: movieImages!.backdrop!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class MovieVideosDisplay extends StatefulWidget {
  final String? api, title;
  const MovieVideosDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  _MovieVideosState createState() => _MovieVideosState();
}

class _MovieVideosState extends State<MovieVideosDisplay> {
  Videos? movieVideos;

  @override
  void initState() {
    super.initState();
    fetchVideos(widget.api!).then((value) {
      setState(() {
        movieVideos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    // double deviceWidth = MediaQuery.of(context).size.width;
    bool playButtonVisibility = true;
    return Column(
      children: [
        movieVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style:
                          kTextHeaderStyle, /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: deviceHeight * 0.27,
            child: movieVideos == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : movieVideos!.result!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.10,
                        child: const Center(
                          child:
                              Text('This movie doesn\'t have a video provided'),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.19,
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
                                  launch(YOUTUBE_BASE_URL +
                                      movieVideos!.result![index].videoLink!);
                                },
                                child: SizedBox(
                                  height: deviceHeight * 0.18,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: deviceHeight * 0.17,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  FadeInImage(
                                                    image: NetworkImage(
                                                        YOUTUBE_THUMBNAIL_URL +
                                                            movieVideos!
                                                                .result![index]
                                                                .videoLink! +
                                                            '/hqdefault.jpg'),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        playButtonVisibility,
                                                    child: const SizedBox(
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 90,
                                                      ),
                                                      height: 90,
                                                      width: 90,
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
                                          movieVideos!.result![index].name!,
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
                          itemCount: movieVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    Key? key,
    this.widget,
  }) : super(key: key);
  final MovieDetailPage? widget;

  @override
  _WatchNowButtonState createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        style: ButtonStyle(
            maximumSize: MaterialStateProperty.all(const Size(150, 50)),
            backgroundColor:
                MaterialStateProperty.all(const Color(0xFFF57C00))),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MovieStream(id: widget.widget!.movie.id!);
          }));
        },
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
            Text(
              'WATCH NOW',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreDisplay extends StatefulWidget {
  final String? api;
  const GenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  _GenreDisplayState createState() => _GenreDisplayState();
}

class _GenreDisplayState extends State<GenreDisplay>
    with AutomaticKeepAliveClientMixin<GenreDisplay> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    fetchMovieGenre(widget.api!).then((value) {
      setState(() {
        genreList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: SizedBox(
      height: genreList == null ? 0 : 80,
      child: genreList == null
          ? Container()
          : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: genreList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GenreMovies(
                                    genres: genreList![index],
                                  )));
                    },
                    child: Chip(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Color(0xFFad5700)),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      label: Text(
                        genreList![index].genreName!,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        // style: widget.themeData.textTheme.bodyText1,
                      ),
                      backgroundColor: Colors.transparent,
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

class MovieInfoTable extends StatefulWidget {
  final String? api;
  const MovieInfoTable({Key? key, this.api}) : super(key: key);

  @override
  _MovieInfoTableState createState() => _MovieInfoTableState();
}

class _MovieInfoTableState extends State<MovieInfoTable> {
  MovieDetails? movieDetails;
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    fetchMovieDetails(widget.api!).then((value) {
      setState(() {
        movieDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return movieDetails == null
        ? const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: [
              const Text(
                'Movie Info',
                style: kTextHeaderStyle,
              ),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(dataRowHeight: 40, columns: [
                      const DataColumn(
                          label: Text(
                        'Original Title',
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      )),
                      DataColumn(
                        label: Text(
                          movieDetails!.originalTitle!,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ], rows: [
                      DataRow(cells: [
                        const DataCell(Text('Status')),
                        DataCell(Text(movieDetails!.status!.isEmpty
                            ? 'unknown'
                            : movieDetails!.status!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Runtime')),
                        DataCell(Text(movieDetails!.runtime! == 0
                            ? 'N/A'
                            : '${movieDetails!.runtime!} mins')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Spoken language')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movieDetails!.spokenLanguages!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(movieDetails!
                                        .spokenLanguages!.isEmpty
                                    ? 'N/A'
                                    : '${movieDetails!.spokenLanguages![index].englishName},'),
                              );
                            },
                          ),
                        )),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Budget')),
                        DataCell(movieDetails!.budget == 0
                            ? const Text('-')
                            : Text(formatCurrency
                                .format(movieDetails!.budget!)
                                .toString())),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Revenue')),
                        DataCell(movieDetails!.budget == 0
                            ? const Text('-')
                            : Text(formatCurrency
                                .format(movieDetails!.revenue!)
                                .toString())),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Tagline')),
                        DataCell(
                          Text(
                            movieDetails!.tagline!.isEmpty
                                ? '-'
                                : movieDetails!.tagline!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production companies')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                movieDetails!.productionCompanies!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(movieDetails!
                                        .productionCompanies!.isEmpty
                                    ? 'N/A'
                                    : '${movieDetails!.productionCompanies![index].name},'),
                              );
                            },
                          ),
                        )
                            // movieDetails!.productionCompanies!.isEmpty
                            //     ? const Text('-')
                            //     : Text(
                            //         movieDetails!.productionCompanies![0].name!),
                            ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production countries')),
                        DataCell(SizedBox(
                          height: 20,
                          width: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                movieDetails!.productionCountries!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(movieDetails!
                                        .productionCountries!.isEmpty
                                    ? 'N/A'
                                    : '${movieDetails!.productionCountries![index].name},'),
                              );
                            },
                          ),
                        )
                            // movieDetails!.productionCompanies!.isEmpty
                            //     ? const Text('-')
                            //     : Text(
                            //         movieDetails!.productionCountries![0].name!),
                            ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ],
          );
  }
}

class SearchMovieWidget extends StatefulWidget {
  final String? query;
  final Function(Movie)? onTap;
  const SearchMovieWidget({Key? key, this.query, this.onTap}) : super(key: key);
  @override
  _SearchMovieWidgetState createState() => _SearchMovieWidgetState();
}

class _SearchMovieWidgetState extends State<SearchMovieWidget>
    with SingleTickerProviderStateMixin {
  List<Movie>? moviesList;
  List<TV>? tvList;
  List<Person>? personList;
  TabController? tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchMovies(Endpoints.movieSearchUrl(widget.query!)).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    fetchTV(Endpoints.tvSearchUrl(widget.query!)).then((value) {
      setState(() {
        tvList = value;
      });
    });
    fetchPerson(Endpoints.personSearchUrl(widget.query!)).then((value) {
      setState(() {
        personList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: const Color(0xFF202124),
        child: moviesList == null || tvList == null || personList == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : moviesList!.isEmpty
                ? const Center(
                    child: Text(
                      'Oops! the movie you searched doesn\'t exist',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  )
                : Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        indicatorColor: const Color(0xFFF57C00),
                        indicatorWeight: 3,
                        unselectedLabelColor: Colors.white54,
                        labelColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: tabController,
                        tabs: const [
                          Tab(
                            child: Text('Movies',
                                style: TextStyle(fontFamily: 'Poppins')),
                          ),
                          Tab(
                            child: Text('TV shows',
                                style: TextStyle(fontFamily: 'Poppins')),
                          ),
                          Tab(
                            child: Text('People',
                                style: TextStyle(fontFamily: 'Poppins')),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(controller: tabController, children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: moviesList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onTap!(moviesList![index]);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId: '${moviesList![index].id}');
                                    }));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: moviesList![index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : FadeInImage(
                                                        image: NetworkImage(
                                                            TMDB_BASE_IMAGE_URL +
                                                                'w500/' +
                                                                moviesList![
                                                                        index]
                                                                    .posterPath!),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            const AssetImage(
                                                                'assets/images/loading.gif'),
                                                      ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      moviesList![index].title!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          moviesList![index]
                                                              .voteAverage!
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins'),
                                                        ),
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.0),
                                          child: Divider(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: moviesList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onTap!(moviesList![index]);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId: '${moviesList![index].id}');
                                    }));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: moviesList![index]
                                                            .posterPath ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/na_logo.png',
                                                        fit: BoxFit.cover,
                                                      )
                                                    : FadeInImage(
                                                        image: NetworkImage(
                                                            TMDB_BASE_IMAGE_URL +
                                                                'w500/' +
                                                                moviesList![
                                                                        index]
                                                                    .posterPath!),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            const AssetImage(
                                                                'assets/images/loading.gif'),
                                                      ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      moviesList![index].title!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          moviesList![index]
                                                              .voteAverage!
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins'),
                                                        ),
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.0),
                                          child: Divider(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: personList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    widget.onTap!(moviesList![index]);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SearchedPersonDetailPage(
                                          person: personList![index],
                                          heroId: '${personList![index].id}');
                                    }));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 85,
                                              height: 130,
                                              child: Hero(
                                                tag: '${personList![index].id}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: personList![index]
                                                              .profilePath ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : FadeInImage(
                                                          image: NetworkImage(
                                                              TMDB_BASE_IMAGE_URL +
                                                                  'w500/' +
                                                                  personList![
                                                                          index]
                                                                      .profilePath!),
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              const AssetImage(
                                                                  'assets/images/loading.gif'),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      personList![index].name!,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          moviesList![index]
                                                              .voteAverage!
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins'),
                                                        ),
                                                        const Icon(Icons.star,
                                                            color: Color(
                                                                0xFFF57C00)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.0),
                                          child: Divider(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class CastTab extends StatefulWidget {
  final String? api;
  const CastTab({Key? key, this.api}) : super(key: key);

  @override
  _CastTabState createState() => _CastTabState();
}

class _CastTabState extends State<CastTab>
    with AutomaticKeepAliveClientMixin<CastTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            color: const Color(0xFF202124),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: credits!.cast!.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CastDetailPage(
                          cast: credits!.cast![index],
                          heroId: credits!.cast![index].id.toString());
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 16.0, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: credits!.cast![index].profilePath == null
                                ? Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage(
                                    image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                        'w500/' +
                                        credits!.cast![index].profilePath!),
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(
                                        'assets/images/loading.gif'),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  credits!.cast![index].name!,
                                  // style: themeData!.textTheme.bodyText2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'As : ' + credits!.cast![index].character!,
                                  // style: themeData!.textTheme.bodyText1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class CrewTab extends StatefulWidget {
  final String? api;
  const CrewTab({Key? key, this.api}) : super(key: key);

  @override
  _CrewTabState createState() => _CrewTabState();
}

class _CrewTabState extends State<CrewTab>
    with AutomaticKeepAliveClientMixin<CrewTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            color: const Color(0xFF202124),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: credits!.crew!.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CrewDetailPage(
                        heroId: '${credits!.crew![index].id}',
                        crew: credits!.crew![index],
                      );
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 16.0, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Hero(
                            tag: '${credits!.crew![index].id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: credits!.crew![index].profilePath == null
                                  ? Image.asset(
                                      'assets/images/na_logo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : FadeInImage(
                                      image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                          'w500/' +
                                          credits!.crew![index].profilePath!),
                                      fit: BoxFit.cover,
                                      placeholder: const AssetImage(
                                          'assets/images/loading.gif'),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  credits!.crew![index].name!,
                                  // style: themeData!.textTheme.bodyText2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Job : ' + credits!.crew![index].department!,
                                  // style: themeData!.textTheme.bodyText1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class MovieRecommendationsTab extends StatefulWidget {
  final String api;
  const MovieRecommendationsTab({Key? key, required this.api})
      : super(key: key);

  @override
  _MovieRecommendationsTabState createState() =>
      _MovieRecommendationsTabState();
}

class _MovieRecommendationsTabState extends State<MovieRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  @override
  void initState() {
    super.initState();
    fetchMovies(widget.api).then((value) {
      setState(() {
        movieList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: movieList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : movieList!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'We don\'t have a recommendations for this movie :(',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: movieList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MovieDetailPage(
                            movie: movieList![index],
                            heroId: '${movieList![index].id}',
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0, top: 0.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 80,
                                  height: 125,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: movieList![index].posterPath == null
                                        ? Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          )
                                        : FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    movieList![index]
                                                        .posterPath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          movieList![index].originalTitle!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins'),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              movieList![index]
                                                  .voteAverage!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            const Icon(Icons.star,
                                                color: Color(0xFFF57C00)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Divider(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarMoviesTab extends StatefulWidget {
  final String api;
  const SimilarMoviesTab({Key? key, required this.api}) : super(key: key);

  @override
  _SimilarMoviesTabState createState() => _SimilarMoviesTabState();
}

class _SimilarMoviesTabState extends State<SimilarMoviesTab>
    with AutomaticKeepAliveClientMixin {
  List<Movie>? movieList;
  @override
  void initState() {
    super.initState();
    fetchMovies(widget.api).then((value) {
      setState(() {
        movieList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: movieList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : movieList!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'We don\'t have a similars for this movie :(',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: movieList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MovieDetailPage(
                            movie: movieList![index],
                            heroId: '${movieList![index].id}',
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0, top: 0.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 125,
                                  width: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: movieList![index].posterPath == null
                                        ? Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          )
                                        : FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    movieList![index]
                                                        .posterPath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          movieList![index].originalTitle!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins'),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              movieList![index]
                                                  .voteAverage!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            const Icon(Icons.star,
                                                color: Color(0xFFF57C00)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Divider(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreMovies extends StatefulWidget {
  final String api;
  final int genreId;
  const ParticularGenreMovies(
      {Key? key, required this.api, required this.genreId})
      : super(key: key);
  @override
  _ParticularGenreMoviesState createState() => _ParticularGenreMoviesState();
}

class _ParticularGenreMoviesState extends State<ParticularGenreMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(
            Uri.parse('$TMDB_API_BASE_URL/discover/movie?api_key=$TMDB_API_KEY'
                '&language=en-US'
                '&sort_by=popularity.desc'
                '&include_adult=false'
                '&include_video=false'
                '&watch_region=US'
                '&page=$pageNum'
                '&with_genres=${widget.genreId}'));
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
    fetchMovies(widget.api).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: moviesList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : moviesList!.isEmpty
              ? const Center(
                  child: Text(
                    'Oops! movies for this genre doesn\'t exist :(',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        itemCount: moviesList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId: '${moviesList![index].id}')));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Hero(
                                        tag: '${moviesList![index].id}',
                                        child: SizedBox(
                                          width: 85,
                                          height: 130,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: moviesList![index]
                                                        .posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            moviesList![index]
                                                                .posterPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                moviesList![index].title!,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    moviesList![index]
                                                        .voteAverage!
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  const Icon(Icons.star,
                                                      color: Color(0xFFF57C00)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                        visible: isLoading,
                        child:
                            const Center(child: CircularProgressIndicator())),
                  ],
                ),
    );
  }
}

class ParticularStreamingServiceMovies extends StatefulWidget {
  final String api;
  final int providerID;
  const ParticularStreamingServiceMovies({
    Key? key,
    required this.api,
    required this.providerID,
  }) : super(key: key);
  @override
  _ParticularStreamingServiceMoviesState createState() =>
      _ParticularStreamingServiceMoviesState();
}

class _ParticularStreamingServiceMoviesState
    extends State<ParticularStreamingServiceMovies> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/discover/movie?api_key='
            '$TMDB_API_KEY'
            '&language=en-US&sort_by=popularity'
            '.desc&include_adult=false&include_video=false&page=$pageNum'
            '&with_watch_providers=${widget.providerID}'
            '&watch_region=US'));
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
    fetchMovies(widget.api).then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202124),
      child: moviesList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : moviesList!.isEmpty
              ? const Center(
                  child: Text(
                    'Oops! movies for this watch provider doesn\'t exist :(',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        itemCount: moviesList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MovieDetailPage(
                                          movie: moviesList![index],
                                          heroId: '${moviesList![index].id}')));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: Hero(
                                          tag: '${moviesList![index].id}',
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: moviesList![index]
                                                        .posterPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            moviesList![index]
                                                                .posterPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                moviesList![index].title!,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    moviesList![index]
                                                        .voteAverage!
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  const Icon(Icons.star,
                                                      color: Color(0xFFF57C00)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                        visible: isLoading,
                        child:
                            const Center(child: CircularProgressIndicator())),
                  ],
                ),
    );
  }
}

class StreamingServicesWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final int providerID;
  const StreamingServicesWidget({
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
          return StreamingServicesMovies(
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
              color: const Color(0xFFF57C00),
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
                child: Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AboutPage();
              }));
            },
          ),
        ],
      ),
    );
  }
}

class GenreListGrid extends StatefulWidget {
  final String api;
  const GenreListGrid({Key? key, required this.api}) : super(key: key);

  @override
  _GenreListGridState createState() => _GenreListGridState();
}

class _GenreListGridState extends State<GenreListGrid>
    with AutomaticKeepAliveClientMixin<GenreListGrid> {
  List<Genres>? genreList;
  @override
  void initState() {
    super.initState();
    fetchMovieGenre(widget.api).then((value) {
      setState(() {
        genreList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    super.build(context);
    return genreList == null
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Genres',
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Genres',
                      style: kTextHeaderStyle,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 75,
                  child: Row(
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
                                    return GenreMovies(
                                        genres: genreList![index]);
                                  }));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 125,
                                    alignment: Alignment.center,
                                    child: Text(genreList![index].genreName!),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF57C00),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class WatchProvidersButton extends StatefulWidget {
  final Function()? onTap;
  final String api;
  const WatchProvidersButton({
    Key? key,
    this.onTap,
    required this.api,
  }) : super(key: key);

  @override
  State<WatchProvidersButton> createState() => _WatchProvidersButtonState();
}

class _WatchProvidersButtonState extends State<WatchProvidersButton> {
  WatchProviders? watchProviders;
  @override
  void initState() {
    super.initState();
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0x26F57C00)),
            maximumSize: MaterialStateProperty.all(const Size(140, 40)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(color: Color(0xFFF57C00))))),
        onPressed: () {
          widget.onTap!();
        },
        child: const Text(
          'Watch providers',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class WatchProvidersDetails extends StatefulWidget {
  final String api;
  const WatchProvidersDetails({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<WatchProvidersDetails> createState() => _WatchProvidersDetailsState();
}

class _WatchProvidersDetailsState extends State<WatchProvidersDetails>
    with SingleTickerProviderStateMixin {
  WatchProviders? watchProviders;
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    fetchWatchProviders(widget.api).then((value) {
      setState(() {
        watchProviders = value;
      });
    });
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return watchProviders == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            child: Column(
              children: [
                TabBar(
                  controller: tabController,
                  isScrollable: true,
                  indicatorColor: const Color(0xFFF57C00),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      child: Text('Buy'),
                    ),
                    Tab(
                      child: Text('Paid Stream'),
                    ),
                    Tab(
                      child: Text('Rent'),
                    ),
                    Tab(
                      child: Text('Free'),
                    )
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.buy == null
                            ? const Center(
                                child: Text(
                                    'This movie doesn\'t have an option to buy yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.buy!.length,
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
                                            child: watchProviders!
                                                        .buy![index].logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .buy![index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              watchProviders!
                                                  .buy![index].providerName!,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.flatRate == null
                            ? const Center(
                                child: Text(
                                    'This movie doesn\'t have an option to stream yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.flatRate!.length,
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
                                            child: watchProviders!
                                                        .flatRate![index]
                                                        .logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .flatRate![
                                                                    index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Text(
                                              watchProviders!.flatRate![index]
                                                  .providerName!,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: watchProviders?.rent == null
                            ? const Center(
                                child: Text(
                                    'This movie doesn\'t have an option to rent yet'))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: watchProviders!.rent!.length,
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
                                            child: watchProviders!.rent![index]
                                                        .logoPath ==
                                                    null
                                                ? Image.asset(
                                                    'assets/images/na_logo.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : FadeInImage(
                                                    image: NetworkImage(
                                                        TMDB_BASE_IMAGE_URL +
                                                            'w500/' +
                                                            watchProviders!
                                                                .rent![index]
                                                                .logoPath!),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            watchProviders!
                                                .rent![index].providerName!,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                      ),
                      Padding(
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
                                              'assets/images/loading.gif'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Expanded(
                                        flex: 6,
                                        child: Text(
                                          'Cinemax',
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

class MoviesFromWatchProviders extends StatefulWidget {
  const MoviesFromWatchProviders({Key? key}) : super(key: key);

  @override
  _MoviesFromWatchProvidersState createState() =>
      _MoviesFromWatchProvidersState();
}

class _MoviesFromWatchProvidersState extends State<MoviesFromWatchProviders> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Movies from streaming services',
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
                      StreamingServicesWidget(
                        imagePath: 'assets/images/netflix.png',
                        title: 'Netflix',
                        providerID: 8,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/amazon_prime.png',
                        title: 'Amazon Prime',
                        providerID: 9,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hulu.png',
                        title: 'hulu',
                        providerID: 15,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/hbo_max.png',
                        title: 'HBO Max',
                        providerID: 384,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/apple_tv.png',
                        title: 'Apple TV plus',
                        providerID: 350,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/peacock.png',
                        title: 'Peacock',
                        providerID: 387,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/itunes.png',
                        title: 'iTunes',
                        providerID: 2,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/youtube.png',
                        title: 'YouTube Premium',
                        providerID: 188,
                      ),
                      StreamingServicesWidget(
                        imagePath: 'assets/images/paramount.png',
                        title: 'Paramount Plus',
                        providerID: 531,
                      ),
                      StreamingServicesWidget(
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
