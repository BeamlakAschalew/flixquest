import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemax/widgets/movie_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/movie_ui_components.dart';
import '../../widgets/common_widgets.dart';
import 'movie_detail.dart';

class MovieBookmark extends StatefulWidget {
  const MovieBookmark({
    Key? key,
  }) : super(key: key);

  @override
  State<MovieBookmark> createState() => _MovieBookmarkState();
}

class _MovieBookmarkState extends State<MovieBookmark> {
  List<Movie>? movieList;
  int count = 0;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    fetchBookmark();
    super.initState();
  }

  Future<void> setData() async {
    var mov = await movieDatabaseController.getMovieList();
    setState(() {
      movieList = mov;
    });
  }

  void fetchBookmark() async {
    await setData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return movieList == null && viewType == 'grid'
        ? Container(
            color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            child: moviesAndTVShowGridShimmer(isDark))
        : movieList == null && viewType == 'list'
            ? Container(
                color:
                    isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    isLoading: false,
                    scrollController: _scrollController))
            : movieList!.isEmpty
                ? Container(
                    color: isDark
                        ? const Color(0xFF000000)
                        : const Color(0xFFFFFFFF),
                    child: const Center(
                      child: Text(
                        'You don\'t have any movies bookmarked :)',
                        textAlign: TextAlign.center,
                        style: kTextSmallHeaderStyle,
                      ),
                    ),
                  )
                : Container(
                    color: isDark
                        ? const Color(0xFF000000)
                        : const Color(0xFFFFFFFF),
                    child: Column(
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
                                            moviesList: movieList,
                                            imageQuality: imageQuality,
                                            isDark: isDark)
                                        : MovieListView(
                                            imageQuality: imageQuality,
                                            isDark: isDark,
                                            moviesList: movieList,
                                            scrollController: _scrollController,
                                          )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
  }
}
