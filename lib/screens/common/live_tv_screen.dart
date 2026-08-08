import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/live_tv_database_controller.dart';
import '../../models/live_tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '../../services/daddylive_service.dart';
import '../../ui_components/app_ui_components.dart';
import 'live_player.dart';

enum _ChannelScope { all, favorites, recent }

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final _database = LiveTVDatabaseController();
  final _searchController = TextEditingController();
  DaddyLiveService? _service;
  List<Channel> _channels = const <Channel>[];
  Set<String> _favoriteIds = <String>{};
  List<String> _recentIds = const <String>[];
  String? _selectedCategory;
  String? _resolvingId;
  String _query = '';
  String? _error;
  bool _loading = true;
  _ChannelScope _scope = _ChannelScope.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _service?.close();
    _searchController.dispose();
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
        final catalog = await _api().getCatalog(refresh: refresh);
        channels = catalog.channels;
        await _database.cacheChannels(channels);
      }
      channels = channels.toList()..sort((a, b) => a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _favoriteIds = favorites;
        _recentIds = recent;
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
    final values = _channels.expand((channel) => channel.categories).toSet();
    return values.toList()..sort();
  }

  List<Channel> get _visibleChannels {
    Iterable<Channel> result = _channels;
    if (_scope == _ChannelScope.favorites) {
      result = result.where((channel) => _favoriteIds.contains(channel.id));
    } else if (_scope == _ChannelScope.recent) {
      final byId = <String, Channel>{for (final item in result) item.id: item};
      result = _recentIds.map((id) => byId[id]).whereType<Channel>();
    }
    if (_selectedCategory != null) {
      result = result.where(
        (channel) => channel.categories.contains(_selectedCategory),
      );
    }
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (channel) =>
            channel.name.toLowerCase().contains(query) ||
            channel.id.contains(query),
      );
    }
    return result.toList(growable: false);
  }

  Future<void> _toggleFavorite(Channel channel) async {
    final isFavorite = await _database.toggleFavorite(channel.id);
    if (!mounted) return;
    setState(() {
      if (isFavorite) {
        _favoriteIds.add(channel.id);
      } else {
        _favoriteIds.remove(channel.id);
      }
    });
  }

  Future<void> _play(Channel channel) async {
    setState(() => _resolvingId = channel.id);
    try {
      final stream = await _api().getStream(channel.id);
      await _database.addRecent(channel.id);
      _recentIds = await _database.getRecentIds();
      if (!mounted) return;
      context.read<SettingsProvider>().analytics.trackLiveTVChannelView(
            channelName: channel.name,
            streamId: channel.id,
          );
      final autoFullScreen = context.read<SettingsProvider>().defaultViewMode;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LivePlayer(
            channelName: channel.name,
            videoUrl: stream.url,
            headers: stream.headers,
            autoFullScreen: autoFullScreen,
            colors: <Color>[
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
            ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live TV'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh channels and schedule',
            onPressed: _loading ? null : () => _load(refresh: true),
            icon: Icon(PhosphorIcons.arrowsClockwise()),
          ),
        ],
      ),
      body: AppResponsiveContent(
        maxWidth: 1100,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AppEmptyState(
        icon: PhosphorIcons.broadcast(),
        title: 'Live TV is unavailable',
        message: _error!,
        action: FilledButton.icon(
          onPressed: _load,
          icon: Icon(PhosphorIcons.arrowsClockwise()),
          label: const Text('Retry'),
        ),
      );
    }
    final visible = _visibleChannels;
    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildHeader()),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: PhosphorIcons.televisionSimple(),
                title: 'No channels found',
                message: 'Try another search, category, or collection.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              sliver: SliverGrid.builder(
                itemCount: visible.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisExtent: 112,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, index) => _ChannelCard(
                  channel: visible[index],
                  favorite: _favoriteIds.contains(visible[index].id),
                  resolving: _resolvingId == visible[index].id,
                  onFavorite: () => _toggleFavorite(visible[index]),
                  onPlay: () => _play(visible[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search channels',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: Icon(PhosphorIcons.x()),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<_ChannelScope>(
            showSelectedIcon: false,
            segments: <ButtonSegment<_ChannelScope>>[
              ButtonSegment(
                value: _ChannelScope.all,
                icon: Icon(PhosphorIcons.broadcast()),
                label: const Text('All'),
              ),
              ButtonSegment(
                value: _ChannelScope.favorites,
                icon: Icon(PhosphorIcons.heart()),
                label: const Text('Favorites'),
              ),
              ButtonSegment(
                value: _ChannelScope.recent,
                icon: Icon(PhosphorIcons.clockCounterClockwise()),
                label: const Text('Recent'),
              ),
            ],
            selected: <_ChannelScope>{_scope},
            onSelectionChanged: (value) => setState(() => _scope = value.first),
          ),
          if (_categories.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All categories'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  for (final category in _categories) ...<Widget>[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                  ],
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              '${_visibleChannels.length} channels',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.favorite,
    required this.resolving,
    required this.onFavorite,
    required this.onPlay,
  });

  final Channel channel;
  final bool favorite;
  final bool resolving;
  final VoidCallback onFavorite;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: resolving ? null : onPlay,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colors.primaryContainer,
                      colors.primary.withValues(alpha: 0.45),
                    ],
                  ),
                ),
                child: Text(
                  (channel.letter?.isNotEmpty ?? false)
                      ? channel.letter!.toUpperCase()
                      : channel.name.substring(0, 1).toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      channel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.categories.isEmpty
                          ? 'Channel ${channel.id}'
                          : channel.categories.take(2).join(' â¢ '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: onFavorite,
                icon: Icon(
                  favorite
                      ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                      : PhosphorIcons.heart(),
                  color: favorite ? colors.primary : null,
                ),
              ),
              if (resolving)
                const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                Icon(PhosphorIcons.playCircle(), size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
