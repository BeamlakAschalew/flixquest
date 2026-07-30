import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../app/tv_design.dart';
import '../controllers/tv_catalog_controller.dart';
import '../focus/tv_focusable.dart';
import '../models/tv_media_item.dart';
import '../widgets/tv_content_grid.dart';
import '../widgets/tv_media_card.dart';
import '../widgets/tv_state_panel.dart';

class TvSearchScreen extends StatefulWidget {
  const TvSearchScreen({
    required this.metrics,
    required this.onOpenMedia,
    super.key,
  });

  final TvShellMetrics metrics;
  final ValueChanged<TvMediaItem> onOpenMedia;

  @override
  State<TvSearchScreen> createState() => _TvSearchScreenState();
}

class _TvSearchScreenState extends State<TvSearchScreen> {
  static const _controller = TvCatalogController();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode(debugLabel: 'TV search query');
  Future<List<TvMediaItem>>? _results;
  String _submittedQuery = '';
  bool _queryHasFocus = false;
  TvMediaKind _selectedKind = TvMediaKind.movie;

  @override
  void initState() {
    super.initState();
    _queryFocusNode.addListener(_handleQueryFocus);
  }

  void _handleQueryFocus() {
    if (_queryHasFocus != _queryFocusNode.hasFocus) {
      setState(() => _queryHasFocus = _queryFocusNode.hasFocus);
    }
  }

  void _submit() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      _queryFocusNode.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    final results = _controller.search(
      query: query,
      settings: context.read<SettingsProvider>(),
      dependencies: context.read<AppDependencyProvider>(),
    );
    setState(() {
      _submittedQuery = query;
      _selectedKind = TvMediaKind.movie;
      _results = results.then((items) {
        final hasMovies = items.any((item) => item.kind == TvMediaKind.movie);
        final hasSeries = items.any((item) => item.kind == TvMediaKind.series);
        if (mounted && !hasMovies && hasSeries) {
          setState(() => _selectedKind = TvMediaKind.series);
        }
        return items;
      });
    });
  }

  @override
  void dispose() {
    _queryFocusNode
      ..removeListener(_handleQueryFocus)
      ..dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.metrics.contentPadding,
        0,
        widget.metrics.contentPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(PhosphorIcons.magnifyingGlass(),
                  color: colors.primary, size: 32),
              const SizedBox(width: 13),
              Text(
                'Search',
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 34,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.metrics.compact ? 16 : 24),
          FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: _queryHasFocus
                            ? colors.primary
                            : colors.outlineVariant,
                        width: _queryHasFocus ? 3 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _queryController,
                      focusNode: _queryFocusNode,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      onSubmitted: (_) => _submit(),
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 17,
                        ),
                        hintText: 'Movies and series',
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                TvFocusable(
                  semanticLabel: 'Search FlixQuest',
                  onActivate: _submit,
                  focusScale: 1.025,
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(PhosphorIcons.magnifyingGlass(),
                            color: colors.onPrimary),
                        const SizedBox(width: 10),
                        Text(
                          'Search',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontFamily: 'FigtreeSB',
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.metrics.compact ? 10 : 18),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final future = _results;
    if (future == null) {
      return TvStatePanel(
        title: 'Find something to watch',
        message: 'Select the search field to open the TV keyboard.',
        icon: PhosphorIcons.keyboard(),
      );
    }
    return FutureBuilder<List<TvMediaItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return TvStatePanel.error(onRetry: _submit);
        }
        final items = snapshot.data ?? const <TvMediaItem>[];
        if (items.isEmpty) {
          return TvStatePanel(
            title: 'No matches',
            message: 'No movies or series matched “$_submittedQuery”.',
            icon: PhosphorIcons.magnifyingGlass(),
          );
        }
        final movies = items
            .where((item) => item.kind == TvMediaKind.movie)
            .toList(growable: false);
        final series = items
            .where((item) => item.kind == TvMediaKind.series)
            .toList(growable: false);
        final selectedItems =
            _selectedKind == TvMediaKind.movie ? movies : series;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: Row(
                children: <Widget>[
                  _SearchResultTab(
                    label: 'Movies',
                    count: movies.length,
                    icon: PhosphorIcons.filmSlate(),
                    selected: _selectedKind == TvMediaKind.movie,
                    onActivate: () =>
                        setState(() => _selectedKind = TvMediaKind.movie),
                  ),
                  const SizedBox(width: 14),
                  _SearchResultTab(
                    label: 'TV Series',
                    count: series.length,
                    icon: PhosphorIcons.television(),
                    selected: _selectedKind == TvMediaKind.series,
                    onActivate: () =>
                        setState(() => _selectedKind = TvMediaKind.series),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.metrics.compact ? 8 : 14),
            Expanded(
              child: selectedItems.isEmpty
                  ? TvStatePanel(
                      title: _selectedKind == TvMediaKind.movie
                          ? 'No movie matches'
                          : 'No TV series matches',
                      message:
                          'Try another title or choose the other results tab.',
                      icon: _selectedKind == TvMediaKind.movie
                          ? PhosphorIcons.filmSlate()
                          : PhosphorIcons.television(),
                    )
                  : TvContentGrid<TvMediaItem>(
                      scopeId: 'search:$_submittedQuery:${_selectedKind.name}',
                      items: selectedItems,
                      itemId: (item) => item.stableId,
                      semanticLabel: (item) => item.title,
                      targetItemWidth: widget.metrics.mediaCardWidth,
                      autofocus: true,
                      itemBuilder: (_, item, width) =>
                          TvMediaCard(item: item, width: width),
                      onItemActivated: widget.onOpenMedia,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchResultTab extends StatelessWidget {
  const _SearchResultTab({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onActivate,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TvFocusable(
      semanticLabel: '$label, $count results',
      onActivate: onActivate,
      focusScale: 1.02,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.18)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: selected ? colors.primary : colors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                color: colors.onSurface,
                fontFamily: selected ? 'FigtreeSB' : 'Figtree',
                fontSize: 17,
              ),
            ),
            const SizedBox(width: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontFamily: 'FigtreeSB',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
