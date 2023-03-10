import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        if (mounted) {
          fetchMovies(
                  '${widget.api}&include_adult=${widget.includeAdult}&page=$pageNum')
              .then((value) {
            if (mounted) {
              setState(() {
                moviesList!.addAll(value);
                isLoading = false;
                pageNum++;
              });
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMovies(
            '${widget.api}&page=${widget.page}&include_adult=${widget.includeAdult}')
        .then((value) {
      if (mounted) {
        setState(() {
          moviesList = value;
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
                        child: mainPageVerticalScrollShimmer(
                            isDark: isDark,
                            isLoading: isLoading,
                            scrollController: _scrollController))
                    : moviesList!.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: const Center(
                              child: Text(
                                'Oops! movies for the parameters you specified doesn\'t exist :(',
                                style: kTextHeaderStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                                                  scrollController:
                                                      _scrollController,
                                                  moviesList: moviesList,
                                                  imageQuality: imageQuality,
                                                  isDark: isDark)
                                              : MovieListView(
                                                  scrollController:
                                                      _scrollController,
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
                                    child: Center(
                                        child: LinearProgressIndicator()),
                                  )),
                            ],
                          )));
  }
}
