// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/functions/video_utils.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';
import 'package:flixquest/constants/app_constants.dart'
    show MediaType, StreamRoute;
import 'package:flixquest/models/provider_load_state.dart';
import 'package:flixquest/services/globle_method.dart';
import 'package:flixquest/video_providers/provider_loader.dart';
import 'package:flixquest/widgets/provider_loading_widget.dart';
import '../../controllers/recently_watched_database_controller.dart';
import '../../provider/recently_watched_provider.dart';
import '../../video_providers/common.dart';
import '../../video_providers/names.dart';
import '/api/endpoints.dart';
import '/provider/app_dependency_provider.dart';
import '/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:better_player_plus/better_player.dart';
import '../../models/sub_languages.dart';
import '../../widgets/common_widgets.dart';

import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.metadata,
      required this.download,
      required this.route,
      super.key});

  final TVStreamMetadata metadata;
  final bool download;
  final StreamRoute route;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

  List<RegularVideoLinks>? tvVideoLinks;
  List<RegularSubtitleLinks>? tvVideoSubs;

  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  List<ProviderLoadState> providerStates = [];
  int currentProviderIndex = 0;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  late int foundIndex;

  @override
  void initState() {
    super.initState();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());

    // Initialize provider states
    for (var provider in videoProviders) {
      providerStates.add(ProviderLoadState(
        codeName: provider.codeName,
        fullName: provider.fullName,
        status: ProviderStatus.pending,
      ));
    }

    loadVideo();
  }

  void loadVideo() async {
    try {
      // Fetch season episodes first
      await _fetchSeasonEpisodes();

      var isBookmarked = await recentlyWatchedEpisodeController
          .contain(widget.metadata.episodeId!);
      int elapsed = 0;
      if (isBookmarked) {
        if (mounted) {
          var rEpisodes =
              Provider.of<RecentProvider>(context, listen: false).episodes;

          int index = rEpisodes
              .indexWhere((element) => element.id == widget.metadata.episodeId);
          setState(() {
            elapsed = rEpisodes[index].elapsed!;
          });
          widget.metadata.elapsed = elapsed;
        }
      } else {
        widget.metadata.elapsed = 0;
      }

      if (widget.metadata.airDate != null &&
          !isReleased(widget.metadata.airDate!)) {
        GlobalMethods.showScaffoldMessage(
            tr('episode_may_not_be_available'), context);
      }

      // Iterate through providers
      for (int i = 0; i < videoProviders.length; i++) {
        if (mounted) {
          setState(() {
            currentProviderIndex = i;
            providerStates[i] = providerStates[i].copyWith(
              status: ProviderStatus.loading,
            );
          });
        }

        try {
          final result = await ProviderLoader.loadTVFromProvider(
            providerCode: videoProviders[i].codeName,
            route: widget.route,
            tvId: widget.metadata.tvId!,
            seriesName: widget.metadata.seriesName!,
            seasonNumber: widget.metadata.seasonNumber!,
            episodeNumber: widget.metadata.episodeNumber!,
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            streamingServerDCVA: appDep.streamingServerDCVA,
            streamingServerZoro: appDep.streamingServerZoro,
            appLanguage: settings.appLanguage,
          );

          if (result.success &&
              result.videoLinks != null &&
              result.videoLinks!.isNotEmpty) {
            // Success! Mark provider as successful
            if (mounted) {
              setState(() {
                providerStates[i] = providerStates[i].copyWith(
                  status: ProviderStatus.success,
                );
                tvVideoLinks = result.videoLinks;
                tvVideoSubs = result.subtitleLinks;
              });
            }

            // Convert and process videos
            videos = VideoUtils.convertVideoLinksToMap(tvVideoLinks!);

            // Process subtitles if available
            if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
              await _processSubtitles(tvVideoSubs!);
            }

            break; // Found working provider, exit loop
          } else {
            // Provider failed
            if (mounted) {
              setState(() {
                providerStates[i] = providerStates[i].copyWith(
                  status: ProviderStatus.failed,
                  errorMessage: result.errorMessage ?? 'No video sources found',
                );
              });
            }
          }
        } catch (e) {
          // Provider error
          if (mounted) {
            setState(() {
              providerStates[i] = providerStates[i].copyWith(
                status: ProviderStatus.failed,
                errorMessage: e.toString(),
              );
            });
          }
        }
      }

      // Check if we found any working provider
      if ((tvVideoLinks == null || tvVideoLinks!.isEmpty) && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr('tv_vid_404'),
                hideButton: false,
              );
            },
            context: context);
        return;
      }

      // Prepare final video map (reversed for quality ordering)
      Map<String, String> reversedVids =
          VideoUtils.reverseVideoQualityMap(videos);

      if (tvVideoLinks != null && mounted) {
        final mixpanel =
            Provider.of<SettingsProvider>(context, listen: false).mixpanel;
        mixpanel.track('Most viewed TV series', properties: {
          'TV series name': widget.metadata.seriesName,
          'TV series id': '${widget.metadata.tvId}',
          'TV series episode name': '${widget.metadata.episodeName}',
          'TV series season number': '${widget.metadata.seasonNumber}',
          'TV series episode number': '${widget.metadata.episodeNumber}'
        });

        // Navigate to player
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerOne(
                mediaType: MediaType.tvShow,
                sources: reversedVids,
                subs: subs,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.surface
                ],
                settings: settings,
                tvMetadata: widget.metadata,
                tvRoute: widget.route,
                subtitleStyle:
                    Provider.of<SettingsProvider>(context).subtitleTextStyle,
                onEpisodeChange:
                    (episodeId, episodeNumber, seasonNumber) async {
                  // This callback is now unused but kept for backwards compatibility
                  // Episode changes are handled directly in the player
                },
              );
            },
          ),
        ).then((value) async {
          if (value != null) {
            Function callback = value;
            await callback.call();
          }
        });
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr('tv_vid_404'),
                  hideButton: false,
                );
              },
              context: context);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: "${tr("tv_vid_404")}\n$e",
                hideButton: false,
              );
            },
            context: context);
      }
    }
  }

  void getAppLanguage() {
    for (int i = 0; i < supportedLanguages.length; i++) {
      if (supportedLanguages[i].languageCode ==
          settings.defaultSubtitleLanguage) {
        foundIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ProviderLoadingWidget(
          providers: providerStates,
          currentIndex: currentProviderIndex,
        ),
      ),
    );
  }

  Future<void> _processSubtitles(List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final proxyUrl =
        Provider.of<AppDependencyProvider>(context, listen: false).tmdbProxy;
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);

    try {
      if (!appDep.fetchSubtitles) {
        return;
      }

      // Use the VideoUtils.parseSubtitles method
      final parsedSubs = await VideoUtils.parseSubtitles(
        subtitles: subtitles,
        defaultLanguage: settings.defaultSubtitleLanguage.isEmpty
            ? ''
            : supportedLanguages[foundIndex].englishName.isEmpty
                ? ''
                : supportedLanguages[foundIndex].languageCode,
        fetchAllLanguages: settings.fetchSpecificLangSubs,
        getVttContent: (url) => getVttFileAsString(url),
      );

      if (mounted) {
        setState(() {
          subs.addAll(parsedSubs);
        });
      }

      // Handle external subtitles if needed
      if (parsedSubs.isEmpty && appDep.useExternalSubtitles) {
        await fetchSocialLinks(
          Endpoints.getExternalLinksForTV(
              widget.metadata.tvId!, settings.appLanguage),
          isProxyEnabled,
          proxyUrl,
        ).then((value) async {
          if (value.imdbId != null) {
            await getExternalSubtitle(
                    Endpoints.searchExternalMovieSubtitles(value.imdbId!,
                        supportedLanguages[foundIndex].languageCode),
                    appDep.opensubtitlesKey)
                .then((value) async {
              if (value.isNotEmpty && value[0].attr!.files![0].fileId != null) {
                await downloadExternalSubtitle(
                        Endpoints.externalSubtitleDownload(),
                        value[0].attr!.files![0].fileId!,
                        appDep.opensubtitlesKey)
                    .then((value) async {
                  if (value.link != null) {
                    subs.addAll({
                      BetterPlayerSubtitlesSource(
                          name: supportedLanguages[foundIndex].englishName,
                          urls: [value.link],
                          selectedByDefault: true,
                          type: BetterPlayerSubtitlesSourceType.network)
                    });
                  }
                });
              }
            });
          }
        });
      }
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerGeneral(e, context);
    }
  }

  Future<void> _fetchSeasonEpisodes() async {
    try {
      if (widget.metadata.tvId != null &&
          widget.metadata.seasonNumber != null) {
        final isProxyEnabled =
            Provider.of<SettingsProvider>(context, listen: false).enableProxy;
        final proxyUrl =
            Provider.of<AppDependencyProvider>(context, listen: false)
                .tmdbProxy;

        // First, fetch TV details to get all seasons
        await fetchTVDetails(
          Endpoints.tvDetailsUrl(widget.metadata.tvId!, settings.appLanguage),
          isProxyEnabled,
          proxyUrl,
        ).then((tvDetails) {
          if (tvDetails.seasons != null && tvDetails.seasons!.isNotEmpty) {
            setState(() {
              widget.metadata.allSeasons = tvDetails.seasons!
                  .map((season) => SeasonMetadata.fromSeason(season))
                  .toList();
            });
          }
        });

        // Then fetch current season's episodes
        await fetchTVDetails(
          Endpoints.getSeasonDetails(
            widget.metadata.tvId!,
            widget.metadata.seasonNumber!,
            settings.appLanguage,
          ),
          isProxyEnabled,
          proxyUrl,
        ).then((value) {
          if (value.episodes != null && value.episodes!.isNotEmpty) {
            setState(() {
              // Explicitly pass seasonNumber to ensure it's correct
              widget.metadata.seasonEpisodes = value.episodes!
                  .map((episode) => EpisodeMetadata(
                        episodeId: episode.episodeId ?? 0,
                        episodeName:
                            episode.name ?? 'Episode ${episode.episodeNumber}',
                        episodeNumber: episode.episodeNumber ?? 0,
                        seasonNumber: widget.metadata
                            .seasonNumber!, // Use the current season number
                        stillPath: episode.stillPath,
                        airDate: episode.airDate,
                        runtime: null,
                        overview: episode.overview,
                        voteAverage: episode.voteAverage,
                      ))
                  .toList();
            });
          }
        });

        // Set the season change callback
        widget.metadata.onSeasonChange = (int seasonNumber) async {
          // This will be called from the player when user changes season
          // We don't need to implement the fetch here, it's handled in the player
        };
      }
    } catch (e) {
      // If fetching episodes fails, continue without them
      debugPrint('Failed to fetch season episodes: $e');
    }
  }
}
