import 'dart:async';

import 'package:better_player_plus/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../functions/function.dart';
import '../../models/live_tv.dart';
import '../../services/daddylive_service.dart';

class LivePlayer extends StatefulWidget {
  const LivePlayer({
    required this.videoUrl,
    required this.colors,
    required this.autoFullScreen,
    required this.channelName,
    this.headers = const <String, String>{},
    this.streamIcon,
    this.channels = const <Channel>[],
    this.initialChannelId,
    this.service,
    this.onChannelSwitch,
    super.key,
  });

  final String videoUrl;
  final List<Color> colors;
  final bool autoFullScreen;
  final String channelName;
  final Map<String, String> headers;
  final String? streamIcon;

  /// Channels available for in-player switching. When empty, the channel
  /// switcher is hidden.
  final List<Channel> channels;
  final String? initialChannelId;
  final DaddyLiveService? service;
  final void Function(Channel channel)? onChannelSwitch;

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends State<LivePlayer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerControlsConfiguration betterPlayerControlsConfiguration;
  late BetterPlayerBufferingConfiguration betterPlayerBufferingConfiguration;

  final GlobalKey _betterPlayerKey = GlobalKey();

  String? _currentChannelId;
  bool _isSwitching = false;
  String? _bannerText;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _currentChannelId =
        widget.initialChannelId ?? widget.channels.firstOrNull?.id;

    betterPlayerBufferingConfiguration =
        const BetterPlayerBufferingConfiguration(
      // Keep memory usage predictable on low-memory Android TV hardware.
      maxBufferMs: 120000,
      minBufferMs: 15000,
      bufferForPlaybackMs: 2500,
      bufferForPlaybackAfterRebufferMs: 5000,
    );

    betterPlayerControlsConfiguration = BetterPlayerControlsConfiguration(
      name: widget.channelName,
      enableFullscreen: true,
      enableSubtitles: false,
      enablePip: true,
      backgroundColor: widget.colors.elementAt(1).withValues(alpha: 0.6),
      controlBarColor: Colors.black.withValues(alpha: 0.3),
      progressBarBackgroundColor: Colors.white,
      muteIcon: PhosphorIcons.speakerSimpleSlash(),
      unMuteIcon: PhosphorIcons.speakerHigh(),
      pauseIcon: PhosphorIcons.pause(),
      pipMenuIcon: PhosphorIcons.appWindow(),
      playIcon: PhosphorIcons.play(),
      showControlsOnInitialize: false,
      loadingColor: widget.colors.first,
      iconsColor: widget.colors.first,
      progressBarPlayedColor: widget.colors.first,
      progressBarBufferedColor: Colors.black45,
      skipForwardIcon: PhosphorIcons.arrowsClockwise(),
      skipBackIcon: PhosphorIcons.arrowsCounterClockwise(),
      fullscreenEnableIcon: PhosphorIcons.cornersOut(),
      fullscreenDisableIcon: PhosphorIcons.cornersIn(),
      overflowMenuIcon: PhosphorIcons.list(),
      subtitlesIcon: PhosphorIcons.closedCaptioning(),
      qualitiesIcon: PhosphorIcons.highDefinition(),
      overflowMenuIconsColor: widget.colors.first,
      overflowModalTextColor: widget.colors.first,
      overflowModalColor: widget.colors.last,
      enableAudioTracks: false,
      overflowMenuCustomItems: canSwitchChannels
          ? <BetterPlayerOverflowMenuItem>[
              BetterPlayerOverflowMenuItem(
                PhosphorIcons.televisionSimple(),
                'Channels',
                _showChannelSwitcher,
              ),
            ]
          : const <BetterPlayerOverflowMenuItem>[],
    );

    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      autoDetectFullscreenDeviceOrientation: true,
      looping: true,
      autoPlay: true,
      allowedScreenSleep: false,
      fit: BoxFit.contain,
      autoDispose: true,
      controlsConfiguration: betterPlayerControlsConfiguration,
      showPlaceholderUntilPlay: true,
      subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
        backgroundColor: Colors.black45,
        fontFamily: 'Figtree',
        fontColor: Colors.white,
        outlineEnabled: false,
        fontSize: 17,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController
        .setupDataSource(_buildDataSource(widget.videoUrl, widget.headers))
        .then((value) {
      if (_betterPlayerController.videoPlayerController!.value.aspectRatio >
          1.0) {
        if (widget.autoFullScreen) {
          _betterPlayerController.enterFullScreen();
        }
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stream: ${error.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _retryStream();
              },
            ),
          ),
        );
      }
    });
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
  }

  bool get canSwitchChannels =>
      widget.service != null &&
      widget.channels.isNotEmpty &&
      widget.channels.length > 1;

  BetterPlayerDataSource _buildDataSource(
    String url,
    Map<String, String> headers,
  ) {
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      liveStream: true,
      bufferingConfiguration: betterPlayerBufferingConfiguration,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Connection': 'keep-alive',
        ...headers,
      },
      videoFormat: BetterPlayerVideoFormat.hls,
    );
  }

  void _retryStream() {
    _betterPlayerController.retryDataSource();
  }

  Future<void> _showChannelSwitcher() async {
    final selected = await showModalBottomSheet<Channel>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ChannelSwitcherSheet(
        channels: widget.channels,
        currentChannelId: _currentChannelId,
      ),
    );
    if (selected != null) await _switchChannel(selected);
  }

  Future<void> _switchChannel(Channel channel) async {
    final service = widget.service;
    if (_isSwitching || service == null || channel.id == _currentChannelId) {
      return;
    }
    setState(() => _isSwitching = true);
    _showBanner('Switching to ${channel.name}…');
    try {
      final stream = await service.getStream(channel.id);
      if (!mounted) return;
      await _betterPlayerController.pause();
      await _betterPlayerController
          .setupDataSource(_buildDataSource(stream.url, stream.headers));
      await _betterPlayerController.play();
      if (!mounted) return;
      setState(() {
        _currentChannelId = channel.id;
        _isSwitching = false;
      });
      widget.onChannelSwitch?.call(channel);
      _showBanner(channel.name);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSwitching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to switch channel: ${error.toString()}')),
      );
    }
  }

  void _showBanner(String text) {
    _bannerTimer?.cancel();
    setState(() => _bannerText = text);
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bannerText = null);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _betterPlayerController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: BetterPlayer(
                  key: _betterPlayerKey,
                  controller: _betterPlayerController,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedSlide(
                      offset: _bannerText == null
                          ? const Offset(0, -2)
                          : Offset.zero,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _bannerText == null ? 0 : 1,
                        duration: const Duration(milliseconds: 240),
                        child: Material(
                          color: Colors.black.withValues(alpha: .78),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (_isSwitching)
                                  const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Icon(
                                    PhosphorIcons.broadcast(
                                      PhosphorIconsStyle.fill,
                                    ),
                                    size: 18,
                                    color: widget.colors.first,
                                  ),
                                const SizedBox(width: 9),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width *
                                        .62,
                                  ),
                                  child: Text(
                                    _bannerText ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'FigtreeSB',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelSwitcherSheet extends StatefulWidget {
  const _ChannelSwitcherSheet({
    required this.channels,
    required this.currentChannelId,
  });

  final List<Channel> channels;
  final String? currentChannelId;

  @override
  State<_ChannelSwitcherSheet> createState() => _ChannelSwitcherSheetState();
}

class _ChannelSwitcherSheetState extends State<_ChannelSwitcherSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = searchTokens(_query);
    final filtered = tokens.isEmpty
        ? widget.channels
        : widget.channels
            .where(
              (channel) => normalizeSearchText(
                '${channel.name} ${channel.id}',
              ).contains(tokens.join(' ')),
            )
            .toList(growable: false);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIcons.televisionSimple(),
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Channels',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.channels.length} channels • tap to switch',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchController,
              autofocus: true,
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
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final channel = filtered[index];
                final isCurrent = channel.id == widget.currentChannelId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: isCurrent
                        ? colors.primary.withValues(alpha: .14)
                        : colors.surfaceContainerHighest.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context, channel),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    channel.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  if (channel.nowPlaying != null ||
                                      channel.categories.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 3),
                                    Text(
                                      channel.nowPlaying ??
                                          channel.categories.join(' • '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: channel.nowPlaying != null
                                                ? colors.primary
                                                : colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              isCurrent
                                  ? PhosphorIcons.playCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.circle(),
                              size: 22,
                              color: isCurrent
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
