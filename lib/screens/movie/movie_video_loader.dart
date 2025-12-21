// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/functions/video_utils.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
import 'package:flixquest/models/provider_video_source.dart';
import 'package:flixquest/models/provider_load_state.dart';
import 'package:flixquest/services/external_subtitle_service.dart';
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
import 'package:flixquest/constants/app_constants.dart'
    show MediaType, StreamRoute;

import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      required this.route,
      super.key});

  final bool download;
  final MovieStreamMetadata metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  RecentlyWatchedMoviesController recentlyWatchedMoviesController =
      RecentlyWatchedMoviesController();

  List<RegularVideoLinks>? movieVideoLinks;
  List<RegularSubtitleLinks>? movieVideoSubs;

  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  List<ProviderLoadState> providerStates = [];
  int currentProviderIndex = 0;
  bool isFetchingSubtitles = false;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  // Collect all working providers
  List<ProviderVideoSource> availableProviders = [];

  late int foundIndex;

  @override
  void initState() {
    super.initState();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());

    // Initialize provider states
    for (final provider in videoProviders) {
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
      // Fetch movie recommendations first
      await _fetchMovieRecommendations();

      var isBookmarked = await recentlyWatchedMoviesController
          .contain(widget.metadata.movieId!);
      int elapsed = 0;
      if (isBookmarked) {
        var rMovies =
            Provider.of<RecentProvider>(context, listen: false).movies;
        int index = rMovies
            .indexWhere((element) => element.id == widget.metadata.movieId);
        setState(() {
          elapsed = rMovies[index].elapsed!;
        });
        widget.metadata.elapsed = elapsed;
      } else {
        widget.metadata.elapsed = 0;
      }

      if (widget.metadata.releaseDate != null &&
          !isReleased(widget.metadata.releaseDate!)) {
        GlobalMethods.showScaffoldMessage(
            tr('movie_may_not_be_available'), context);
      }

      // Iterate through providers - stop at FIRST working provider for fast loading
      String? firstWorkingProviderCode;
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
          final result = await ProviderLoader.loadMovieFromProvider(
            providerCode: videoProviders[i].codeName,
            route: widget.route,
            movieId: widget.metadata.movieId!,
            movieName: widget.metadata.movieName!,
            releaseYear: widget.metadata.releaseYear?.toString(),
            consumetUrl: appDep.consumetUrl,
            newFlixHQUrl: appDep.newFlixHQUrl,
            flixApiUrl: appDep.flixApiUrl,
            newFlixhqServer: appDep.newFlixhqServer,
            streamingServerFlixHQ: appDep.streamingServerFlixHQ,
            gokuServer: appDep.gokuServer,
            sflixServer: appDep.sflixServer,
            himoviesServer: appDep.himoviesServer,
            animekaiServer: appDep.animekaiServer,
            hianimeServer: appDep.hianimeServer,
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
              });
            }

            // Store the first working provider code
            firstWorkingProviderCode = videoProviders[i].codeName;

            // Convert videos for this provider
            videos = VideoUtils.convertVideoLinksToMap(result.videoLinks!);
            movieVideoLinks = result.videoLinks;
            movieVideoSubs = result.subtitleLinks;

            // Process subtitles for this provider
            if (result.subtitleLinks != null &&
                result.subtitleLinks!.isNotEmpty) {
              final preferredLang = settings.defaultSubtitleLanguage;

              for (var subLink in result.subtitleLinks!) {
                final subLanguage = subLink.language ?? 'Unknown';
                // Check if this subtitle matches the user's preferred language
                final isPreferred = preferredLang.isNotEmpty &&
                    (subLanguage
                            .toLowerCase()
                            .startsWith(preferredLang.toLowerCase()) ||
                        subLanguage.toLowerCase() ==
                            preferredLang.toLowerCase() ||
                        // Also check for common English variants
                        (preferredLang.toLowerCase() == 'en' &&
                            (subLanguage == 'English' ||
                                subLanguage == 'English - English' ||
                                subLanguage == 'English - SDH' ||
                                subLanguage.startsWith('English'))));

                subs.add(
                  BetterPlayerSubtitlesSource(
                    type: BetterPlayerSubtitlesSourceType.network,
                    urls: [subLink.url ?? ''],
                    name: subLanguage,
                    selectedByDefault: isPreferred,
                  ),
                );
              }
            }

            // Stop at first working provider
            break;
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

      // Check if we found a working provider
      if (firstWorkingProviderCode == null && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr('movie_vid_404'),
                hideButton: false,
              );
            },
            context: context);
        return;
      }

      // Prepare final video map (reversed for quality ordering)
      Map<String, String> reversedVids =
          VideoUtils.reverseVideoQualityMap(videos);

      if (firstWorkingProviderCode != null && mounted) {
        final mixpanel =
            Provider.of<SettingsProvider>(context, listen: false).mixpanel;
        mixpanel.track('Most viewed movies', properties: {
          'Movie name': widget.metadata.movieName,
          'Movie id': widget.metadata.movieId,
          'Is Movie adult?': widget.metadata.isAdult ?? 'unknown',
        });

        // Navigate to player with provider list for lazy loading
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return PlayerOne(
                mediaType: MediaType.movie,
                sources: reversedVids,
                subs: subs,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.surface
                ],
                settings: settings,
                movieMetadata: widget.metadata,
                availableProviders:
                    videoProviders, // Pass provider list for lazy loading
                currentProviderCode:
                    firstWorkingProviderCode, // Current provider
                subtitleStyle:
                    Provider.of<SettingsProvider>(context).subtitleTextStyle,
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
                  error: tr('movie_vid_404'),
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
                error: "${tr("movie_vid_404")}\n$e",
                hideButton: false,
              );
            },
            context: context);
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
          additionalMessage:
              isFetchingSubtitles ? 'Fetching subtitles...' : null,
        ),
      ),
    );
  }

  Future<void> _processSubtitles(List<RegularSubtitleLinks> subtitles) async {
    final isProxyEnabled =
        Provider.of<SettingsProvider>(context, listen: false).enableProxy;
    final appDep = Provider.of<AppDependencyProvider>(context, listen: false);

    try {
      if (!appDep.fetchSubtitles) {
        return;
      }

      if (mounted) {
        setState(() {
          isFetchingSubtitles = true;
        });
      }

      // Use the VideoUtils.parseSubtitles method
      final parsedSubs = await VideoUtils.parseSubtitles(
        subtitles: subtitles,
        defaultLanguage: settings.defaultSubtitleLanguage,
        fetchAllLanguages: settings.fetchSpecificLangSubs,
        getVttContent: (url) => getVttFileAsString(url),
      );

      if (mounted) {
        setState(() {
          subs.addAll(parsedSubs);
        });
      }

      // Handle external subtitles if needed - using new Wyzie Subs API
      if (parsedSubs.isEmpty && appDep.useExternalSubtitles) {
        try {
          // Fetch subtitles using TMDB ID directly (no need for IMDB ID)
          final externalSubs =
              await ExternalSubtitleService.fetchMovieSubtitles(
            widget.metadata.movieId!,
          );

          // Find a subtitle matching the user's preferred language
          if (externalSubs.isNotEmpty) {
            // Try to find a subtitle in the user's preferred language
            var preferredSub = externalSubs.firstWhere(
              (sub) => sub.language == settings.defaultSubtitleLanguage,
              orElse: () => externalSubs.first,
            );

            // Download and add the subtitle
            final betterPlayerSource =
                await ExternalSubtitleService.convertToBetterPlayerSource(
              preferredSub,
            );
            subs.add(betterPlayerSource);
          }
        } catch (e) {
          debugPrint('Error fetching external subtitles: $e');
        }
      }
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerGeneral(e, context);
    } finally {
      if (mounted) {
        setState(() {
          isFetchingSubtitles = false;
        });
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

  Future<void> _fetchMovieRecommendations() async {
    try {
      if (widget.metadata.movieId != null) {
        final isProxyEnabled =
            Provider.of<SettingsProvider>(context, listen: false).enableProxy;
        final proxyUrl =
            Provider.of<AppDependencyProvider>(context, listen: false)
                .tmdbProxy;

        // Fetch movie recommendations
        await fetchMovies(
          Endpoints.getMovieRecommendations(
              widget.metadata.movieId!, 1, settings.appLanguage),
          isProxyEnabled,
          proxyUrl,
        ).then((movies) {
          debugPrint('Fetched ${movies.length} movie recommendations');
          if (movies.isNotEmpty) {
            setState(() {
              // Get top 10 recommendations
              final topRecommendations = movies.take(10).toList();
              widget.metadata.recommendations = topRecommendations
                  .map((movie) => MovieRecommendation.fromMovie(movie))
                  .toList();
              debugPrint(
                  'Set ${widget.metadata.recommendations?.length} recommendations in metadata');
            });
          }
        });

        // Set the movie change callback
        widget.metadata.onMovieChange = (int movieId) async {
          // This will be called from the player when user selects a movie
        };
      }
    } catch (e) {
      // If fetching recommendations fails, continue without them
      debugPrint('Failed to fetch movie recommendations: $e');
    }
  }
}
