import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../functions/function.dart';
import '../../models/movie_stream_metadata.dart';
import '../../models/tv_stream_metadata.dart';
import '../../provider/settings_provider.dart';
import '../../screens/movie/movie_video_loader.dart';
import '../../screens/tv/tv_video_loader.dart';
import '../../services/app_session_state_store.dart';
import '../focus/tv_focus_memory.dart';
import '../focus/tv_screen_focus_controller.dart';
import '../models/tv_media_item.dart';
import '../navigation/tv_back_dispatcher.dart';
import '../screens/tv_catalog_screen.dart';
import '../screens/tv_home_screen.dart';
import '../screens/tv_library_screen.dart';
import '../screens/tv_live_screen.dart';
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

class _TvHomeShellState extends State<TvHomeShell> with RestorationMixin {
  final TvFocusMemory _focusMemory = TvFocusMemory();
  final GlobalKey<TvNavigationRailState> _navigationRailKey =
      GlobalKey<TvNavigationRailState>();
  final TvScreenFocusController _searchFocusController =
      TvScreenFocusController();
  final TvScreenFocusController _moviesFocusController =
      TvScreenFocusController();
  final TvScreenFocusController _seriesFocusController =
      TvScreenFocusController();
  final TvScreenFocusController _settingsFocusController =
      TvScreenFocusController();
  late final FocusScopeNode _shellFocusScope;
  late final List<TvNavigationDestination> _destinations;
  late final AppSessionStateStore _sessionState;
  late final RestorableString _selectedDestinationId;
  int _libraryRevision = 0;

  @override
  String get restorationId => 'television_home';

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
        id: 'live',
        label: 'Live TV',
        icon: PhosphorIcons.broadcast(),
        selectedIcon: PhosphorIcons.broadcast(PhosphorIconsStyle.fill),
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
    _sessionState = AppSessionStateStore(sharedPrefsSingleton);
    _selectedDestinationId = RestorableString(
      _sessionState.televisionDestination ?? 'home',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsProvider>().analytics.trackNavigation(
            destination: _selectedDestinationId.value,
            surface: 'tv',
            source: 'restored',
          );
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(
      _selectedDestinationId,
      'selected_destination',
    );
    if (!AppSessionStateStore.televisionDestinations
        .contains(_selectedDestinationId.value)) {
      _selectedDestinationId.value = 'home';
    }
  }

  @override
  void dispose() {
    _selectedDestinationId.dispose();
    _shellFocusScope.dispose();
    super.dispose();
  }

  void _selectDestination(String destinationId) {
    if (_selectedDestinationId.value == destinationId) return;
    setState(() => _selectedDestinationId.value = destinationId);
    context.read<SettingsProvider>().analytics.trackNavigation(
          destination: destinationId,
          surface: 'tv',
        );
    unawaited(_sessionState.rememberTelevisionDestination(destinationId));
  }

  Future<bool> _handleBack() async {
    if (_navigationRailKey.currentState?.hasFocus != true) {
      _navigationRailKey.currentState
          ?.requestFocus(_selectedDestinationId.value);
      return true;
    }
    if (_selectedDestinationId.value == 'home') return false;
    setState(() => _selectedDestinationId.value = 'home');
    context.read<SettingsProvider>().analytics.trackNavigation(
          destination: 'home',
          surface: 'tv',
          source: 'back',
        );
    unawaited(_sessionState.rememberTelevisionDestination('home'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationRailKey.currentState?.requestFocus('home');
    });
    return true;
  }

  bool _enterDestination(String destinationId) {
    final controller = switch (destinationId) {
      'search' => _searchFocusController,
      'movies' => _moviesFocusController,
      'series' => _seriesFocusController,
      'settings' => _settingsFocusController,
      _ => null,
    };
    if (controller == null) return false;
    _selectDestination(destinationId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.requestFocus();
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
      _navigationRailKey.currentState
          ?.requestFocus(_selectedDestinationId.value);
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
                          selectedId: _selectedDestinationId.value,
                          autofocusId: _selectedDestinationId.value,
                          metrics: metrics,
                          onDestinationSelected: _selectDestination,
                          onMoveRight: _enterDestination,
                        ),
                        SizedBox(width: metrics.railGap),
                        Expanded(
                          child: ClipRect(
                            child: Builder(
                              builder: (context) {
                                final selectedIndex = _destinations.indexWhere(
                                  (destination) =>
                                      destination.id ==
                                      _selectedDestinationId.value,
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
                                    focusController: _searchFocusController,
                                  ),
                                  TvCatalogScreen(
                                    kind: TvMediaKind.movie,
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                    focusController: _moviesFocusController,
                                  ),
                                  TvCatalogScreen(
                                    kind: TvMediaKind.series,
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                    focusController: _seriesFocusController,
                                  ),
                                  TvLiveScreen(metrics: metrics),
                                  TvLibraryScreen(
                                    key: ValueKey<int>(_libraryRevision),
                                    metrics: metrics,
                                    onOpenMedia: _openMedia,
                                  ),
                                  TvProfileScreen(metrics: metrics),
                                  TvSettingsScreen(
                                    metrics: metrics,
                                    focusController: _settingsFocusController,
                                  ),
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
