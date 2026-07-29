import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/network.dart';
import '../../models/movie.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';
import '../../ui_components/movie_ui_components.dart';

class DiscoverMovieResult extends StatefulWidget {
  const DiscoverMovieResult(
      {required this.api,
      required this.includeAdult,
      required this.page,
      super.key});
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
  Object? error;

  String _requestUrl(int page) {
    final uri = Uri.parse(widget.api);
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'include_adult': '${widget.includeAdult ?? false}',
        'page': '$page',
      },
    ).toString();
  }

  Future<void> _loadMore() async {
    if (isLoading || moviesList == null) return;
    setState(() => isLoading = true);
    final settings = context.read<SettingsProvider>();
    final dependencies = context.read<AppDependencyProvider>();
    try {
      final value = await fetchMovies(
        _requestUrl(pageNum),
        settings.enableProxy,
        dependencies.tmdbProxy,
      );
      if (!mounted) return;
      setState(() {
        moviesList!.addAll(value);
        isLoading = false;
        pageNum++;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception;
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 320) _loadMore();
  }

  Future<void> _loadInitial() async {
    final settings = context.read<SettingsProvider>();
    final dependencies = context.read<AppDependencyProvider>();
    try {
      final value = await fetchMovies(
        _requestUrl(widget.page),
        settings.enableProxy,
        dependencies.tmdbProxy,
      );
      if (mounted) setState(() => moviesList = value);
    } catch (exception) {
      if (mounted) setState(() => error = exception);
    }
  }

  @override
  void initState() {
    super.initState();
    pageNum = widget.page + 1;
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    final imageQuality = Provider.of<SettingsProvider>(context).imageQuality;
    final viewType = Provider.of<SettingsProvider>(context).defaultView;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('discover_movies')),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: error != null && moviesList == null
          ? AppEmptyState(
              icon: PhosphorIcons.cloudSlash(),
              title: tr('error_occured'),
              message: tr('check_connection'),
              action: FilledButton(
                onPressed: () {
                  setState(() => error = null);
                  _loadInitial();
                },
                child: Text(tr('retry')),
              ),
            )
          : moviesList == null && viewType == 'grid'
              ? const AppMediaGridShimmer()
              : moviesList == null
                  ? const AppMediaListShimmer()
                  : moviesList!.isEmpty
                      ? AppEmptyState(
                          icon: PhosphorIcons.filmSlate(),
                          title: tr('discover_movies'),
                          message: tr('parameter_movie_404'),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: viewType == 'grid'
                                  ? MovieGridView(
                                      scrollController: _scrollController,
                                      moviesList: moviesList,
                                      imageQuality: imageQuality,
                                      themeMode: themeMode,
                                    )
                                  : MovieListView(
                                      scrollController: _scrollController,
                                      moviesList: moviesList,
                                      themeMode: themeMode,
                                      imageQuality: imageQuality,
                                    ),
                            ),
                            AppLoadingFooter(visible: isLoading),
                          ],
                        ),
    );
  }
}
