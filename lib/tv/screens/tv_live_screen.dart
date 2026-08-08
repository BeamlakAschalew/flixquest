import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/live_tv_database_controller.dart';
import '../../functions/function.dart';
import '../../models/live_tv.dart';
import '../../provider/app_dependency_provider.dart';
import '../../screens/common/live_player.dart';
import '../../services/daddylive_service.dart';
import '../app/tv_design.dart';
import '../focus/tv_focusable.dart';
import '../player/tv_player_screen.dart';
import '../widgets/tv_state_panel.dart';

enum _TvLiveScope { all, favorites, recent }

enum _TvLiveMode { channels, schedule }

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
  DaddyLiveEpg? _epg;
  Set<String> _favorites = <String>{};
  List<String> _recent = const <String>[];
  _TvLiveScope _scope = _TvLiveScope.all;
  _TvLiveMode _mode = _TvLiveMode.channels;
  String? _category;
  int _selectedDayIndex = 0;
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
      DaddyLiveEpg? epg;
      if (!refresh && await _database.isCacheValid()) {
        channels = await _database.getCachedChannels();
        epg = await _database.getCachedEpg();
      } else {
        final catalog = await _api().getCatalog(refresh: refresh);
        channels = catalog.channels;
        epg = catalog.epg;
        await _database.cacheChannels(channels);
        await _database.cacheEpg(epg);
      }
      channels = channels.toList()..sort((a, b) => a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _epg = epg;
        _favorites = favorites;
        _recent = recent;
        _loading = false;
      });
    } catch (error) {
      final cached = await _database.getCachedChannels();
      final cachedEpg = await _database.getCachedEpg();
      if (!mounted) return;
      setState(() {
        _channels = cached;
        _epg = cachedEpg;
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
    final tokens = searchTokens(_query);
    if (tokens.isNotEmpty) {
      result = result.where((item) => _matches(item, tokens));
    }
    return result.toList(growable: false);
  }

  static bool _matches(Channel channel, List<String> tokens) {
    // 24/7 channels match by their own identity only (name / id), never by
    // the event that happens to be airing. Use the Schedule search for teams.
    final haystack = normalizeSearchText('${channel.name} ${channel.id}');
    return tokens.every(haystack.contains);
  }

  static bool _eventMatches(
    DaddyLiveEpgEvent event,
    String categoryName,
    List<String> tokens,
  ) {
    final haystack = normalizeSearchText(
      '$categoryName ${event.title} '
      '${event.channels.map((channel) => channel.name).join(' ')}',
    );
    return tokens.every(haystack.contains);
  }

  List<({String name, List<DaddyLiveEpgEvent> events})> get _scheduleSections {
    final epg = _epg;
    if (epg == null || epg.days.isEmpty) return const [];
    final day = epg.days[_selectedDayIndex.clamp(0, epg.days.length - 1)];
    final tokens = searchTokens(_query);
    return <({String name, List<DaddyLiveEpgEvent> events})>[
      for (final category in day.categories)
        (
          name: category.name,
          events: category.events
              .where(
                (event) =>
                    tokens.isEmpty ||
                    _eventMatches(event, category.name, tokens),
              )
              .toList(growable: false),
        ),
    ]..removeWhere((section) => section.events.isEmpty);
  }

  int get _visibleEventCount => _scheduleSections
      .fold(0, (sum, section) => sum + section.events.length);

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
              channels: _visible,
              initialChannelId: channel.id,
              service: _api(),
              onChannelSwitch: (switched) => _database.addRecent(switched.id),
            ),
          ),
        ),
      );
      _recent = await _database.getRecentIds();
      if (mounted) setState(() {});
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
    final isSchedule = _mode == _TvLiveMode.schedule;
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
            _buildTitle(isSchedule),
            SizedBox(height: widget.metrics.compact ? 12 : 18),
            _buildControls(isSchedule),
            if (!isSchedule && _categories.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _buildCategories(),
            ],
            if (isSchedule &&
                _epg != null &&
                _epg!.days.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _buildDays(),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: isSchedule ? _buildSchedule() : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(bool isSchedule) {
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
            isSchedule ? PhosphorIcons.calendarDots() : PhosphorIcons.broadcast(),
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
                isSchedule ? 'Schedule' : 'Live TV',
                style: TextStyle(
                  color: colors.onSurface,
                  fontFamily: 'FigtreeSB',
                  fontSize: 34,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isSchedule
                    ? '$_visibleEventCount events • Select a match to watch'
                    : '${_visible.length} channels • Select a channel to watch',
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

  Widget _buildControls(bool isSchedule) {
    return Row(
      children: <Widget>[
        for (final entry in <(_TvLiveMode, String, IconData)>[
          (_TvLiveMode.channels, 'Channels', PhosphorIcons.televisionSimple()),
          (_TvLiveMode.schedule, 'Schedule', PhosphorIcons.calendarDots()),
        ]) ...<Widget>[
          TvFocusable(
            semanticLabel: '${entry.$2} view',
            selected: _mode == entry.$1,
            onActivate: () => setState(() => _mode = entry.$1),
            focusScale: 1.025,
            child: _TvPill(
              icon: entry.$3,
              label: entry.$2,
              selected: _mode == entry.$1,
            ),
          ),
          const SizedBox(width: 8),
        ],
        const SizedBox(width: 6),
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
              hintText: isSchedule
                  ? 'Search matches, teams & leagues'
                  : 'Search channels',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              filled: true,
              border: InputBorder.none,
            ),
          ),
        ),
        if (!isSchedule) ...<Widget>[
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

  Widget _buildDays() {
    final days = _epg!.days;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          for (var i = 0; i < days.length; i++) ...<Widget>[
            if (i != 0) const SizedBox(width: 8),
            TvFocusable(
              semanticLabel: '${_prettyDayLabel(days[i].label)} schedule',
              selected: _selectedDayIndex == i,
              onActivate: () => setState(() => _selectedDayIndex = i),
              focusScale: 1.025,
              child: _TvPill(
                label: _prettyDayLabel(days[i].label),
                selected: _selectedDayIndex == i,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _prettyDayLabel(String label) {
    final parsed = DateTime.tryParse(label);
    if (parsed == null) return label;
    return DateFormat('EEE, MMM d').format(parsed);
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

  Widget _buildSchedule() {
    final sections = _scheduleSections;
    if (sections.isEmpty) {
      return TvStatePanel(
        title: _epg?.days.isNotEmpty ?? false
            ? 'No matches found'
            : 'Schedule unavailable',
        message: _epg?.days.isNotEmpty ?? false
            ? 'Try another team, league, or day.'
            : "Refresh to load today's schedule.",
        icon: PhosphorIcons.calendarDots(),
        actionLabel: (_epg?.days.isNotEmpty ?? false) ? null : 'Refresh',
        onAction: (_epg?.days.isNotEmpty ?? false) ? null : () => _load(refresh: true),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(3, 3, 12, 30),
      itemCount: sections.length,
      itemBuilder: (_, sectionIndex) {
        final section = sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      section.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'FigtreeSB',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Text(
                    '${section.events.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            for (final event in section.events) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TvScheduleEventTile(
                  event: event,
                  resolvingChannelId: _resolvingId,
                  onPlay: _play,
                ),
              ),
            ],
          ],
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

class _TvScheduleEventTile extends StatelessWidget {
  const _TvScheduleEventTile({
    required this.event,
    required this.resolvingChannelId,
    required this.onPlay,
  });

  final DaddyLiveEpgEvent event;
  final String? resolvingChannelId;
  final void Function(Channel channel) onPlay;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                event.time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.primary,
                  fontFamily: 'FigtreeSB',
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'FigtreeSB',
                      fontSize: 20,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (final channel in event.channels)
                        TvFocusable(
                          semanticLabel: 'Watch on ${channel.name}',
                          enabled: resolvingChannelId != channel.id,
                          onActivate: () => onPlay(channel),
                          focusScale: 1.025,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (resolvingChannelId == channel.id)
                                  SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  )
                                else
                                  Icon(
                                    PhosphorIcons.broadcast(
                                      PhosphorIconsStyle.fill,
                                    ),
                                    size: 16,
                                    color: colors.primary,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  channel.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontFamily: 'FigtreeSB',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  bool get _isLive => channel.nowPlaying != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = channel.nowPlaying ??
        channel.nextUp ??
        (channel.categories.isEmpty
            ? 'Channel ${channel.id}'
            : channel.categories.first);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TvDesign.surfaceFor(context, emphasis: 0.04),
        borderRadius: BorderRadius.circular(TvDesign.cardRadius),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _TvChannelAvatar(name: channel.name, letter: channel.letter),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'FigtreeSB',
                      fontSize: 18,
                    ),
                  ),
                ),
                if (_isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: colors.error,
                            fontFamily: 'FigtreeSB',
                            fontSize: 11,
                            letterSpacing: .6,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: <Widget>[
                  Icon(
                    _isLive
                        ? PhosphorIcons.broadcast(PhosphorIconsStyle.fill)
                        : channel.nextUp != null
                            ? PhosphorIcons.clockCounterClockwise()
                            : PhosphorIcons.radio(),
                    size: 16,
                    color: _isLive
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isLive ? colors.primary : colors.onSurfaceVariant,
                        fontFamily: _isLive ? 'FigtreeSB' : 'Figtree',
                        fontSize: 15,
                      ),
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

class _TvChannelAvatar extends StatelessWidget {
  const _TvChannelAvatar({required this.name, this.letter});

  final String name;
  final String? letter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = (letter ?? (name.isEmpty ? '?' : name.trim()))
        .characters
        .first
        .toUpperCase();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colors.primary.withValues(alpha: .85),
            colors.primary.withValues(alpha: .45),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: colors.onPrimary,
          fontFamily: 'FigtreeSB',
          fontSize: 17,
          height: 1,
        ),
      ),
    );
  }
}
