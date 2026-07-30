import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../app/tv_design.dart';
import '../controllers/tv_catalog_controller.dart';
import '../models/tv_media_item.dart';
import '../widgets/tv_content_grid.dart';
import '../widgets/tv_media_card.dart';
import '../widgets/tv_state_panel.dart';

class TvCatalogScreen extends StatefulWidget {
  const TvCatalogScreen({
    required this.kind,
    required this.metrics,
    required this.onOpenMedia,
    super.key,
  });

  final TvMediaKind kind;
  final TvShellMetrics metrics;
  final ValueChanged<TvMediaItem> onOpenMedia;

  @override
  State<TvCatalogScreen> createState() => _TvCatalogScreenState();
}

class _TvCatalogScreenState extends State<TvCatalogScreen> {
  static const _controller = TvCatalogController();
  Future<List<TvMediaItem>>? _items;
  String? _configurationKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    final dependencies = context.watch<AppDependencyProvider>();
    final key = '${widget.kind.name}|${settings.appLanguage}|'
        '${settings.enableProxy}|${dependencies.tmdbProxy}';
    if (_configurationKey != key) {
      _configurationKey = key;
      _items = _load(settings, dependencies);
    }
  }

  Future<List<TvMediaItem>> _load(
    SettingsProvider settings,
    AppDependencyProvider dependencies,
  ) {
    return widget.kind == TvMediaKind.movie
        ? _controller.loadMovies(settings: settings, dependencies: dependencies)
        : _controller.loadSeries(
            settings: settings, dependencies: dependencies);
  }

  void _retry() {
    setState(() {
      _items = _load(
        context.read<SettingsProvider>(),
        context.read<AppDependencyProvider>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.kind == TvMediaKind.movie ? 'Movies' : 'Series';
    final icon = widget.kind == TvMediaKind.movie
        ? PhosphorIcons.filmSlate()
        : PhosphorIcons.television();
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
          _CatalogHeader(title: title, icon: icon),
          SizedBox(height: widget.metrics.compact ? 10 : 18),
          Expanded(
            child: FutureBuilder<List<TvMediaItem>>(
              future: _items,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return TvStatePanel.error(onRetry: _retry);
                }
                final items = snapshot.data ?? const <TvMediaItem>[];
                if (items.isEmpty) {
                  return TvStatePanel(
                    title: 'No $title available',
                    message: 'Try again in a moment.',
                    icon: icon,
                    actionLabel: 'Retry',
                    onAction: _retry,
                  );
                }
                return TvContentGrid<TvMediaItem>(
                  scopeId: 'catalog-${widget.kind.name}',
                  items: items,
                  itemId: (item) => item.stableId,
                  semanticLabel: (item) => item.title,
                  targetItemWidth: widget.metrics.mediaCardWidth,
                  itemBuilder: (_, item, width) =>
                      TvMediaCard(item: item, width: width),
                  onItemActivated: widget.onOpenMedia,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, color: colors.primary, size: 32),
        const SizedBox(width: 13),
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: 'FigtreeSB',
            fontSize: 34,
          ),
        ),
      ],
    );
  }
}
