import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../ui_components/app_ui_components.dart';
import 'player_sheet_ui.dart';

class _LocalSubtitleEntry {
  final String filePath;
  final String fileName;
  final String extension;
  bool isSelected;

  _LocalSubtitleEntry({
    required this.filePath,
    required this.fileName,
    required this.extension,
    this.isSelected = false,
  });
}

/// Allows users to upload local .srt/.vtt subtitle files from their device.
class PlayerLocalSubtitles {
  final List<_LocalSubtitleEntry> _uploadedSubtitles = [];
  final Set<String> _addedFilePaths = {};

  /// Show the local subtitles upload sheet.
  ///
  /// Opens a bottom sheet where the user can pick `.srt` or `.vtt` files from
  /// their device, review selected files, remove unwanted ones, and apply the
  /// chosen subtitles to the current stream.
  void showLocalSubtitlesUpload({
    required BuildContext context,
    required List<Color> colors,
    required BetterPlayerController betterPlayerController,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: .65,
        minChildSize: .40,
        maxChildSize: .90,
        expand: false,
        snap: true,
        snapSizes: const [.40, .65, .90],
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final Widget content;

            if (_uploadedSubtitles.isEmpty) {
              content = AppEmptyState(
                icon: PhosphorIcons.fileArrowUp(),
                title: tr('no_file_selected'),
                message: tr('supported_formats_srt_vtt'),
                action: FilledButton.icon(
                  onPressed: () => _pickFiles(setBottomSheetState, context),
                  icon: Icon(PhosphorIcons.fileArrowUp()),
                  label: Text(tr('upload_subtitle_file')),
                ),
              );
            } else {
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _pickFiles(setBottomSheetState, context),
                      icon: Icon(PhosphorIcons.plus()),
                      label: Text(tr('add_more')),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: _uploadedSubtitles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final subtitle = _uploadedSubtitles[index];
                        return PlayerChoiceCard(
                          title: subtitle.fileName,
                          subtitle:
                              '.${subtitle.extension} · ${tr('local_file')}',
                          selected: subtitle.isSelected,
                          onTap: () {
                            setBottomSheetState(() {
                              subtitle.isSelected = !subtitle.isSelected;
                            });
                          },
                          thumbnail: PlayerThumbnail(
                            width: 48,
                            height: 34,
                            child: Icon(PhosphorIcons.fileText()),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              PhosphorIcons.trash(),
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () {
                              setBottomSheetState(() {
                                _uploadedSubtitles.removeAt(index);
                                _removeAppliedSubtitle(
                                  subtitle.filePath,
                                  betterPlayerController,
                                );
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            final selectedCount =
                _uploadedSubtitles.where((s) => s.isSelected).length;

            return PlayerSheetScaffold(
              icon: PhosphorIcons.fileArrowUp(),
              title: tr('upload_subtitles'),
              subtitle: _uploadedSubtitles.isEmpty
                  ? tr('select_subtitle_file')
                  : tr(
                      _uploadedSubtitles.length == 1
                          ? 'subtitle_file_count'
                          : 'subtitle_files_count',
                      namedArgs: {
                        'count': '${_uploadedSubtitles.length}',
                      },
                    ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(bottomSheetContext),
                  icon: Icon(PhosphorIcons.x()),
                ),
              ],
              footer: selectedCount == 0
                  ? null
                  : PlayerSheetFooter(
                      label: tr('subtitles_selected',
                          namedArgs: {'count': '$selectedCount'}),
                      actionLabel: tr('apply'),
                      onPressed: () {
                        _applySelectedSubtitles(
                            context, betterPlayerController);
                        Navigator.pop(bottomSheetContext);
                      },
                    ),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickFiles(
      StateSetter setBottomSheetState, BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt', 'vtt'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setBottomSheetState(() {
          for (final file in result.files) {
            if (file.path != null) {
              final filePath = file.path!;
              // Avoid duplicates in the list
              if (!_uploadedSubtitles.any((s) => s.filePath == filePath)) {
                _uploadedSubtitles.add(
                  _LocalSubtitleEntry(
                    filePath: filePath,
                    fileName: file.name.replaceAll(
                        RegExp(r'\.(srt|vtt)$', caseSensitive: false), ''),
                    extension: file.extension ?? '',
                    isSelected: true, // auto-select new files
                  ),
                );
              }
            }
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('failed_upload_subtitle',
                namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final List<BetterPlayerSubtitlesSource> _appliedSubtitles = [];

  /// Get the list of all successfully applied local subtitles
  List<BetterPlayerSubtitlesSource> get appliedSubtitles =>
      List.unmodifiable(_appliedSubtitles);

  void _applySelectedSubtitles(
      BuildContext context, BetterPlayerController controller) {
    int added = 0;

    for (final subtitle in _uploadedSubtitles.where((s) => s.isSelected)) {
      if (_addedFilePaths.contains(subtitle.filePath)) {
        subtitle.isSelected = false;
        continue;
      }

      final source = BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.file,
        urls: [subtitle.filePath],
        name: subtitle.fileName,
      );

      controller.betterPlayerSubtitlesSourceList.add(source);
      _appliedSubtitles.add(source);

      _addedFilePaths.add(subtitle.filePath);
      added++;

      // Deselect after applying
      subtitle.isSelected = false;
    }

    if (added > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('subtitle_added')),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('subtitle_already_added')),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeAppliedSubtitle(
    String filePath,
    BetterPlayerController controller,
  ) {
    _addedFilePaths.remove(filePath);
    final removedSources = _appliedSubtitles.where(
      (source) => _isLocalSourceForPath(source, filePath),
    );
    final wasSelected = removedSources.any(
      (source) => identical(source, controller.betterPlayerSubtitlesSource),
    );
    _appliedSubtitles.removeWhere(
      (source) => _isLocalSourceForPath(source, filePath),
    );
    controller.betterPlayerSubtitlesSourceList.removeWhere(
      (source) => _isLocalSourceForPath(source, filePath),
    );
    if (wasSelected) {
      unawaited(
        controller.setupSubtitleSource(
          BetterPlayerSubtitlesSource(
            type: BetterPlayerSubtitlesSourceType.none,
          ),
        ),
      );
    }
  }

  bool _isLocalSourceForPath(
    BetterPlayerSubtitlesSource source,
    String filePath,
  ) {
    return source.type == BetterPlayerSubtitlesSourceType.file &&
        source.urls?.contains(filePath) == true;
  }
}
