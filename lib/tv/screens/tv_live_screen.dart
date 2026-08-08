import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/live_tv_database_controller.dart';
import '../../models/live_tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../screens/common/live_player.dart';
import '../../services/daddylive_service.dart';
import '../app/tv_design.dart';
import '../focus/tv_focusable.dart';
import '../player/tv_player_screen.dart';
import '../widgets/tv_state_panel.dart';

enum _TvLiveScope { all, favorites, recent }

class TvLiveScreen extends StatefulWidget {
  const TvLiveScreen({required this.metrics, super.key});

  final TvShellMetrics metrics;

  @override
  State<TvLiveScreen> createState() => _TvLiveScreenState();
}

class _TvLiveScreenState extends State<TvLiveScreen> {
  final _database = LiveTVDatabaseController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode(debugLabel: 'Live TV search');
  DaddyLiveService? _service;
  List<Channel> _channels = const <Channel>[];
  Set<String> _favorites = <String>{};
  List<String> _recent = const <String>[];
  _TvLiveScope _scope = _TvLiveScope.all;
  String? _category;
  String? _resolvingId;
  String _query = '';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _service?.close();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  DaddyLiveService _api() => _service ??= DaddyLiveService(
        baseUrl: context.read<AppDependencyProvider>().flixquestAPIURL,
      );

  Future<void> _load({bool refresh = false}) async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final favorites = await _database.getFavoriteIds();
      final recent = await _database.getRecentIds();
      List<Channel> channels;
      if (!refresh && await _database.isCacheValid()) {
        channels = await _database.getCachedChannels();
      } else {
        channels = (await _api().getCatalog(refresh: refresh)).channels;
        await _database.cacheChannels(channels);
      }
      channels = channels.toList()..sort((a, b) => a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _favorites = favorites;
        _recent = recent;
        _loading = false;
      });
    } catch (error) {
      final cached = await _database.getCachedChannels();
      if (!mounted) return;
      setState(() {
        _channels = cached;
        _loading = false;
        _error = cached.isEmpty ? error.toString() : null;
      });
    }
  }

  List<String> get _categories {
    final categories = _channels.expand((item) => item.categories).toSet();
    return categories.toList()..sort();
  }

  List<Channel> get _visible {
    Iterable<Channel> result = _channels;
    if (_scope == _TvLiveScope.favorites) {
      result = result.where((item) => _favorites.contains(item.id));
    } else if (_scope == _TvLiveScope.recent) {
      final byId = <String, Channel>{for (final item in result) item.id: item};
      result = _recent.map((id) => byId[id]).whereType<Channel>();
    }
    if (_category != null) {
      result = result.where((item) => item.categories.contains(_category));
    }
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (item) =>
            item.name.toLowerCase().contains(query) || item.id.contains(query),
      );
    }
    return result.toList(growable: false);
  }

  Future<void> _toggleFavorite(Channel channel) async {
    final value = await _database.toggleFavorite(channel.id);
    if (!mounted) return;
    setState(() {
      if (value) {
        _favorites.add(channel.id);
      } else {
        _favorites.remove(channel.id);
      }
    });
  }

  Future<void> _play(Channel channel) async {
    setState(() => _resolvingId = channel.id);
    try {
      final stream = await _api().getStream(channel.id);
      await _database.addRecent(channel.id);
      _recent = await _database.getRecentIds();
      if (!mounted) return;
      final theme = Theme.of(context);
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => TvPlayerScreen(
            child: LivePlayer(
              channelName: channel.name,
              videoUrl: stream.url,
              headers: stream.headers,
              autoFullScreen: false,
              colors: <Color>[
                theme.colorScheme.primary,
                Colors.black,
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _resolvingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) return _buildError();
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          widget.metrics.contentPadding,
          0,
          widget.metrics.contentPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitle(),
            SizedBox(height: widget.metrics.compact ? 12 : 18),
            _buildControls(),
            if (_categories.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _buildCategories(),
            ],
            const SizedBox(height: 16),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            PhosphorIcons.broadcast(),
            color: colors.primary,
            size: 27,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Live TV',
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 34,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${_visible.length} channels • Select a channel to watch',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        TvFocusable(
          semanticLabel: 'Refresh live TV',
          onActivate: () => _load(refresh: true),
          focusScale: 1.025,
          child: _TvPill(
            icon: PhosphorIcons.arrowsClockwise(),
            label: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            onChanged: (value) => setState(() => _query = value),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              hintText: 'Search channels',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              filled: true,
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(width: 14),
        for (final entry in <(_TvLiveScope, String, IconData)>[
          (_TvLiveScope.all, 'All', PhosphorIcons.broadcast()),
          (_TvLiveScope.favorites, 'Favorites', PhosphorIcons.heart()),
          (
            _TvLiveScope.recent,
            'Recent',
            PhosphorIcons.clockCounterClockwise()
          ),
        ]) ...<Widget>[
          TvFocusable(
            semanticLabel: '${entry.$2} channels',
            selected: _scope == entry.$1,
            onActivate: () => setState(() => _scope = entry.$1),
            focusScale: 1.025,
            child: _TvPill(
              icon: entry.$3,
              label: entry.$2,
              selected: _scope == entry.$1,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          TvFocusable(
            semanticLabel: 'All categories',
            selected: _category == null,
            onActivate: () => setState(() => _category = null),
            focusScale: 1.025,
            child:
                _TvPill(label: 'All categories', selected: _category == null),
          ),
          for (final category in _categories) ...<Widget>[
            const SizedBox(width: 8),
            TvFocusable(
              semanticLabel: '$category category',
              selected: _category == category,
              onActivate: () => setState(() => _category = category),
              focusScale: 1.025,
              child: _TvPill(
                label: category,
                selected: _category == category,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final channels = _visible;
    if (channels.isEmpty) {
      return TvStatePanel(
        title: 'No channels found',
        message: 'Try another search, category, or collection.',
        icon: PhosphorIcons.televisionSimple(),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(3, 3, 12, 30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.metrics.compact ? 3 : 4,
        childAspectRatio: widget.metrics.compact ? 1.8 : 1.65,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: channels.length,
      itemBuilder: (_, index) {
        final channel = channels[index];
        return _TvChannelCard(
          channel: channel,
          favorite: _favorites.contains(channel.id),
          resolving: _resolvingId == channel.id,
          onPlay: () => _play(channel),
          onFavorite: () => _toggleFavorite(channel),
        );
      },
    );
  }

  Widget _buildError() {
    return TvStatePanel.error(
      onRetry: _load,
      message: _error ?? 'Live TV is currently unavailable.',
    );
  }
}

class _TvPill extends StatelessWidget {
  const _TvPill({required this.label, this.icon, this.selected = false});

  final String label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected
            ? colors.primary.withValues(alpha: 0.18)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: colors.primary.withValues(alpha: 0.4))
            : Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(
              icon,
              size: 22,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface,
              fontFamily: selected ? 'FigtreeSB' : 'Figtree',
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _TvChannelCard extends StatelessWidget {
  const _TvChannelCard({
    required this.channel,
    required this.favorite,
    required this.resolving,
    required this.onPlay,
    required this.onFavorite,
  });

  final Channel channel;
  final bool favorite;
  final bool resolving;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TvDesign.surfaceFor(context, emphasis: 0.04),
        borderRadius: BorderRadius.circular(TvDesign.cardRadius),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                    ),
                    child: Text(
                      (channel.letter?.isNotEmpty ?? false)
                          ? channel.letter!.toUpperCase()
                          : channel.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          channel.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'FigtreeSB',
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          channel.categories.isEmpty
                              ? 'Channel ${channel.id}'
                              : channel.categories.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: TvFocusable(
                    semanticLabel: 'Play ${channel.name}',
                    enabled: !resolving,
                    onActivate: onPlay,
                    child: _TvPill(
                      icon: PhosphorIcons.play(),
                      label: resolving ? 'Loading' : 'Watch',
                      selected: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TvFocusable(
                  semanticLabel: favorite
                      ? 'Remove ${channel.name} from favorites'
                      : 'Add ${channel.name} to favorites',
                  onActivate: onFavorite,
                  child: _TvPill(
                    icon: favorite
                        ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                        : PhosphorIcons.heart(),
                    label: '',
                    selected: favorite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
