import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../controllers/bookmark_database_controller.dart';
import '../../models/movie.dart';
import '../../models/tv.dart';
import '../../services/globle_method.dart';
import '/screens/common/sync_screen.dart';
import 'package:flutter/material.dart';
import '../../ui_components/app_ui_components.dart';
import '../movie/bookmark_movies_tab.dart';
import '../tv/bookmark_tv_tab.dart';

import '../../services/bookmark_sync_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({this.embedded = false, super.key});

  final bool embedded;

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  MovieDatabaseController movieDatabaseController = MovieDatabaseController();
  TVDatabaseController tvDatabaseController = TVDatabaseController();
  List<TV>? tvList;
  List<Movie>? movieList;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getData();
    fetchMovieBookmark();
    fetchTVBookmark();
    _triggerAutoSync();
  }

  void _triggerAutoSync() async {
    if (BookmarkSyncService.instance.canSync) {
      await BookmarkSyncService.instance.autoSyncIfSignedIn();
      if (mounted) {
        fetchMovieBookmark();
        fetchTVBookmark();
      }
    }
  }

  void getData() async {
    user = _auth.currentUser;
    uid = user?.uid;
  }

  Future<void> setMovieData() async {
    var mov = await movieDatabaseController.getMovieList();
    if (mounted) {
      setState(() {
        movieList = mov;
      });
    }
  }

  void fetchMovieBookmark() async {
    await setMovieData();
  }

  Future<void> setTVData() async {
    var tv = await tvDatabaseController.getTVList();
    if (mounted) setState(() => tvList = tv);
  }

  void fetchTVBookmark() async {
    await setTVData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(PhosphorIcons.caretLeft())),
              title: Text(tr('bookmarks')),
              actions: [
                  IconButton(
                      onPressed: () {
                        _syncBookmarks();
                      },
                      icon: Icon(PhosphorIcons.arrowsClockwise()))
                ]),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (widget.embedded)
              AppResponsiveContent(
                padding: const EdgeInsets.fromLTRB(20, 18, 8, 14),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/fq_svg.svg',
                      width: 30,
                      height: 30,
                      colorFilter:
                          ColorFilter.mode(colors.primary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        tr('bookmarks'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: tr('sync'),
                      onPressed: _syncBookmarks,
                      icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18),
                    ),
                  ],
                ),
              ),
            AppResponsiveContent(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: colors.onPrimary,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  tabs: [
                    Tab(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.filmStrip(), size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              tr('movies'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.television(), size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              tr('tv_series'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  MovieBookmark(movieList: movieList),
                  TVBookmark(
                    tvList: tvList,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _syncBookmarks() {
    if (user == null || user!.isAnonymous) {
      GlobalMethods.showCustomScaffoldMessage(
        SnackBar(
          content: Text(
            tr('bookmark_feature_notice'),
            style: kTextVerySmallBodyStyle,
            maxLines: 6,
          ),
        ),
        context,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SyncScreen()),
    ).then((_) {
      fetchMovieBookmark();
      fetchTVBookmark();
    });
  }
}
