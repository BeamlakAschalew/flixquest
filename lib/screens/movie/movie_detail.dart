// ignore_for_file: avoid_unnecessary_containers

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../provider/settings_provider.dart';
import '/api/endpoints.dart';
import '/models/movie.dart';
import '/widgets/movie_widgets.dart';
import '../../controllers/database_controller.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String heroId;

  const MovieDetailPage({
    Key? key,
    required this.movie,
    required this.heroId,
  }) : super(key: key);
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
      'Movie name': '${widget.movie.originalTitle}',
      'Movie id': '${widget.movie.id}',
      'Is Movie adult?': '${widget.movie.adult}'
    });
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).darktheme;

    super.build(context);
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 1,
            shadowColor: isDark ? Colors.white : Colors.black,
            forceElevated: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            leading: SABTN(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            title: SABT(
                child: Text(
              widget.movie.releaseDate == ""
                  ? widget.movie.title!
                  : '${widget.movie.title!} (${DateTime.parse(widget.movie.releaseDate!).year})',
              style: const TextStyle(
                color: Color(0xFFF57C00),
              ),
            )),
            expandedHeight: 380,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                children: [
                  MovieDetailQuickInfo(
                    heroId: widget.heroId,
                    movie: widget.movie,
                  ),

                  const SizedBox(height: 18),

                  // ratings / lists / bookmark options
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
    );
  }

  @override
  bool get wantKeepAlive => true;

  void modalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return WatchProvidersDetails(
          api: Endpoints.getMovieWatchProviders(widget.movie.id!),
        );
      },
    );
  }
}
