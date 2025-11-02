import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../models/recently_watched.dart';
import '../../../models/tv_stream_metadata.dart';
import '../../../provider/app_dependency_provider.dart';
import '../../../provider/recently_watched_provider.dart';
import '../../../provider/settings_provider.dart';
import '../../../api/endpoints.dart';
import '../../../functions/network.dart';
import '../../tv/tv_video_loader.dart';

class PlayerEpisodeSelection {
  int? _browsedSeasonNumber;

  PlayerEpisodeSelection(this._browsedSeasonNumber);

  void showEpisodeSelectionBottomSheet({
    required BuildContext context,
    required List<Color> colors,
    required TVStreamMetadata tvMetadata,
    required StreamRoute? tvRoute,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) {
    if (tvMetadata.seasonEpisodes == null ||
        tvMetadata.seasonEpisodes!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        snapSizes: [0.5, 0.7, 0.95],
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Draggable Header
              SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Back button to season selector (if multiple seasons available)
                          if (tvMetadata.allSeasons != null &&
                              tvMetadata.allSeasons!.length > 1)
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                                showSeasonSelectionBottomSheet(
                                  context: context,
                                  colors: colors,
                                  tvMetadata: tvMetadata,
                                  tvRoute: tvRoute,
                                  onSaveProgress: onSaveProgress,
                                  closePlayer: closePlayer,
                                );
                              },
                            )
                          else
                            SizedBox(width: 60),
                          Expanded(
                            child: Text(
                              tr('season_episodes', namedArgs: {
                                'season':
                                    '${_browsedSeasonNumber ?? tvMetadata.seasonNumber}'
                              }),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                  ],
                ),
              ),
              // Episode List
              Expanded(
                child: Consumer<RecentProvider>(
                  builder: (context, recentProvider, child) {
                    return ListView.builder(
                      itemCount: tvMetadata.seasonEpisodes!.length,
                      itemBuilder: (context, index) {
                        final episode = tvMetadata.seasonEpisodes![index];
                        final isCurrentEpisode =
                            episode.episodeNumber == tvMetadata.episodeNumber &&
                                episode.seasonNumber == tvMetadata.seasonNumber;

                        // Check if episode is in recently watched
                        final recentEpisode =
                            recentProvider.episodes.firstWhere(
                          (e) => e.id == episode.episodeId,
                          orElse: () => RecentEpisode(
                            dateTime: '',
                            elapsed: 0,
                            id: 0,
                            posterPath: '',
                            remaining: 0,
                            seriesName: '',
                            episodeName: '',
                            episodeNum: 0,
                            seasonNum: 0,
                            seriesId: 0,
                          ),
                        );

                        final hasProgress = recentEpisode.id != 0;
                        final progressPercentage =
                            hasProgress && recentEpisode.elapsed! > 0
                                ? (recentEpisode.elapsed! /
                                        (recentEpisode.elapsed! +
                                            recentEpisode.remaining!)) *
                                    100
                                : 0.0;

                        return InkWell(
                          onTap: () async {
                            if (!isCurrentEpisode) {
                              // Save progress and send analytics before switching
                              onSaveProgress();

                              if (context.mounted) {
                                // Close the bottom sheet first
                                Navigator.pop(context);
                                closePlayer();

                                // Use pushReplacement to replace Player with VideoLoader
                                // This prevents player stacking
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TVVideoLoader(
                                      download: false,
                                      route: tvRoute ?? StreamRoute.flixHQ,
                                      metadata: TVStreamMetadata(
                                        elapsed: null,
                                        episodeId: episode.episodeId,
                                        episodeName: episode.episodeName,
                                        episodeNumber: episode.episodeNumber,
                                        posterPath: tvMetadata.posterPath,
                                        seasonNumber: episode.seasonNumber,
                                        seriesName: tvMetadata.seriesName,
                                        tvId: tvMetadata.tvId,
                                        airDate: episode.airDate,
                                        seasonEpisodes:
                                            tvMetadata.seasonEpisodes,
                                        allSeasons: tvMetadata.allSeasons,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: _buildEpisodeListItem(
                            context,
                            episode,
                            isCurrentEpisode,
                            hasProgress,
                            progressPercentage,
                            colors,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeListItem(
    BuildContext context,
    EpisodeMetadata episode,
    bool isCurrentEpisode,
    bool hasProgress,
    double progressPercentage,
    List<Color> colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentEpisode ? colors.first.withOpacity(0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode thumbnail
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: episode.stillPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            cacheManager: cacheProp(),
                            imageUrl:
                                'https://image.tmdb.org/t/p/w300${episode.stillPath}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.first,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.grey[600],
                            size: 32,
                          ),
                        ),
                ),
                // Progress bar
                if (hasProgress && progressPercentage > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: LinearProgressIndicator(
                        value: progressPercentage / 100,
                        backgroundColor: Colors.grey[700],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.first,
                        ),
                      ),
                    ),
                  ),
                // Current episode indicator
                if (isCurrentEpisode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.first,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tr('playing'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${episode.episodeNumber}. ${episode.episodeName}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isCurrentEpisode ? FontWeight.bold : FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Rating and runtime row
                  Row(
                    children: [
                      if (episode.voteAverage != null &&
                          episode.voteAverage! > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.first.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: colors.first,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${episode.voteAverage!.toStringAsFixed(1)}/10',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.first,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (episode.voteAverage != null &&
                          episode.voteAverage! > 0 &&
                          episode.runtime != null)
                        SizedBox(width: 8),
                      if (episode.runtime != null)
                        Text(
                          '${episode.runtime}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                  if (episode.overview != null && episode.overview!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        episode.overview!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSeasonSelectionBottomSheet({
    required BuildContext context,
    required List<Color> colors,
    required TVStreamMetadata tvMetadata,
    required StreamRoute? tvRoute,
    required Function() onSaveProgress,
    required Function() closePlayer,
  }) {
    if (tvMetadata.allSeasons == null || tvMetadata.allSeasons!.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        snap: true,
        snapSizes: [0.4, 0.6, 0.9],
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Draggable Header
              SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('select_season'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                  ],
                ),
              ),
              // Season List
              Expanded(
                child: ListView.builder(
                  itemCount: tvMetadata.allSeasons!.length,
                  itemBuilder: (context, index) {
                    final season = tvMetadata.allSeasons![index];
                    final isCurrentSeason =
                        season.seasonNumber == tvMetadata.seasonNumber;

                    return InkWell(
                      onTap: () async {
                        // Check if we need to fetch episodes (either different season OR episodes from wrong season are loaded)
                        if (!isCurrentSeason ||
                            _browsedSeasonNumber != season.seasonNumber) {
                          // Store the root navigator and context before closing the sheet
                          final rootNavigator =
                              Navigator.of(context, rootNavigator: true);

                          // Close season selector first
                          Navigator.of(context).pop();

                          // Show loading indicator using root navigator
                          rootNavigator.push(
                            PageRouteBuilder(
                              opaque: false,
                              barrierDismissible: false,
                              pageBuilder: (_, __, ___) => WillPopScope(
                                onWillPop: () async => false,
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: colors.first,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          // Fetch episodes for the selected season
                          await _fetchEpisodesForSeason(
                            context,
                            season.seasonNumber,
                            tvMetadata,
                            colors,
                          );

                          // Close loading indicator using root navigator
                          rootNavigator.pop();

                          // Use WidgetsBinding to ensure we show the sheet after the frame is complete
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Get the current context from the root navigator
                            final currentContext = rootNavigator.context;
                            if (currentContext.mounted) {
                              showEpisodeSelectionBottomSheet(
                                context: currentContext,
                                colors: colors,
                                tvMetadata: tvMetadata,
                                tvRoute: tvRoute,
                                onSaveProgress: onSaveProgress,
                                closePlayer: closePlayer,
                              );
                            }
                          });
                        } else {
                          // Already showing correct season's episodes, just go back
                          Navigator.pop(context);
                          showEpisodeSelectionBottomSheet(
                            context: context,
                            colors: colors,
                            tvMetadata: tvMetadata,
                            tvRoute: tvRoute,
                            onSaveProgress: onSaveProgress,
                            closePlayer: closePlayer,
                          );
                        }
                      },
                      child: _buildSeasonListItem(
                        context,
                        season,
                        isCurrentSeason,
                        colors,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonListItem(
    BuildContext context,
    SeasonMetadata season,
    bool isCurrentSeason,
    List<Color> colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentSeason ? colors.first.withOpacity(0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Season poster
            if (season.posterPath != null)
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[800],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    cacheManager: cacheProp(),
                    imageUrl:
                        'https://image.tmdb.org/t/p/w185${season.posterPath}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.first,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        Icons.tv,
                        color: Colors.grey[600],
                        size: 32,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: Center(
                  child: Icon(
                    Icons.tv,
                    color: Colors.grey[600],
                    size: 32,
                  ),
                ),
              ),
            SizedBox(width: 16),
            // Season info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.seasonName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isCurrentSeason ? FontWeight.bold : FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    tr('episodes_count',
                        namedArgs: {'count': '${season.episodeCount}'}),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (season.overview != null && season.overview!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        season.overview!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (isCurrentSeason)
              Icon(
                Icons.check_circle,
                color: colors.first,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchEpisodesForSeason(
    BuildContext context,
    int seasonNumber,
    TVStreamMetadata tvMetadata,
    List<Color> colors,
  ) async {
    try {
      final isProxyEnabled =
          Provider.of<SettingsProvider>(context, listen: false).enableProxy;
      final proxyUrl =
          Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
      final currentLanguage =
          Provider.of<SettingsProvider>(context, listen: false).appLanguage;

      await fetchTVDetails(
        Endpoints.getSeasonDetails(
          tvMetadata.tvId!,
          seasonNumber,
          currentLanguage,
        ),
        isProxyEnabled,
        proxyUrl,
      ).then((value) {
        if (value.episodes != null && value.episodes!.isNotEmpty) {
          // Update the browsed season number to show in the title
          _browsedSeasonNumber = seasonNumber;

          // DON'T update tvMetadata.seasonNumber here!
          // That field represents the CURRENTLY PLAYING episode's season,
          // not the season being browsed in the list.
          // Only update the episodes list.
          tvMetadata.seasonEpisodes = value.episodes!
              .map((episode) => EpisodeMetadata(
                    episodeId: episode.episodeId ?? 0,
                    episodeName:
                        episode.name ?? 'Episode ${episode.episodeNumber}',
                    episodeNumber: episode.episodeNumber ?? 0,
                    seasonNumber: seasonNumber, // Use the fetched season number
                    stillPath: episode.stillPath,
                    airDate: episode.airDate,
                    runtime: null,
                    overview: episode.overview,
                    voteAverage: episode.voteAverage,
                  ))
              .toList();
        }
      });
    } catch (e) {
      debugPrint('Failed to fetch episodes for season $seasonNumber: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('failed_load_season_episodes')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
