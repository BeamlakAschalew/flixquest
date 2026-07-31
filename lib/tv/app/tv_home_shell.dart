import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../functions/function.dart';
import '../../models/movie_stream_metadata.dart';
import '../../models/tv_stream_metadata.dart';
import '../../screens/movie/movie_video_loader.dart';
import '../../screens/tv/tv_video_loader.dart';
import '../focus/tv_focus_memory.dart';
import '../models/tv_media_item.dart';
import '../navigation/tv_back_dispatcher.dart';
import '../screens/tv_catalog_screen.dart';
import '../screens/tv_home_screen.dart';
import '../screens/tv_library_screen.dart';
import '../screens/tv_media_details_screen.dart';
import '../screens/tv_profile_screen.dart';
import '../screens/tv_search_screen.dart';
import '../screens/tv_settings_screen.dart';
import '../widgets/tv_navigation_rail.dart';
import 'tv_design.dart';

class TvHomeShell extends StatefulWidget {
  const TvHomeShell({super.key});

  static const shellKey = Key('tv-home-shell');

  @override
  State<TvHomeShell> createState() => _TvHomeShellState();
}

class _TvHomeShellState extends State<TvHomeShell> {
  final TvFocusMemory _focusMemory = TvFocusMemory();
  final GlobalKey<TvNavigationRailState> _navigationRailKey =
      GlobalKey<TvNavigationRailState>();
  late final FocusScopeNode _shellFocusScope;
  late final List<TvNavigationDestination> _destinations;
  String _selectedDestinationId = 'home';
  int _libraryRevision = 0;

  @override
  void initState() {
    super.initState();
    _shellFocusScope = FocusScopeNode(debugLabel: 'TV home shell');
    _destinations = <TvNavigationDestination>[
      TvNavigationDestination(
        id: 'home',
        label: 'Home',
        icon: PhosphorIcons.house(),
        selectedIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
      ),
      TvNavigationDestination(
        id: 'search',
        label: 'Search',
        icon: PhosphorIcons.magnifyingGlass(),
      ),
      TvNavigationDestination(
        id: 'movies',
        label: 'Movies',
        icon: PhosphorIcons.filmSlate(),
        selectedIcon: PhosphorIcons.filmSlate(PhosphorIconsStyle.fill),
      ),
      TvNavigationDestination(
        id: 'series',
        label: 'Series',
        icon: PhosphorIcons.television(),
        selectedIcon: PhosphorIcons.television(PhosphorIconsStyle.fill),
      ),
      TvNavigationDestination(
        id: 'library',
        label: 'My List',
        icon: PhosphorIcons.bookmarkSimple(),
        selectedIcon: PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill),
      ),
      TvNavigationDestination(
        id: 'profile',
        label: 'Profile',
        icon: PhosphorIcons.user(),
        selectedIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
      ),
      TvNavigationDestination(
        id: 'settings',
        label: 'Settings',
        icon: PhosphorIcons.gear(),
        selectedIcon: PhosphorIcons.gear(PhosphorIconsStyle.fill),
      ),
    ];
  }

  @override
  void dispose() {
    _shellFocusScope.dispose();
    super.dispose();
  }

  void _selectDestination(String destinationId) {
    if (_selectedDestinationId == destinationId) return;
    setState(() => _selectedDestinationId = destinationId);
  }

  Future<bool> _handleBack() async {
    if (_selectedDestinationId == 'home') return false;
    setState(() => _selectedDestinationId = 'home');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationRailKey.currentState?.requestFocus('home');
    });
    return true;
  }

  void _restoreFocusAfterRoute(FocusNode? previousFocus) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (previousFocus != null &&
          previousFocus.context != null &&
          previousFocus.canRequestFocus) {
        previousFocus.requestFocus();
        return;
      }
      _navigationRailKey.currentState?.requestFocus(_selectedDestinationId);
    });
  }

  Future<void> _openMedia(TvMediaItem item) async {
    final previousFocus = FocusManager.instance.primaryFocus;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TvMediaDetailsScreen(item: item),
      ),
    );
    if (mounted) {
      setState(() => _libraryRevision++);
      _restoreFocusAfterRoute(previousFocus);
    }
  }

  Future<void> _continueWatching(TvMediaItem item) async {
    final previousFocus = FocusManager.instance.primaryFocus;
    final recentMovie = item.recentMovie;
    final recentEpisode = item.recentEpisode;
    Widget? loader;

    if (recentMovie?.id != null) {
      loader = MovieVideoLoader(
        download: false,
        useTvPlayer: true,
        onTvPlayerExit: () {
          if (!mounted) return;
          setState(() => _libraryRevision++);
          _restoreFocusAfterRoute(previousFocus);
        },
        metadata: MovieStreamMetadata(
          backdropPath: recentMovie!.backdropPath,
          elapsed: recentMovie.elapsed,
          movieId: recentMovie.id,
          movieName: recentMovie.title,
          posterPath: recentMovie.posterPath,
          releaseYear: recentMovie.releaseYear,
          isAdult: null,
          releaseDate: null,
        ),
      );
    } else if (recentEpisode?.id != null &&
        recentEpisode?.seriesId != null &&
        recentEpisode?.seasonNum != null &&
        recentEpisode?.episodeNum != null) {
      loader = TVVideoLoader(
        download: false,
        useTvPlayer: true,
        onTvPlayerExit: () {
          if (!mounted) return;
          setState(() => _libraryRevision++);
          _restoreFocusAfterRoute(previousFocus);
        },
        metadata: TVStreamMetadata(
          elapsed: recentEpisode!.elapsed,
          episodeId: recentEpisode.id,
          episodeName: recentEpisode.episodeName,
          episodeNumber: recentEpisode.episodeNum,
          posterPath: recentEpisode.posterPath,
          backdropPath: recentEpisode.backdropPath,
          seasonNumber: recentEpisode.seasonNum,
          seriesName: recentEpisode.seriesName,
          tvId: recentEpisode.seriesId,
          airDate: null,
        ),
      );
    }

    if (loader == null) {
      await _openMedia(item);
      return;
    }
    if (!await checkConnection()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your internet connection.')),
        );
      }
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => loader!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TvFocusMemoryScope(
      memory: _focusMemory,
      child: TvBackDispatcher(
        onBack: _handleBack,
        child: FocusScope(
          node: _shellFocusScope,
          child: Scaffold(
            key: TvHomeShell.shellKey,
            backgroundColor: TvDesign.surfaceFor(context),
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.75, -1),
                  radius: 1.35,
                  colors: <Color>[
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    TvDesign.surfaceFor(context),
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final metrics = TvShellMetrics.fromConstraints(constraints);
                  return SafeArea(
                    minimum: EdgeInsets.all(metrics.safeInset),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TvNavigationRail(
                          key: _navigationRailKey,
                          destinations: _destinations,
                          selectedId: _selectedDestinationId,
                          autofocusId: 'home',
                          metrics: metrics,
                          onDestinationSelected: _selectDestination,
                        ),
                        SizedBox(width: metrics.railGap),
                        Expanded(
                          child: ClipRect(
                            child: Builder(
                              builder: (context) {
                                final selectedIndex = _destinations.indexWhere(
                                  (destination) =>
                                      destination.id == _selectedDestinationId,
                                );
                                final screens = <Widget>[
                                  TvHomeScreen(
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                    onContinueWatching: _continueWatching,
                                  ),
                                  TvSearchScreen(
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                  ),
                                  TvCatalogScreen(
                                    kind: TvMediaKind.movie,
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                  ),
                                  TvCatalogScreen(
                                    kind: TvMediaKind.series,
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                  ),
                                  TvLibraryScreen(
                                    key: ValueKey<int>(_libraryRevision),
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                  ),
                                  TvProfileScreen(metrics: metrics),
                                  TvSettingsScreen(metrics: metrics),
                                ];
                                return IndexedStack(
                                  index: selectedIndex,
                                  children: <Widget>[
                                    for (var index = 0;
                                        index < screens.length;
                                        index++)
                                      ExcludeFocus(
                                        excluding: index != selectedIndex,
                                        child: screens[index],
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
