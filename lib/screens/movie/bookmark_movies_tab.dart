import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../controllers/database_controller.dart';
import '../../models/movie.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/movie_ui_components.dart';
import '../../widgets/common_widgets.dart';

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
        ? Container(child: moviesAndTVShowGridShimmer(isDark))
        : movieList == null && viewType == 'list'
            ? Container(
                child: mainPageVerticalScrollShimmer(
                    isDark: isDark,
                    isLoading: false,
                    scrollController: _scrollController))
            : movieList!.isEmpty
                ? Container(
                    child: const Center(
                      child: Text(
                        'You don\'t have any movies bookmarked :)',
                        textAlign: TextAlign.center,
                        style: kTextSmallHeaderStyle,
                      ),
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
