import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/tv_stream_metadata.dart';
import '../../../ui_components/app_ui_components.dart';
import '../../tv/tv_video_loader.dart';
import 'player_sheet_ui.dart';

class PlayerNextEpisodeWidget {
  Widget buildNextEpisodeFloatingButton({
    required BuildContext context,
    required TVStreamMetadata tvMetadata,
    required bool showNextEpisodeButton,
    required List<Color> colors,
    required Function() onSaveProgress,
    required Function() closePlayer,
    bool useTvPlayer = false,
  }) {
    final episodes = tvMetadata.seasonEpisodes;
    if (episodes == null) return const SizedBox.shrink();
    final currentIndex = episodes.indexWhere(
      (episode) =>
          episode.episodeNumber == tvMetadata.episodeNumber &&
          episode.seasonNumber == tvMetadata.seasonNumber,
    );
    if (currentIndex < 0 || currentIndex >= episodes.length - 1) {
      return const SizedBox.shrink();
    }
    final nextEpisode = episodes[currentIndex + 1];
    final navigator = Navigator.of(context);

    return Positioned(
      right: 16,
      bottom: 92,
      child: IgnorePointer(
        ignoring: !showNextEpisodeButton,
        child: AnimatedSlide(
          offset: showNextEpisodeButton ? Offset.zero : const Offset(.2, 0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: showNextEpisodeButton ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: SizedBox(
              width:
                  (MediaQuery.sizeOf(context).width * .48).clamp(220.0, 330.0),
              child: PlayerChoiceCard(
                title:
                    '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                subtitle: tr('next_episode'),
                description: nextEpisode.overview,
                thumbnail: PlayerThumbnail(
                  width: 108,
                  height: 68,
                  child: nextEpisode.stillPath == null
                      ? Icon(PhosphorIcons.filmStrip())
                      : CachedNetworkImage(
                          cacheManager: cacheProp(),
                          imageUrl:
                              'https://image.tmdb.org/t/p/w300${nextEpisode.stillPath}',
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const AppCachedImagePlaceholder(),
                          errorWidget: (_, __, ___) =>
                              Icon(PhosphorIcons.filmStrip()),
                        ),
                ),
                trailing: Icon(
                  PhosphorIcons.playCircle(PhosphorIconsStyle.fill),
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  onSaveProgress();
                  closePlayer();
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => TVVideoLoader(
                        download: false,
                        useTvPlayer: useTvPlayer,
                        metadata: _metadataForEpisode(
                          nextEpisode,
                          tvMetadata,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showNextEpisodeCountdown({
    required BuildContext context,
    required EpisodeMetadata nextEpisode,
    required List<Color> colors,
    required TVStreamMetadata tvMetadata,
    required Function() onSaveProgress,
    required Function() closePlayer,
    bool useTvPlayer = false,
  }) {
    var countdown = 10;
    Timer? timer;
    var dismissed = false;
    final navigator = Navigator.of(context);

    void play(BuildContext dialogContext) {
      if (dismissed) return;
      dismissed = true;
      timer?.cancel();
      if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);
      onSaveProgress();
      closePlayer();
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => TVVideoLoader(
            download: false,
            useTvPlayer: useTvPlayer,
            metadata: _metadataForEpisode(nextEpisode, tvMetadata),
          ),
        ),
      );
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            if (dismissed) return;
            if (countdown <= 1) {
              play(dialogContext);
            } else if (dialogContext.mounted) {
              setDialogState(() => countdown--);
            }
          });
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            PhosphorIcons.skipForward(
                              PhosphorIconsStyle.fill,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            tr('next_episode'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PlayerChoiceCard(
                      title:
                          '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                      subtitle: tr(
                        'playing_in_seconds',
                        namedArgs: {'seconds': '$countdown'},
                      ),
                      description: nextEpisode.overview,
                      selected: true,
                      onTap: null,
                      thumbnail: PlayerThumbnail(
                        width: 112,
                        height: 70,
                        child: nextEpisode.stillPath == null
                            ? Icon(PhosphorIcons.filmStrip())
                            : CachedNetworkImage(
                                cacheManager: cacheProp(),
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w300${nextEpisode.stillPath}',
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    const AppCachedImagePlaceholder(),
                                errorWidget: (_, __, ___) =>
                                    Icon(PhosphorIcons.filmStrip()),
                              ),
                      ),
                      trailing: SizedBox(
                        width: 38,
                        height: 38,
                        child: CircularProgressIndicator(
                          value: countdown / 10,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            dismissed = true;
                            timer?.cancel();
                            Navigator.pop(dialogContext);
                          },
                          child: Text(tr('cancel')),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () => play(dialogContext),
                          icon: Icon(PhosphorIcons.play()),
                          label: Text(tr('play_now')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      dismissed = true;
      timer?.cancel();
    });
  }

  TVStreamMetadata _metadataForEpisode(
    EpisodeMetadata episode,
    TVStreamMetadata current,
  ) {
    return TVStreamMetadata(
      elapsed: null,
      episodeId: episode.episodeId,
      episodeName: episode.episodeName,
      episodeNumber: episode.episodeNumber,
      posterPath: current.posterPath,
      backdropPath: episode.stillPath ?? current.backdropPath,
      seasonNumber: episode.seasonNumber,
      seriesName: current.seriesName,
      tvId: current.tvId,
      airDate: episode.airDate,
      seasonEpisodes: current.seasonEpisodes,
      allSeasons: current.allSeasons,
    );
  }
}
