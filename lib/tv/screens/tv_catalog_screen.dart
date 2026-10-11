import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/common_widgets.dart'
    show AppStreamingService, appStreamingServices;
import '../app/tv_design.dart';
import '../app/tv_shell_layout.dart';
import '../controllers/tv_catalog_controller.dart';
import '../focus/tv_screen_focus_controller.dart';
import '../models/tv_media_item.dart';
import '../widgets/tv_browse_skeleton.dart';
import '../widgets/tv_browse_view.dart';
import '../widgets/tv_media_card.dart' show TvMediaBadge;
import '../widgets/tv_shortcut_tile.dart';
import '../widgets/tv_state_panel.dart';

/// The Movies or Series destination: a browse page of rows, with the phone
/// app's streaming services and the genres as rows of shortcuts.
class TvCatalogScreen extends StatefulWidget {
  const TvCatalogScreen({
    required this.kind,
    required this.metrics,
    required this.onOpenMedia,
    required this.onOpenCollection,
    this.focusController,
    super.key,
  });

  final TvMediaKind kind;
  final TvShellMetrics metrics;
  final ValueChanged<TvMediaItem> onOpenMedia;
  final ValueChanged<TvCollection> onOpenCollection;
  final TvScreenFocusController? focusController;

  @override
  State<TvCatalogScreen> createState() => _TvCatalogScreenState();
}

class _TvCatalogScreenState extends State<TvCatalogScreen> {
  static const _controller = TvCatalogController();
  Future<TvCatalogData>? _data;
  String? _configurationKey;

  bool get _isMovie => widget.kind == TvMediaKind.movie;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    final dependencies = context.watch<AppDependencyProvider>();
    final key = '${widget.kind.name}|${settings.appLanguage}|'
        '${settings.enableProxy}|${dependencies.tmdbProxy}';
    if (_configurationKey != key) {
      _configurationKey = key;
      _data = _load(settings, dependencies);
    }
  }

  Future<TvCatalogData> _load(
    SettingsProvider settings,
    AppDependencyProvider dependencies,
  ) {
    return _controller.loadCatalog(
      kind: widget.kind,
      settings: settings,
      dependencies: dependencies,
    );
  }

  void _retry() {
    setState(() {
      _data = _load(
        context.read<SettingsProvider>(),
        context.read<AppDependencyProvider>(),
      );
    });
  }

  void _openService(AppStreamingService service) {
    widget.onOpenCollection(_controller.serviceCollection(
      kind: widget.kind,
      service: service,
      settings: context.read<SettingsProvider>(),
      dependencies: context.read<AppDependencyProvider>(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    // A full-bleed screen: only the browse view's artwork reaches the edges.
    final insets = TvShellInsets.of(context);
    return FutureBuilder<TvCatalogData>(
      future: _data,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;
        return AnimatedSwitcher(
          // The page fades in over its skeleton rather than cutting to it.
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey<Object>(
              loading ? 'loading' : data?.featured?.stableId ?? 'error',
            ),
            child: loading
                ? TvBrowseSkeleton(metrics: widget.metrics)
                : _buildLoaded(snapshot, insets),
          ),
        );
      },
    );
  }

  Widget _buildLoaded(
      AsyncSnapshot<TvCatalogData> snapshot, EdgeInsets insets) {
    final data = snapshot.data;
    final featured = data?.featured;
    if (snapshot.hasError || data == null || featured == null) {
      return Padding(
        padding: insets,
        child: TvStatePanel(
          title: _isMovie
              ? tr('tv_no_movies_to_show')
              : tr('tv_no_series_to_show'),
          message: tr('tv_flixquest_could_not_load_this_page_try_again'),
          icon:
              _isMovie ? PhosphorIcons.filmSlate() : PhosphorIcons.television(),
          actionLabel: tr('retry'),
          onAction: _retry,
        ),
      );
    }
    String key(TvMediaItem item) => '${item.kind.name}:${item.id}';
    final topTen = data.topTen.map(key).toSet();
    // Series on the air right now; upcoming movies have nothing new yet.
    final airing = _isMovie ? const <String>{} : data.fresh.map(key).toSet();
    return TvBrowseView(
      featured: featured,
      rows: _rows(data),
      metrics: widget.metrics,
      onOpenMedia: widget.onOpenMedia,
      focusController: widget.focusController,
      focusMemoryScope: 'tv-${widget.kind.name}-row',
      badgeFor: (item) => topTen.contains(key(item))
          ? TvMediaBadge.top10
          : airing.contains(key(item))
              ? TvMediaBadge.newEpisodes
              : null,
    );
  }

  List<TvBrowseRow> _rows(TvCatalogData data) {
    final kind = widget.kind.name;
    return <TvBrowseRow>[
      TvTopTenRow(
        title: tr(_isMovie ? 'top_10_movies_today' : 'top_10_series_today'),
        scopeId: '$kind-top-ten',
        items: data.topTen,
      ),
      TvMediaRow(
        title: tr('tv_trending_now'),
        scopeId: '$kind-trending',
        items: data.trending,
      ),
      TvMediaRow(
        title: tr(_isMovie ? 'popular_movies' : 'popular_series'),
        scopeId: '$kind-popular',
        items: data.popular,
      ),
      TvShortcutRow(
        title: tr('streaming_services'),
        scopeId: '$kind-services',
        shortcuts: <TvBrowseShortcut>[
          for (final service in appStreamingServices)
            TvBrowseShortcut(
              id: 'service-${service.providerId}',
              title: service.name,
              facts: <String>[tr('tv_streaming_service')],
              description: tr('tv_service_description', namedArgs: {
                'kind': tr(_isMovie ? 'movies' : 'series'),
                'service': service.name
              }),
              logoAsset: service.imagePath,
              onActivate: () => _openService(service),
            ),
        ],
      ),
      TvMediaRow(
        title: tr('tv_top_rated'),
        scopeId: '$kind-top-rated',
        items: data.topRated,
      ),
      TvMediaRow(
        title: _isMovie ? tr('tv_coming_soon') : tr('new_episodes'),
        scopeId: '$kind-fresh',
        items: data.fresh,
        // Every card here would say New episodes.
        showBadges: _isMovie,
      ),
      TvShortcutRow(
        title: tr('genres'),
        scopeId: '$kind-genres',
        shortcuts: <TvBrowseShortcut>[
          for (final genre in data.genres)
            TvBrowseShortcut(
              id: 'genre-${genre.genreID}',
              title: genre.genreName!,
              facts: <String>[tr('tv_genre')],
              description: tr('tv_genre_description', namedArgs: {
                'genre': genre.genreName!,
                'kind': tr(_isMovie ? 'movies' : 'series')
              }),
              onActivate: () => widget.onOpenCollection(
                _controller.genreCollection(
                  kind: widget.kind,
                  genre: genre,
                  settings: context.read<SettingsProvider>(),
                  dependencies: context.read<AppDependencyProvider>(),
                ),
              ),
            ),
        ],
      ),
      for (final shelf in data.serviceShelves)
        TvMediaRow(
          title:
              tr('tv_popular_on', namedArgs: {'service': shelf.service.name}),
          scopeId: '$kind-on-${shelf.service.providerId}',
          items: shelf.items,
        ),
    ];
  }
}
