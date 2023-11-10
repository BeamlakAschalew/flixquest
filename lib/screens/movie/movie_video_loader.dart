// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:startapp_sdk/startapp.dart';
import '/api/endpoints.dart';
import '/functions/network.dart';
import '/models/movie_stream.dart';
import '/provider/app_dependency_provider.dart';
import '/provider/settings_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import '../../models/sub_languages.dart';
import '../../widgets/common_widgets.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      required this.route,
      Key? key})
      : super(key: key);

  final bool download;
  final List metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<MovieResults>? movies;
  List<MovieEpisodes>? epi;
  MovieVideoSources? movieVideoSources;
  List<MovieVideoLinks>? movieVideoLinks;
  List<MovieVideoSubtitles>? movieVideoSubs;
  List<TMAVideoSources>? tmaVideoSources;
  List<TMASubtitleSources>? tmaSubtitleSources;

  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);

  /// TMDB Route
  MovieInfoTMDBRoute? episode;

  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();

    if (appDep.enableADS) {
      loadInterstitialAd();
    }
    loadVideo();
  }

  Future<void> loadInterstitialAd() async {
    startAppSdk.loadInterstitialAd().then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
    });
  }

  String processVttFileTimestamps(String vttFile) {
    final lines = vttFile.split('\n');
    final processedLines = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('-->') && line.trim().length == 23) {
        String endTimeModifiedString =
            '${line.trim().substring(0, line.trim().length - 9)}00:${line.trim().substring(line.trim().length - 9)}';
        String finalStr = '00:$endTimeModifiedString';
        processedLines.add(finalStr);
      } else {
        processedLines.add(line);
      }
    }

    return processedLines.join('\n');
  }

  void loadVideo() async {
    try {
      if (widget.route == StreamRoute.flixHQ) {
        debugPrint("USED FLIXHQ ROUTE");
        await fetchMoviesForStream(Endpoints.searchMovieTVForStream(
                removeCharacters(widget.metadata.elementAt(1)),
                appDep.consumetUrl))
            .then((value) async {
          if (mounted) {
            setState(() {
              movies = value;
            });
            if (movies == null || movies!.isEmpty) {
              Navigator.pop(context);
              showModalBottomSheet(
                  builder: (context) {
                    return ReportErrorWidget(
                      error: tr("movie_vid_404"),
                      hideButton: true,
                    );
                  },
                  context: context);
            }
          }

          for (int i = 0; i < movies!.length; i++) {
            if (movies![i].releaseDate ==
                    widget.metadata.elementAt(3).toString() &&
                movies![i].type == 'Movie') {
              await getMovieStreamEpisodes(Endpoints.getMovieTVStreamInfo(
                      movies![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  epi = value;
                });
                if (epi != null && epi!.isNotEmpty) {
                  await getMovieStreamLinksAndSubs(
                          Endpoints.getMovieTVStreamLinks(
                              epi![0].id!,
                              movies![i].id!,
                              appDep.consumetUrl,
                              appDep.streamingServer))
                      .then((value) {
                    if (mounted) {
                      if (value.messageExists == null &&
                          value.videoLinks != null &&
                          value.videoLinks!.isNotEmpty) {
                        setState(() {
                          movieVideoSources = value;
                        });
                      } else if (value.messageExists != null) {
                        Navigator.pop(context);
                        showModalBottomSheet(
                            builder: (context) {
                              return ReportErrorWidget(
                                error: tr("movie_vid_server_error"),
                                hideButton: false,
                              );
                            },
                            context: context);
                      }
                    }
                    if (mounted) {
                      movieVideoLinks = movieVideoSources!.videoLinks;
                      movieVideoSubs = movieVideoSources!.videoSubtitles;
                    }
                  });
                }
              });

              break;
            }
          }
          if (movieVideoLinks == null || movieVideoLinks!.isEmpty) {
            Navigator.pop(context);
            showModalBottomSheet(
                builder: (context) {
                  return ReportErrorWidget(
                    error: tr("movie_vid_404"),
                    hideButton: true,
                  );
                },
                context: context);
          }
        });
      } else {
        debugPrint("USED TMDB ROUTE");
        await getMovieStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
                widget.metadata.elementAt(0).toString(),
                "movie",
                appDep.consumetUrl))
            .then((value) async {
          if (mounted) {
            setState(() {
              episode = value;
            });
          }

          if (episode != null &&
              episode!.id != null &&
              episode!.id!.isNotEmpty &&
              episode!.episodeId != null &&
              episode!.episodeId!.isNotEmpty) {
            await getMovieStreamLinksAndSubs(
                    Endpoints.getMovieTVStreamLinksTMDB(
                        appDep.consumetUrl,
                        episode!.episodeId!,
                        episode!.id!,
                        appDep.streamingServer))
                .then((value) {
              if (mounted) {
                if (value.messageExists == null &&
                    value.videoLinks != null &&
                    value.videoLinks!.isNotEmpty) {
                  setState(() {
                    movieVideoSources = value;
                  });
                } else if (value.messageExists != null) {
                  Navigator.pop(context);
                  showModalBottomSheet(
                      builder: (context) {
                        return ReportErrorWidget(
                          error: tr("movie_vid_server_error"),
                          hideButton: false,
                        );
                      },
                      context: context);
                }
              }
              if (mounted) {
                movieVideoLinks = movieVideoSources!.videoLinks;
                movieVideoSubs = movieVideoSources!.videoSubtitles;
              }
            });
          } else {
            if (mounted) {
              Navigator.pop(context);
              showModalBottomSheet(
                  builder: (context) {
                    return ReportErrorWidget(
                      error: tr("movie_vid_404"),
                      hideButton: true,
                    );
                  },
                  context: context);
            }
          }
        });
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      late int foundIndex;

      for (int i = 0; i < supportedLanguages.length; i++) {
        if (supportedLanguages[i].languageCode ==
            settings.defaultSubtitleLanguage) {
          foundIndex = i;
          break;
        }
      }

      if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
        if (supportedLanguages[foundIndex].englishName == '') {
          for (int i = 0; i < movieVideoSubs!.length - 1; i++) {
            if (mounted) {
              setState(() {
                loadProgress = (i / movieVideoSubs!.length) * 100;
              });
            }
            await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs![i].language!,
                    selectedByDefault: movieVideoSubs![i].language ==
                            'English' ||
                        movieVideoSubs![i].language == 'English - English' ||
                        movieVideoSubs![i].language == 'English - SDH' ||
                        movieVideoSubs![i].language == 'English 1' ||
                        movieVideoSubs![i].language == 'English - English [CC]',
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (movieVideoSubs!
              .where((element) => element.language!
                  .startsWith(supportedLanguages[foundIndex].englishName))
              .isNotEmpty) {
            if (settings.fetchSpecificLangSubs) {
              for (int i = 0; i < movieVideoSubs!.length; i++) {
                if (movieVideoSubs![i]
                    .language!
                    .startsWith(supportedLanguages[foundIndex].englishName)) {
                  await getVttFileAsString(movieVideoSubs![i].url!)
                      .then((value) {
                    subs.add(
                      BetterPlayerSubtitlesSource(
                          name: movieVideoSubs![i].language,
                          selectedByDefault: true,
                          content: processVttFileTimestamps(value),
                          type: BetterPlayerSubtitlesSourceType.memory),
                    );
                  });
                }
              }
            } else {
              await getVttFileAsString((movieVideoSubs!.where((element) =>
                          element.language!.startsWith(
                              supportedLanguages[foundIndex].englishName)))
                      .first
                      .url!)
                  .then((value) {
                subs.addAll({
                  BetterPlayerSubtitlesSource(
                      name: movieVideoSubs!
                          .where((element) => element.language!.startsWith(
                              supportedLanguages[foundIndex].englishName))
                          .first
                          .language,
                      //  urls: [movieVideoSubs![i].url],
                      selectedByDefault: true,
                      content: processVttFileTimestamps(value),
                      type: BetterPlayerSubtitlesSourceType.memory),
                });
              });
            }
          } else {
            if (appDep.useExternalSubtitles) {
              await fetchSocialLinks(
                Endpoints.getExternalLinksForMovie(
                    widget.metadata.elementAt(0), "en"),
              ).then((value) async {
                if (value.imdbId != null) {
                  await getExternalSubtitle(
                          Endpoints.searchExternalMovieSubtitles(value.imdbId!,
                              supportedLanguages[foundIndex].languageCode),
                          appDep.opensubtitlesKey)
                      .then((value) async {
                    if (value.isNotEmpty &&
                        value[0].attr!.files![0].fileId != null) {
                      await downloadExternalSubtitle(
                              Endpoints.externalSubtitleDownload(),
                              value[0].attr!.files![0].fileId!,
                              appDep.opensubtitlesKey)
                          .then((value) async {
                        if (value.link != null) {
                          subs.addAll({
                            BetterPlayerSubtitlesSource(
                                name:
                                    supportedLanguages[foundIndex].englishName,
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
          }
        }
      }
      if (movieVideoLinks != null) {
        for (int k = 0; k < movieVideoLinks!.length; k++) {
          videos.addAll({
            movieVideoLinks![k].quality!: movieVideoLinks![k].url!,
          });
        }
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (movieVideoLinks != null && mounted) {
        if (interstitialAd != null) {
          interstitialAd!.show();
          loadInterstitialAd().whenComplete(
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return PlayerOne(
                          mediaType: MediaType.movie,
                          sources: reversedVids,
                          subs: subs,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.background
                          ],
                          settings: settings,
                          movieMetadata: widget.metadata);
                    },
                  )));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return PlayerOne(
                  mediaType: MediaType.movie,
                  sources: reversedVids,
                  subs: subs,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.background
                  ],
                  settings: settings,
                  movieMetadata: widget.metadata);
            },
          ));
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("movie_vid_404"),
                  hideButton: true,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            height: 120,
            width: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 65,
                  width: 65,
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(width: 160, child: LinearProgressIndicator()),
                Visibility(
                  visible:
                      settings.defaultSubtitleLanguage != '' ? false : true,
                  child: Text(
                    '${loadProgress.toStringAsFixed(0).toString()}%',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
