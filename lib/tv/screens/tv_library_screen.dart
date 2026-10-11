import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/recently_watched_provider.dart';
import '../app/tv_design.dart';
import '../app/tv_shell_layout.dart';
import '../controllers/tv_catalog_controller.dart';
import '../focus/tv_screen_focus_controller.dart';
import '../models/tv_media_item.dart';
import '../widgets/tv_browse_skeleton.dart';
import '../widgets/tv_browse_view.dart';
import '../widgets/tv_continue_watching_menu.dart';
import '../widgets/tv_shortcut_tile.dart';
import '../widgets/tv_state_panel.dart';

/// My List as a browse page: saved movies and series, then what is being
/// watched, with the spotlight and backdrop following focus.
///
/// Rows stop at [rowLimit] titles, so a long list does not mount hundreds of
/// cards; past that, a See all tile opens the rest as a grid.
class TvLibraryScreen extends StatefulWidget {
  const TvLibraryScreen({
    required this.metrics,
    required this.onOpenMedia,
    this.onContinueWatching,
    this.onOpenCollection,
    this.revision = 0,
    this.focusController,
    this.controller = const TvCatalogController(),
    super.key,
  });

  final TvShellMetrics metrics;
  final ValueChanged<TvMediaItem> onOpenMedia;
  final FutureOr<void> Function(TvMediaItem item)? onContinueWatching;
  final ValueChanged<TvCollection>? onOpenCollection;

  /// Bumped when a bookmark may have changed; the list reloads in place so
  /// the card the user came back to can take focus again.
  final int revision;
  final TvScreenFocusController? focusController;
  final TvCatalogController controller;

  static const rowLimit = 30;

  @override
  State<TvLibraryScreen> createState() => _TvLibraryScreenState();
}

class _TvLibraryScreenState extends State<TvLibraryScreen> {
  late Future<List<TvMediaItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.controller.loadLibrary();
  }

  @override
  void didUpdateWidget(TvLibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) {
      _items = widget.controller.loadLibrary();
    }
  }

  void _refresh() {
    setState(() => _items = widget.controller.loadLibrary());
  }

  Future<void> _removeFromContinueWatching(TvMediaItem item) async {
    final removal = TvContinueWatchingRemoval.forItem(item);
    if (removal == null) return;
    final confirmed = await confirmRemoveFromContinueWatching(
      context: context,
      item: item,
    );
    if (!confirmed || !mounted) return;
    await removal.apply(context.read<RecentProvider>());
  }

  TvCollection _collection(TvMediaKind kind, List<TvMediaItem> items) {
    const page = 24;
    return TvCollection(
      id: 'library-${kind == TvMediaKind.movie ? 'movies' : 'series'}',
      title: tr(kind == TvMediaKind.movie ? 'movies' : 'series'),
      kicker: tr('tv_my_list'),
      loadPage: (number) async {
        final start = (number - 1) * page;
        if (start >= items.length) return const <TvMediaItem>[];
        return items.sublist(start, (start + page).clamp(0, items.length));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final insets = TvShellInsets.of(context);
    final recent = context.watch<RecentProvider?>();
    final continueWatching = <TvMediaItem>[
      ...?recent?.movies.map(TvMediaItem.fromRecentMovie),
      ...?recent?.episodes.map(TvMediaItem.fromRecentEpisode),
    ].where((item) => item.id >= 0).take(16).toList(growable: false);

    return FutureBuilder<List<TvMediaItem>>(
      future: _items,
      builder: (context, snapshot) {
        // A reload keeps the previous list on screen (FutureBuilder carries
        // its data over), so the rows and their focus survive.
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return TvBrowseSkeleton(metrics: widget.metrics);
        }
        if (snapshot.hasError && !snapshot.hasData) {
          return Padding(
            padding: insets,
            child: TvStatePanel.error(onRetry: _refresh),
          );
        }
        final saved = snapshot.data ?? const <TvMediaItem>[];
        if (saved.isEmpty && continueWatching.isEmpty) {
          return Padding(
            padding: insets,
            child: TvStatePanel(
              title: tr('tv_your_list_is_empty'),
              message: tr(
                  'tv_add_a_movie_or_series_to_my_list_from_its_page_and_it_will_wait_for_you_here'),
              icon: PhosphorIcons.bookmarkSimple(),
              actionLabel: tr('refresh'),
              onAction: _refresh,
            ),
          );
        }
        final movies = saved
            .where((item) => item.kind == TvMediaKind.movie)
            .toList(growable: false);
        final series = saved
            .where((item) => item.kind == TvMediaKind.series)
            .toList(growable: false);
        final overflow = <(TvMediaKind, List<TvMediaItem>)>[
          if (movies.length > TvLibraryScreen.rowLimit)
            (TvMediaKind.movie, movies),
          if (series.length > TvLibraryScreen.rowLimit)
            (TvMediaKind.series, series),
        ];

        return TvBrowseView(
          featured: saved.firstOrNull ?? continueWatching.first,
          metrics: widget.metrics,
          onOpenMedia: widget.onOpenMedia,
          focusController: widget.focusController,
          focusMemoryScope: 'tv-library-row',
          showBillboard: false,
          rows: <TvBrowseRow>[
            TvMediaRow(
              title: tr('tv_movies_in_my_list'),
              scopeId: 'library-movies',
              items: movies.take(TvLibraryScreen.rowLimit).toList(),
            ),
            TvMediaRow(
              title: tr('tv_series_in_my_list'),
              scopeId: 'library-series',
              items: series.take(TvLibraryScreen.rowLimit).toList(),
            ),
            TvMediaRow(
              title: tr('tv_continue_watching'),
              scopeId: 'library-continue-watching',
              items: continueWatching,
              onItemActivated: widget.onContinueWatching,
              onItemMenu: _removeFromContinueWatching,
              itemMenuHint: tr('tv_hold_ok_to_remove'),
              showBadges: false,
            ),
            if (widget.onOpenCollection case final open?)
              TvShortcutRow(
                title: tr('see_all'),
                scopeId: 'library-all',
                shortcuts: <TvBrowseShortcut>[
                  for (final (kind, items) in overflow)
                    TvBrowseShortcut(
                      id: 'all-${kind == TvMediaKind.movie ? 'Movies' : 'Series'}',
                      title: tr('tv_library_all', namedArgs: {
                        'kind':
                            tr(kind == TvMediaKind.movie ? 'movies' : 'series'),
                        'count': '${items.length}'
                      }),
                      icon: PhosphorIcons.squaresFour(),
                      facts: <String>[
                        plural('tv_title_count', items.length, name: 'count')
                      ],
                      description: tr('tv_library_description', namedArgs: {
                        'kind':
                            tr(kind == TvMediaKind.movie ? 'movies' : 'series')
                      }),
                      onActivate: () => open(_collection(kind, items)),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
