import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import '../../constants/api_constants.dart';
import '../../models/function.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/movie_ui_components.dart';
import '../../widgets/common_widgets.dart';

class MainMoviesList extends StatefulWidget {
  final String api;
  final bool? includeAdult;
  final String discoverType;
  final bool isTrending;
  final String title;
  const MainMoviesList({
    Key? key,
    required this.api,
    required this.discoverType,
    required this.isTrending,
    required this.includeAdult,
    required this.title,
  }) : super(key: key);
  @override
  MainMoviesListState createState() => MainMoviesListState();
}

class MainMoviesListState extends State<MainMoviesList> {
  List<Movie>? moviesList;
  final _scrollController = ScrollController();
  int pageNum = 2;
  bool isLoading = false;
  final client = HttpClient();
  RetryOptions retryOptions = const RetryOptions(
      maxDelay: Duration(milliseconds: 300),
      delayFactor: Duration(seconds: 0),
      maxAttempts: 1000);
  Duration timeOut = const Duration(seconds: 10);

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          try {
            var response = await retryOptions.retry(
              () => http.get(
                Uri.parse(
                    "$TMDB_API_BASE_URL/movie/${widget.discoverType}?api_key=$TMDB_API_KEY&include_adult=${widget.includeAdult}&page=$pageNum"),
              ),
              retryIf: (e) => e is SocketException || e is TimeoutException,
            );
            setState(() {
              pageNum++;
              isLoading = false;
              var newlistMovies =
                  (json.decode(response.body)['results'] as List)
                      .map((i) => Movie.fromJson(i))
                      .toList();
              moviesList!.addAll(newlistMovies);
            });
          } finally {
            client.close();
          }
        } else if (widget.isTrending == true) {
          try {
            var response = await retryOptions.retry(
              () => http.get(
                Uri.parse(
                    "$TMDB_API_BASE_URL/trending/movie/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=${widget.includeAdult}&page=$pageNum"),
              ),
              retryIf: (e) => e is SocketException || e is TimeoutException,
            );
            setState(() {
              pageNum++;
              isLoading = false;
              var newlistMovies =
                  (json.decode(response.body)['results'] as List)
                      .map((i) => Movie.fromJson(i))
                      .toList();
              moviesList!.addAll(newlistMovies);
            });
          } finally {
            client.close();
          }
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchMovies('${widget.api}&include_adult=${widget.includeAdult}')
        .then((value) {
      setState(() {
        moviesList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} movies'),
      ),
      body: moviesList == null && viewType == 'grid'
          ? moviesAndTVShowGridShimmer(isDark)
          : moviesList == null && viewType == 'list'
              ? mainPageVerticalScrollShimmer(
                  isDark: isDark,
                  isLoading: isLoading,
                  scrollController: _scrollController)
              : moviesList!.isEmpty
                  ? const Center(
                      child: Text('Oops! the movies don\'t exist :('),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Expanded(
                                    child: viewType == 'grid'
                                        ? MovieGridView(
                                            scrollController: _scrollController,
                                            moviesList: moviesList,
                                            imageQuality: imageQuality,
                                            isDark: isDark)
                                        : MovieListView(
                                            scrollController: _scrollController,
                                            moviesList: moviesList,
                                            isDark: isDark,
                                            imageQuality: imageQuality)),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )),
                      ],
                    ),
    );
  }
}
