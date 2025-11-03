import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/tv_stream_metadata.dart';
import '../../tv/tv_video_loader.dart';

class PlayerNextEpisodeWidget {
  Widget buildNextEpisodeFloatingButton({
    required BuildContext context,
    required TVStreamMetadata tvMetadata,
    required bool showNextEpisodeButton,
    required List<Color> colors,
    required Function() onSaveProgress,
    required Function() closePlayer,
    required StreamRoute? tvRoute,
  }) {
    if (tvMetadata.seasonEpisodes == null) {
      return SizedBox.shrink();
    }

    final currentIndex = tvMetadata.seasonEpisodes!.indexWhere(
      (e) => e.episodeNumber == tvMetadata.episodeNumber,
    );

    if (currentIndex == -1 ||
        currentIndex >= tvMetadata.seasonEpisodes!.length - 1) {
      return SizedBox.shrink();
    }

    final nextEpisode = tvMetadata.seasonEpisodes![currentIndex + 1];

    return Positioned(
      bottom: 100, // Increased padding to not cover progress bar
      right: 16,
      child: AnimatedOpacity(
        opacity: showNextEpisodeButton ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () async {
            // Save progress and send analytics before switching
            onSaveProgress();

            if (context.mounted) {
              closePlayer();
              // Use pushReplacement to replace Player with VideoLoader
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TVVideoLoader(
                    download: false,
                    route: tvRoute ?? StreamRoute.flixHQ,
                    metadata: TVStreamMetadata(
                      elapsed: null,
                      episodeId: nextEpisode.episodeId,
                      episodeName: nextEpisode.episodeName,
                      episodeNumber: nextEpisode.episodeNumber,
                      posterPath: tvMetadata.posterPath,
                      seasonNumber: nextEpisode.seasonNumber,
                      seriesName: tvMetadata.seriesName,
                      tvId: tvMetadata.tvId,
                      airDate: nextEpisode.airDate,
                      seasonEpisodes: tvMetadata.seasonEpisodes,
                      allSeasons: tvMetadata.allSeasons,
                    ),
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.first,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Episode thumbnail
                    if (nextEpisode.stillPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              cacheManager: cacheProp(),
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w300${nextEpisode.stillPath}',
                              height: 110,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 110,
                                color: Colors.grey[800],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.first,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 110,
                                color: Colors.grey[800],
                                child: Center(
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.grey[600],
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            // Play icon overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: colors.first,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Episode info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('next_episode'),
                            style: TextStyle(
                              color: colors.first,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'FigtreeBold',
                              letterSpacing: 0.5,
                              decoration:
                                  TextDecoration.none, // Remove any decoration
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'FigtreeSB',
                              decoration:
                                  TextDecoration.none, // Remove any decoration
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Close button at top right
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      // This is handled in the parent by hideNextEpisodeOverlay callback
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
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
    required StreamRoute? tvRoute,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) {
    int countdown = 10; // 10 second countdown
    Timer? countdownTimer;
    bool dismissed = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Only create timer once, not on every rebuild
            if (countdownTimer == null && !dismissed) {
              countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
                if (countdown > 0 && !dismissed) {
                  setDialogState(() {
                    countdown--;
                  });
                } else if (countdown == 0 && !dismissed) {
                  timer.cancel();
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop();
                  }

                  // Save progress and send analytics before switching
                  onSaveProgress();

                  // Pop current player, then push new video loader
                  if (context.mounted) {
                    closePlayer();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TVVideoLoader(
                          download: false,
                          route: tvRoute ?? StreamRoute.flixHQ,
                          metadata: TVStreamMetadata(
                            elapsed: null,
                            episodeId: nextEpisode.episodeId,
                            episodeName: nextEpisode.episodeName,
                            episodeNumber: nextEpisode.episodeNumber,
                            posterPath: tvMetadata.posterPath,
                            seasonNumber: nextEpisode.seasonNumber,
                            seriesName: tvMetadata.seriesName,
                            tvId: tvMetadata.tvId,
                            airDate: nextEpisode.airDate,
                            seasonEpisodes: tvMetadata.seasonEpisodes,
                            allSeasons: tvMetadata.allSeasons,
                          ),
                        ),
                      ),
                    );
                  }
                }
              });
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                tr('next_episode'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nextEpisode.episodeNumber}. ${nextEpisode.episodeName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (nextEpisode.overview != null &&
                          nextEpisode.overview!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nextEpisode.overview!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          tr('playing_in_seconds',
                              namedArgs: {'seconds': countdown.toString()}),
                          style: TextStyle(
                            color: colors.first,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    tr('cancel'),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    dismissed = true;
                    countdownTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                    // Save progress and send analytics before switching
                    onSaveProgress();
                    // Pop current player, then push new video loader
                    if (context.mounted) {
                      closePlayer();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TVVideoLoader(
                            download: false,
                            route: tvRoute ?? StreamRoute.flixHQ,
                            metadata: TVStreamMetadata(
                              elapsed: null,
                              episodeId: nextEpisode.episodeId,
                              episodeName: nextEpisode.episodeName,
                              episodeNumber: nextEpisode.episodeNumber,
                              posterPath: tvMetadata.posterPath,
                              seasonNumber: nextEpisode.seasonNumber,
                              seriesName: tvMetadata.seriesName,
                              tvId: tvMetadata.tvId,
                              airDate: nextEpisode.airDate,
                              seasonEpisodes: tvMetadata.seasonEpisodes,
                              allSeasons: tvMetadata.allSeasons,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.first,
                  ),
                  child: Text(
                    tr('play_now'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dialog dismissed, cancel timer
      dismissed = true;
      countdownTimer?.cancel();
    });
  }
}
