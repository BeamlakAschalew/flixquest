import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/movie_stream_metadata.dart';
import '../../../models/tv_stream_metadata.dart';
import '../../../services/external_subtitle_service.dart';

class PlayerExternalSubtitles {
  List<ExternalSubtitle> _availableExternalSubtitles = [];
  final List<ExternalSubtitle> _selectedExternalSubtitles = [];
  bool _isLoadingExternalSubtitles = false;
  final Set<String> _addedExternalSubtitleIds = {}; // Track added subtitle IDs

  /// Show external subtitles menu
  void showExternalSubtitlesMenu({
    required BuildContext context,
    required List<Color> colors,
    required MediaType? mediaType,
    MovieStreamMetadata? movieMetadata,
    TVStreamMetadata? tvMetadata,
    required BetterPlayerController betterPlayerController,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        snapSizes: [0.5, 0.7, 0.95],
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setBottomSheetState) {
            // Auto-load subtitles when menu is first opened if not already loaded
            if (_availableExternalSubtitles.isEmpty &&
                !_isLoadingExternalSubtitles) {
              Future.microtask(() => _fetchExternalSubtitles(
                    setBottomSheetState,
                    context,
                    mediaType,
                    movieMetadata,
                    tvMetadata,
                    colors,
                  ));
            }

            return Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tr('external_subtitles'),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_availableExternalSubtitles.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () => _fetchExternalSubtitles(
                                        setBottomSheetState,
                                        context,
                                        mediaType,
                                        movieMetadata,
                                        tvMetadata,
                                        colors,
                                      ),
                                      tooltip: tr('refresh'),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _isLoadingExternalSubtitles
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: colors.first,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  tr('searching_for_subtitles'),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _availableExternalSubtitles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.subtitles_off_outlined,
                                      size: 64,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      tr('no_external_subtitles_found'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      tr('try_searching_for_subtitles'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () => _fetchExternalSubtitles(
                                        setBottomSheetState,
                                        context,
                                        mediaType,
                                        movieMetadata,
                                        tvMetadata,
                                        colors,
                                      ),
                                      icon: Icon(Icons.search),
                                      label: Text(tr('search_subtitles')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.first,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _availableExternalSubtitles.length,
                                itemBuilder: (context, index) {
                                  final subtitle =
                                      _availableExternalSubtitles[index];
                                  final isSelected = _selectedExternalSubtitles
                                      .any((s) => s.id == subtitle.id);

                                  return InkWell(
                                    onTap: () => _toggleExternalSubtitle(
                                        subtitle, setBottomSheetState),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colors.first
                                                .withValues(alpha: 0.1)
                                            : null,
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        child: Row(
                                          children: [
                                            // Flag icon
                                            if (subtitle.flagUrl.isNotEmpty)
                                              CachedNetworkImage(
                                                imageUrl: subtitle.flagUrl,
                                                width: 32,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 32,
                                                  height: 24,
                                                  color: Colors.grey[800],
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  Icons.flag,
                                                  color: Colors.grey[600],
                                                  size: 24,
                                                ),
                                              )
                                            else
                                              Icon(
                                                Icons.flag,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                            SizedBox(width: 16),
                                            // Subtitle info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    subtitle.displayName,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    tr('subtitle_source',
                                                        namedArgs: {
                                                          'source':
                                                              subtitle.source
                                                        }),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Selection indicator
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: colors.first,
                                                size: 24,
                                              )
                                            else
                                              Icon(
                                                Icons.circle_outlined,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                  // Footer with selected count
                  if (_selectedExternalSubtitles.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('subtitles_selected', namedArgs: {
                              'count': '${_selectedExternalSubtitles.length}'
                            }),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Store the navigator context before closing
                              final navigatorContext = Navigator.of(context);
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);

                              // Close the bottom sheet
                              navigatorContext.pop();

                              // Apply subtitles with scaffold messenger
                              await _applyExternalSubtitlesWithMessenger(
                                scaffoldMessenger,
                                colors,
                                betterPlayerController,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.first,
                            ),
                            child: Text(
                              tr('apply'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Fetch external subtitles from libre-subs API
  Future<void> _fetchExternalSubtitles(
    StateSetter setBottomSheetState,
    BuildContext context,
    MediaType? mediaType,
    MovieStreamMetadata? movieMetadata,
    TVStreamMetadata? tvMetadata,
    List<Color> colors,
  ) async {
    _isLoadingExternalSubtitles = true;
    setBottomSheetState(() {
      _isLoadingExternalSubtitles = true;
    });

    try {
      List<ExternalSubtitle> subtitles = [];

      if (mediaType == MediaType.movie) {
        // Fetch movie subtitles using TMDB ID
        subtitles = await ExternalSubtitleService.fetchMovieSubtitles(
          movieMetadata!.movieId!,
        );
      } else if (mediaType == MediaType.tvShow) {
        // Fetch TV episode subtitles using TMDB ID, season, and episode
        subtitles = await ExternalSubtitleService.fetchTVSubtitles(
          tvMetadata!.tvId!,
          tvMetadata.seasonNumber!,
          tvMetadata.episodeNumber!,
        );
      }

      _availableExternalSubtitles = subtitles;
      _isLoadingExternalSubtitles = false;
      setBottomSheetState(() {
        _availableExternalSubtitles = subtitles;
        _isLoadingExternalSubtitles = false;
      });

      // Show success message
      if (subtitles.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('found_external_subtitles',
                namedArgs: {'count': '${subtitles.length}'})),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _isLoadingExternalSubtitles = false;
      setBottomSheetState(() {
        _isLoadingExternalSubtitles = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('failed_load_subtitles',
                namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Toggle selection of an external subtitle
  void _toggleExternalSubtitle(
      ExternalSubtitle subtitle, StateSetter setBottomSheetState) {
    final isSelected =
        _selectedExternalSubtitles.any((s) => s.id == subtitle.id);

    if (isSelected) {
      _selectedExternalSubtitles.removeWhere((s) => s.id == subtitle.id);
    } else {
      _selectedExternalSubtitles.add(subtitle);
    }

    setBottomSheetState(() {});
  }

  /// Apply selected external subtitles to the player
  Future<void> _applyExternalSubtitlesWithMessenger(
    ScaffoldMessengerState scaffoldMessenger,
    List<Color> colors,
    BetterPlayerController betterPlayerController,
  ) async {
    if (_selectedExternalSubtitles.isEmpty) {
      return;
    }

    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.last),
              ),
            ),
            SizedBox(width: 16),
            Text(
              tr('downloading_processing_subtitles',
                  namedArgs: {'count': '${_selectedExternalSubtitles.length}'}),
              style: TextStyle(fontFamily: 'Figtree'),
            ),
          ],
        ),
        backgroundColor: colors.first,
        duration: Duration(seconds: 30),
      ),
    );

    try {
      int successCount = 0;

      // Add selected external subtitles to the player's subtitle list
      for (final externalSubtitle in _selectedExternalSubtitles) {
        // Check if this exact subtitle (by ID) is already added
        if (_addedExternalSubtitleIds.contains(externalSubtitle.id)) {
          continue; // Skip already added subtitles
        }

        // Count how many subtitles with the same display name exist
        final sameLanguageCount = betterPlayerController
            .betterPlayerSubtitlesSourceList
            .where(
                (source) => source.name!.startsWith(externalSubtitle.display))
            .length;

        // Download and convert to BetterPlayer source with a number
        final betterPlayerSource =
            await ExternalSubtitleService.convertToBetterPlayerSource(
          externalSubtitle,
          subtitleNumber: sameLanguageCount > 0 ? sameLanguageCount + 1 : null,
        );

        // Add to the controller's subtitle list
        betterPlayerController.betterPlayerSubtitlesSourceList
            .add(betterPlayerSource);

        // Mark this subtitle ID as added
        _addedExternalSubtitleIds.add(externalSubtitle.id);
        successCount++;
      }

      // Hide loading snackbar
      scaffoldMessenger.hideCurrentSnackBar();

      // Show success message
      if (successCount > 0) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              tr('added_external_subtitles',
                  namedArgs: {'count': '$successCount'}),
              style: TextStyle(fontFamily: 'Figtree'),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              tr('all_subtitles_already_added'),
              style: TextStyle(fontFamily: 'Figtree'),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Clear selection after applying
      _selectedExternalSubtitles.clear();
    } catch (e) {
      // Hide loading snackbar
      scaffoldMessenger.hideCurrentSnackBar();

      debugPrint(e.toString());
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              tr('failed_add_subtitles', namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
