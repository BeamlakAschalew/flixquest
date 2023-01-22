import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_constants.dart';
import '../../models/function.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/movie_ui_components.dart';
import '../../widgets/common_widgets.dart';

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
  bool requestFailed = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(Uri.parse('${widget.api}&page=$pageNum'));
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
    getData();
    getMoreData();
  }

  void getData() {
    fetchMovies('${widget.api}&page=${widget.page}}').then((value) {
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
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
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
            child: moviesList == null && viewType == 'grid'
                ? moviesAndTVShowGridShimmer(isDark)
                : moviesList == null && viewType == 'list'
                    ? Container(
                        color: isDark
                            ? const Color(0xFF000000)
                            : const Color(0xFFFFFFFF),
                        child: mainPageVerticalScrollShimmer(
                            isDark: isDark,
                            isLoading: isLoading,
                            scrollController: _scrollController))
                    : moviesList!.isEmpty
                        ? Container(
                            color: isDark
                                ? const Color(0xFF000000)
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
                                    ? const Color(0xFF000000)
                                    : const Color(0xFFFFFFFF),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                                child: viewType == 'grid'
                                                    ? MovieGridView(
                                                        scrollController:
                                                            _scrollController,
                                                        moviesList: moviesList,
                                                        imageQuality:
                                                            imageQuality,
                                                        isDark: isDark)
                                                    : MovieListView(
                                                        scrollController:
                                                            _scrollController,
                                                        moviesList: moviesList,
                                                        isDark: isDark,
                                                        imageQuality:
                                                            imageQuality)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                        visible: isLoading,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        )),
                                  ],
                                ),
                              )));
  }

  Widget retryWidget(isDark) {
    return Container(
      color: isDark ? const Color(0xFF000000) : const Color(0xFFF7F7F7),
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
