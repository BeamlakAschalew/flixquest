import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flixquest/api/endpoints.dart';
import 'package:flixquest/controllers/live_tv_database_controller.dart';
import 'package:flixquest/screens/common/live_player.dart';
import 'package:flixquest/services/globle_method.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../provider/app_dependency_provider.dart';
import '/models/live_tv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../functions/network.dart';
import '../../provider/settings_provider.dart';
import '../../ui_components/app_ui_components.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  List<Channel> channels = [];
  List<Channel> filteredChannels = [];
  bool isLoading = true;
  bool enableRetry = false;
  bool isSearching = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final LiveTVDatabaseController _dbController = LiveTVDatabaseController();
  final ScrollController _scrollController = ScrollController();
  DateTime? lastCacheUpdate;
  int totalChannels = 0;

  @override
  void initState() {
    super.initState();
    _loadChannelsWithCache();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChannelsWithCache() async {
    setState(() {
      isLoading = true;
      enableRetry = false;
    });

    try {
      // Check if cache exists and is valid (24 hours)
      final isCacheValid = await _dbController.isCacheValid(maxAgeHours: 24);
      final cacheMetadata = await _dbController.getCacheMetadata();

      if (isCacheValid && cacheMetadata != null) {
        // Load from cache
        final cachedChannels = await _dbController.getCachedChannels();
        setState(() {
          channels = cachedChannels;
          filteredChannels = cachedChannels;
          isLoading = false;
          lastCacheUpdate = DateTime.fromMillisecondsSinceEpoch(
            cacheMetadata['last_updated'],
          );
          totalChannels = cachedChannels.length;
        });
      } else {
        // Fetch from API
        await _fetchChannelsFromAPI();
      }
    } catch (e) {
      setState(() {
        enableRetry = true;
        isLoading = false;
      });
      if (mounted) {
        if (e is Exception) {
          GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, '');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              'Error loading channels: ${e.toString()}',
              style: TextStyle(fontFamily: 'Figtree'),
            )),
          );
        }
      }
    }
  }

  Future<void> _fetchChannelsFromAPI() async {
    setState(() {
      isLoading = true;
      enableRetry = false;
    });

    try {
      final Channels fetchedData = await fetchChannels(
        Endpoints.getIPTVEndpoint(
          Provider.of<AppDependencyProvider>(context, listen: false)
              .flixquestAPIURL,
        ),
      );

      if (fetchedData.channels != null && fetchedData.channels!.isNotEmpty) {
        // Cache the channels
        await _dbController.cacheChannels(fetchedData.channels!);

        setState(() {
          channels = fetchedData.channels!;
          filteredChannels = fetchedData.channels!;
          isLoading = false;
          lastCacheUpdate = DateTime.now();
          totalChannels = fetchedData.channels!.length;
        });
      }
    } catch (e) {
      setState(() {
        enableRetry = true;
        isLoading = false;
      });
      if (mounted) {
        if (e is Exception) {
          GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, '');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              'Error fetching channels: ${e.toString()}',
              style: TextStyle(fontFamily: 'Figtree'),
            )),
          );
        }
      }
    }
  }

  Future<void> _clearCacheAndRefresh() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('clear_cache')),
        content: Text(tr('clear_cache_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbController.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            tr('cache_cleared'),
            style: TextStyle(fontFamily: 'Figtree'),
          )),
        );
      }
      await _fetchChannelsFromAPI();
    }
  }

  void _performSearch(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredChannels = channels;
        isSearching = false;
      } else {
        isSearching = true;
        filteredChannels = channels
            .where((channel) =>
                channel.name?.toLowerCase().contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
      filteredChannels = channels;
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('channels')),
        actions: [
          if (!isLoading && channels.isNotEmpty)
            IconButton(
              icon: Icon(PhosphorIcons.arrowsClockwise()),
              tooltip: tr('refresh'),
              onPressed: _clearCacheAndRefresh,
            ),
        ],
      ),
      body: AppResponsiveContent(
        maxWidth: 840,
        child: enableRetry
            ? _buildRetryWidget()
            : isLoading
                ? _buildLoadingWidget()
                : channels.isEmpty
                    ? _buildEmptyWidget()
                    : _buildChannelList(),
      ),
    );
  }

  Widget _buildRetryWidget() {
    return AppEmptyState(
      icon: PhosphorIcons.linkBreak(),
      title: tr('channels_fetch_failed'),
      message: tr('check_connection'),
      action: FilledButton.icon(
        icon: Icon(PhosphorIcons.arrowsClockwise()),
        label: Text(tr('retry')),
        onPressed: _loadChannelsWithCache,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return AppEmptyState(
      icon: PhosphorIcons.television(),
      title: tr('channels'),
      message: tr('loading_video_sources'),
      action: const CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyWidget() {
    return AppEmptyState(
      icon: PhosphorIcons.televisionSimple(),
      title: tr('channels'),
      message: tr('no_channels'),
    );
  }

  Widget _buildChannelList() {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: tr('search'),
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            suffixIcon: isSearching
                ? IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
        ),
        if (lastCacheUpdate != null || isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSearching
                        ? '${tr('showing')} ${filteredChannels.length} ${tr('results')}'
                        : '${tr('total_channels')}: $totalChannels',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (lastCacheUpdate != null)
                  Text(
                    _formatCacheTime(lastCacheUpdate!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: filteredChannels.isEmpty
              ? AppEmptyState(
                  icon: PhosphorIcons.magnifyingGlass(),
                  title: tr('search'),
                  message: tr('no_channels_found'),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredChannels.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChannelWidget(
                      channel: filteredChannels[index],
                      key: ValueKey(filteredChannels[index].streamId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatCacheTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return tr('just_now');
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${tr('minutes_ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${tr('hours_ago')}';
    } else {
      return DateFormat('MMM d, y h:mm a').format(time);
    }
  }
}

class ChannelWidget extends StatelessWidget {
  const ChannelWidget({super.key, required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final mixpanel =
              Provider.of<SettingsProvider>(context, listen: false).mixpanel;
          final autoFS = Provider.of<SettingsProvider>(context, listen: false)
              .defaultViewMode;

          mixpanel.track('Most viewed TV channels', properties: {
            'TV Channel name': channel.name ?? 'N/A',
            'Stream ID': channel.streamId ?? 'N/A',
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LivePlayer(
                channelName: channel.name ?? 'Unknown Channel',
                videoUrl: channel.directSource ?? channel.videoUrl ?? '',
                autoFullScreen: autoFS,
                streamIcon: channel.streamIcon,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Channel icon
              if (channel.streamIcon != null && channel.streamIcon!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: channel.streamIcon!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: 48,
                      height: 48,
                      color: Theme.of(context).cardColor,
                      child: Icon(PhosphorIcons.television(), size: 24),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 48,
                      height: 48,
                      color: Theme.of(context).cardColor,
                      child: Icon(PhosphorIcons.television(), size: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(PhosphorIcons.television(), size: 24),
                ),

              const SizedBox(width: 12),

              // Channel name
              Expanded(
                child: Text(
                  channel.name ?? 'Unknown Channel',
                  style: const TextStyle(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Icon(PhosphorIcons.playCircle(), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
