import 'dart:convert';

import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/modals/function.dart';
import 'package:cinemax/modals/movie.dart';
import 'package:cinemax/modals/person.dart';
import 'package:cinemax/modals/tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'movie_detail.dart';
import 'searchedperson.dart';
import 'tv_detail.dart';

class SearchMovieWidget extends StatefulWidget {
  final String? query;
  const SearchMovieWidget({
    Key? key,
    this.query,
  }) : super(key: key);
  @override
  _SearchMovieWidgetState createState() => _SearchMovieWidgetState();
}

class _SearchMovieWidgetState extends State<SearchMovieWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<Movie>? moviesList;
  List<TV>? tvList;
  List<Person>? personList;
  TabController? tabController;
  final ScrollController moviescrollController = ScrollController();
  final ScrollController tvscrollController = ScrollController();
  final ScrollController personcrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    moviescrollController.addListener(() async {
      if (moviescrollController.position.pixels ==
          moviescrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/search/movie?api_key='
            '$TMDB_API_KEY'
            '&language=en-US'
            '&query=${widget.query}'
            '&page=$pageNum'
            '&include_adult=false'));
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
    tvscrollController.addListener(() async {
      if (tvscrollController.position.pixels ==
          tvscrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/search/tv?api_key='
            '$TMDB_API_KEY'
            '&language=en-US'
            '&query=${widget.query}'
            '&page=$pageNum'
            '&include_adult=false'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistTV = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistTV);
        });
      }
    });
    personcrollController.addListener(() async {
      if (personcrollController.position.pixels ==
          personcrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        var response = await http.get(Uri.parse('$TMDB_API_BASE_URL'
            '/search/person?api_key='
            '$TMDB_API_KEY'
            '&language=en-US'
            '&query=${widget.query}'
            '&page=$pageNum'
            '&include_adult=false'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistPerson = (json.decode(response.body)['results'] as List)
              .map((i) => Person.fromJson(i))
              .toList();
          personList!.addAll(newlistPerson);
        });
      }
    });

    return "success";
  }

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
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF202124),
        child: moviesList == null || tvList == null || personList == null
            ? const Center(
                child: CircularProgressIndicator(),
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
                      moviesList!.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Oops! the movie you searched doesn\'t exist, if you searched for a TV show or a person select either of the tabs above',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: moviescrollController,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: moviesList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return MovieDetailPage(
                                                movie: moviesList![index],
                                                heroId:
                                                    '${moviesList![index].id}');
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
                                                          BorderRadius.circular(
                                                              8.0),
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            moviesList![index]
                                                                .title!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                moviesList![
                                                                        index]
                                                                    .voteAverage!
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins'),
                                                              ),
                                                              const Icon(
                                                                  Icons.star,
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
                                Visibility(
                                    visible: isLoading,
                                    child: const Center(
                                        child: CircularProgressIndicator())),
                              ],
                            ),
                      tvList!.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Oops! the TV show you searched doesn\'t exist, if you searched for a movie or a person select either of the tabs above',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: moviescrollController,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: tvList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return TVDetailPage(
                                                tvSeries: tvList![index],
                                                heroId: '${tvList![index].id}');
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
                                                      tag:
                                                          '${tvList![index].id}',
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: tvList![index]
                                                                    .posterPath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : FadeInImage(
                                                                image: NetworkImage(
                                                                    TMDB_BASE_IMAGE_URL +
                                                                        'w500/' +
                                                                        tvList![index]
                                                                            .posterPath!),
                                                                fit: BoxFit
                                                                    .cover,
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            tvList![index]
                                                                .originalName!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                tvList![index]
                                                                    .voteAverage!
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Poppins'),
                                                              ),
                                                              const Icon(
                                                                  Icons.star,
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
                                Visibility(
                                    visible: isLoading,
                                    child: const Center(
                                        child: CircularProgressIndicator())),
                              ],
                            ),
                      personList!.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Oops! the person you searched doesn\'t exist, if you searched for a TV show or a movie select either of the tabs above',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: personcrollController,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: personList!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return SearchedPersonDetailPage(
                                                person: personList![index],
                                                heroId:
                                                    '${personList![index].id}');
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
                                                    height: 85,
                                                    child: Hero(
                                                      tag:
                                                          '${personList![index].id}',
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                        child: personList![
                                                                        index]
                                                                    .profilePath ==
                                                                null
                                                            ? Image.asset(
                                                                'assets/images/na_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : FadeInImage(
                                                                image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                                                    'w500/' +
                                                                    personList![
                                                                            index]
                                                                        .profilePath!),
                                                                fit: BoxFit
                                                                    .cover,
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            personList![index]
                                                                .name!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                    'Poppins'),
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
                                Visibility(
                                    visible: isLoading,
                                    child: const Center(
                                        child: CircularProgressIndicator())),
                              ],
                            ),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
