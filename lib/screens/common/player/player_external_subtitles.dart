import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/external_subtitles.dart';
import '../../../models/movie_stream_metadata.dart';
import '../../../models/tv_stream_metadata.dart';
import '../../../services/external_subtitle_service.dart';
import '../../../ui_components/app_ui_components.dart';
import 'player_sheet_ui.dart';

class PlayerExternalSubtitles {
  List<ExternalSubtitle> _availableExternalSubtitles = [];
  final List<ExternalSubtitle> _selectedExternalSubtitles = [];
  bool _isLoadingExternalSubtitles = false;
  bool _isExternalSubtitlesMenuOpen = false;
  final Set<String> _addedExternalSubtitleIds = {}; // Track added subtitle IDs

  final List<BetterPlayerSubtitlesSource> _appliedSubtitles = [];
  List<BetterPlayerSubtitlesSource> get appliedSubtitles =>
      List.unmodifiable(_appliedSubtitles);

  /// Show external subtitles menu
  void showExternalSubtitlesMenu({
    required BuildContext context,
    required List<Color> colors,
    required MediaType? mediaType,
    MovieStreamMetadata? movieMetadata,
    TVStreamMetadata? tvMetadata,
    required BetterPlayerController betterPlayerController,
  }) {
    _isExternalSubtitlesMenuOpen = true;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: .78,
        minChildSize: .52,
        maxChildSize: .95,
        expand: false,
        snap: true,
        snapSizes: const [.52, .78, .95],
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setBottomSheetState) {
            if (_availableExternalSubtitles.isEmpty &&
                !_isLoadingExternalSubtitles) {
              _isLoadingExternalSubtitles = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                _fetchExternalSubtitles(
                  setBottomSheetState,
                  context,
                  mediaType,
                  movieMetadata,
                  tvMetadata,
                  colors,
                );
              });
            }

            final Widget content;
            if (_isLoadingExternalSubtitles) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr('searching_for_subtitles'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'FigtreeSB',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('loading_video_sources'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            } else if (_availableExternalSubtitles.isEmpty) {
              content = AppEmptyState(
                icon: PhosphorIcons.closedCaptioning(),
                title: tr('no_external_subtitles_found'),
                message: tr('try_searching_for_subtitles'),
                action: FilledButton.icon(
                  onPressed: () => _fetchExternalSubtitles(
                    setBottomSheetState,
                    context,
                    mediaType,
                    movieMetadata,
                    tvMetadata,
                    colors,
                  ),
                  icon: Icon(PhosphorIcons.magnifyingGlass()),
                  label: Text(tr('search_subtitles')),
                ),
              );
            } else {
              content = ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: _availableExternalSubtitles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final subtitle = _availableExternalSubtitles[index];
                  final selected = _selectedExternalSubtitles
                      .any((item) => item.id == subtitle.id);
                  return PlayerChoiceCard(
                    title: subtitle.displayName,
                    subtitle: tr(
                      'subtitle_source',
                      namedArgs: {'source': subtitle.source},
                    ),
                    selected: selected,
                    onTap: () => _toggleExternalSubtitle(
                      subtitle,
                      setBottomSheetState,
                    ),
                    thumbnail: PlayerThumbnail(
                      width: 48,
                      height: 34,
                      child: subtitle.flagUrl.isEmpty
                          ? Icon(PhosphorIcons.flag())
                          : CachedNetworkImage(
                              imageUrl: subtitle.flagUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  const AppCachedImagePlaceholder(),
                              errorWidget: (_, __, ___) =>
                                  Icon(PhosphorIcons.flag()),
                            ),
                    ),
                  );
                },
              );
            }

            return PlayerSheetScaffold(
              icon: PhosphorIcons.closedCaptioning(),
              title: tr('external_subtitles'),
              subtitle: _availableExternalSubtitles.isEmpty
                  ? tr('search_subtitles')
                  : tr(
                      'found_external_subtitles',
                      namedArgs: {
                        'count': '${_availableExternalSubtitles.length}',
                      },
                    ),
              actions: [
                if (_availableExternalSubtitles.isNotEmpty)
                  IconButton(
                    tooltip: tr('refresh'),
                    onPressed: _isLoadingExternalSubtitles
                        ? null
                        : () => _fetchExternalSubtitles(
                              setBottomSheetState,
                              context,
                              mediaType,
                              movieMetadata,
                              tvMetadata,
                              colors,
                            ),
                    icon: Icon(PhosphorIcons.arrowsClockwise()),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  icon: Icon(PhosphorIcons.x()),
                ),
              ],
              footer: _selectedExternalSubtitles.isEmpty
                  ? null
                  : PlayerSheetFooter(
                      label: tr(
                        'subtitles_selected',
                        namedArgs: {
                          'count': '${_selectedExternalSubtitles.length}',
                        },
                      ),
                      actionLabel: tr('apply'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(bottomSheetContext);
                        await _applyExternalSubtitlesWithMessenger(
                          messenger,
                          colors,
                          betterPlayerController,
                        );
                      },
                    ),
              child: content,
            );
          },
        ),
      ),
    ).whenComplete(() {
      _isExternalSubtitlesMenuOpen = false;
    });
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
    _setBottomSheetStateIfOpen(setBottomSheetState, () {
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
      _setBottomSheetStateIfOpen(setBottomSheetState, () {
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
      _setBottomSheetStateIfOpen(setBottomSheetState, () {
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

  void _setBottomSheetStateIfOpen(
      StateSetter setBottomSheetState, VoidCallback fn) {
    if (!_isExternalSubtitlesMenuOpen) {
      return;
    }

    setBottomSheetState(fn);
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

        _appliedSubtitles.add(betterPlayerSource);

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
