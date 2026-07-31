import 'package:better_player_plus/better_player_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/offline_download.dart';
import '../../models/movie_stream_metadata.dart';
import '../../models/tv_stream_metadata.dart';
import '../../constants/app_constants.dart';
import 'player/player_external_subtitles.dart';

/// The lightweight offline variant of FlixQuest's Better Player. The controls
/// keep the same visual language as streaming playback, while omitting
/// provider, quality, subtitle-download and episode-selection actions that do
/// not apply to a single, downloaded MP4.
class OfflinePlayerScreen extends StatefulWidget {
  const OfflinePlayerScreen({
    super.key,
    required this.download,
  });

  final OfflineDownload download;

  @override
  State<OfflinePlayerScreen> createState() => _OfflinePlayerScreenState();
}

class _OfflinePlayerScreenState extends State<OfflinePlayerScreen> {
  late final BetterPlayerController _controller;
  final GlobalKey _playerKey = GlobalKey();
  var _initialized = false;
  final PlayerExternalSubtitles _externalSubtitles = PlayerExternalSubtitles();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final colors = Theme.of(context).colorScheme;
    final accent = Theme.of(context).primaryColor;
    final controls = BetterPlayerControlsConfiguration(
      gestureConfiguration: const BetterPlayerGestureConfiguration(
        enableVolumeSwipe: true,
        enableBrightnessSwipe: true,
        enableSeekSwipe: true,
        volumeSwipeSensitivity: 0.5,
        brightnessSwipeSensitivity: 0.5,
        seekSwipeSensitivity: 1.0,
      ),
      name: widget.download.title,
      watchingText: tr('watching_text'),
      enableFullscreen: true,
      enableSubtitles: true,
      enableQualities: false,
      enablePip: true,
      enableAudioTracks: true,
      backgroundColor: Colors.black,
      progressBarBackgroundColor: Colors.white,
      controlBarColor: Colors.black.withValues(alpha: .48),
      muteIcon: PhosphorIcons.speakerSimpleSlash(),
      unMuteIcon: PhosphorIcons.speakerHigh(),
      pauseIcon: PhosphorIcons.pause(),
      pipMenuIcon: PhosphorIcons.appWindow(),
      playIcon: PhosphorIcons.play(),
      showControlsOnInitialize: false,
      controlsHideTime: const Duration(milliseconds: 300),
      loadingColor: accent,
      loadingWidget: SizedBox(
        width: 60,
        height: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 3,
            color: accent,
            backgroundColor: accent.withValues(alpha: .24),
          ),
        ),
      ),
      iconsColor: accent,
      progressBarPlayedColor: accent,
      progressBarBufferedColor: Colors.black45,
      skipForwardIcon: PhosphorIcons.fastForward(),
      skipBackIcon: PhosphorIcons.rewind(),
      fullscreenEnableIcon: PhosphorIcons.cornersOut(),
      fullscreenDisableIcon: PhosphorIcons.cornersIn(),
      overflowMenuIcon: PhosphorIcons.dotsThreeVertical(),
      overflowMenuIconsColor: accent,
      overflowModalTextColor: accent,
      overflowModalColor: colors.surface,
      overflowMenuCustomItems: [
        BetterPlayerOverflowMenuItem(
          PhosphorIcons.closedCaptioning(),
          tr('external_subtitles'),
          _showExternalSubtitles,
        ),
      ],
      controlBarHeight: 56,
    );
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoDetectFullscreenDeviceOrientation: true,
        autoDetectFullscreenAspectRatio: true,
        autoPlay: true,
        fit: BoxFit.contain,
        autoDispose: true,
        allowedScreenSleep: false,
        controlsConfiguration: controls,
        showPlaceholderUntilPlay: true,
        errorBuilder: (_, __) => const Center(
          child: Text(
            'This downloaded video could not be played.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
    _controller.setBetterPlayerGlobalKey(_playerKey);
    final savedSubtitle = widget.download.offlineSubtitlePath;
    _controller.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        'flixquest-offline://${widget.download.id}',
        videoFormat: BetterPlayerVideoFormat.other,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          key: 'flixquest-offline:${widget.download.id}',
        ),
        subtitles: savedSubtitle?.isNotEmpty == true
            ? [
                BetterPlayerSubtitlesSource(
                  type: BetterPlayerSubtitlesSourceType.file,
                  urls: [savedSubtitle],
                  name: widget.download.offlineSubtitleName ??
                      'Downloaded subtitle',
                  selectedByDefault: true,
                ),
              ]
            : const [],
      ),
    );
  }

  void _showExternalSubtitles() {
    final id = widget.download.contentId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Subtitle search is unavailable for this older download.')),
      );
      return;
    }
    final isMovie = widget.download.mediaType == 'movie';
    _externalSubtitles.showExternalSubtitlesMenu(
      context: context,
      colors: [
        Theme.of(context).primaryColor,
        Theme.of(context).colorScheme.surface
      ],
      mediaType: isMovie ? MediaType.movie : MediaType.tvShow,
      movieMetadata: isMovie
          ? MovieStreamMetadata(
              backdropPath: null,
              elapsed: 0,
              movieId: id,
              movieName: widget.download.title,
              posterPath: null,
              releaseYear: null,
              isAdult: false,
              releaseDate: null,
            )
          : null,
      tvMetadata: isMovie
          ? null
          : TVStreamMetadata(
              elapsed: 0,
              episodeId: 0,
              episodeName: widget.download.subtitle,
              episodeNumber: widget.download.episodeNumber ?? 0,
              posterPath: null,
              seasonNumber: widget.download.seasonNumber ?? 0,
              seriesName: widget.download.title,
              tvId: id,
              airDate: null,
            ),
      betterPlayerController: _controller,
    );
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: BetterPlayer(controller: _controller, key: _playerKey),
        ),
      ),
    );
  }
}
