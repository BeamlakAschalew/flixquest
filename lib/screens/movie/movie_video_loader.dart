// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/functions/network.dart';
import 'package:flixquest/functions/video_utils.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
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
                movieVideoLinks = result.videoLinks;
                movieVideoSubs = result.subtitleLinks;
              });
            }

            // Convert and process videos
            videos = VideoUtils.convertVideoLinksToMap(movieVideoLinks!);

            // Process subtitles if available
            if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
              await _processSubtitles(movieVideoSubs!);
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
      if ((movieVideoLinks == null || movieVideoLinks!.isEmpty) && mounted) {
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

      if (movieVideoLinks != null && mounted) {
        final mixpanel =
            Provider.of<SettingsProvider>(context, listen: false).mixpanel;
        mixpanel.track('Most viewed movies', properties: {
          'Movie name': widget.metadata.movieName,
          'Movie id': widget.metadata.movieId,
          'Is Movie adult?': widget.metadata.isAdult ?? 'unknown',
        });

        // Navigate to player
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
    getAppLanguage();
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
          Endpoints.getExternalLinksForMovie(
              widget.metadata.movieId!, settings.appLanguage),
          isProxyEnabled,
          appDep.tmdbProxy,
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
