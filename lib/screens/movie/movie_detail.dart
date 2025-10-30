// ignore_for_file: avoid_unnecessary_containers

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart';
import '/api/endpoints.dart';
import '/models/movie.dart';
import '/widgets/movie_widgets.dart';
import '../../controllers/bookmark_database_controller.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.heroId,
  });
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<MovieDetailPage> {
  late TabController tabController;
  bool? isBookmarked;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    mixpanelUpload(context);
  }

  void mixpanelUpload(BuildContext context) {
    final mixpanel =
        Provider.of<SettingsProvider>(context, listen: false).mixpanel;
    mixpanel.track('Most viewed movie pages', properties: {
      'Movie name': '${widget.movie.title}',
      'Movie id': '${widget.movie.id}',
      'Is Movie adult?': '${widget.movie.adult}'
    });
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;

    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: themeMode == 'dark' || themeMode == 'amoled'
                ? Colors.white
                : Colors.black,
            forceElevated: true,
            backgroundColor: themeMode == 'dark' || themeMode == 'amoled'
                ? Colors.black
                : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.movie.releaseDate == null
                  ? widget.movie.title!
                  : widget.movie.releaseDate == ''
                      ? widget.movie.title!
                      : '${widget.movie.title!} (${DateTime.parse(widget.movie.releaseDate!).year})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )),
            expandedHeight: 390,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  MovieDetailQuickInfo(
                    heroId: widget.heroId,
                    movie: widget.movie,
                  ),
                  const SizedBox(height: 18),
                  MovieDetailOptions(movie: widget.movie),
                ],
              ),
            ),
          ),

          // body
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [MovieAbout(movie: widget.movie)],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Share.share(tr(
              'share_movie',
              namedArgs: {
                'title': widget.movie.title!,
                'rating': widget.movie.voteAverage!.toStringAsFixed(1),
                'id': widget.movie.id.toString()
              },
            ));
          },
          child: const Icon(FontAwesomeIcons.shareNodes)),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void modalBottomSheetMenu(String country) {
    final lang = Provider.of<SettingsProvider>(context).appLanguage;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return WatchProvidersDetails(
          api: Endpoints.getMovieWatchProviders(widget.movie.id!, lang),
          country: country,
        );
      },
    );
  }
}
