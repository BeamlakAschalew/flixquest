// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/models/movie_stream_metadata.dart';
import 'package:flixquest/video_providers/flixhq.dart';
import 'package:startapp_sdk/startapp.dart';
import '../../video_providers/common.dart';
import '../../video_providers/names.dart';
import '../../video_providers/zoro.dart';
import '/api/endpoints.dart';
import '/functions/network.dart';
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
import '../../video_providers/superstream.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download,
      required this.metadata,
      required this.route,
      Key? key})
      : super(key: key);

  final bool download;
  final MovieStreamMetadata metadata;
  final StreamRoute route;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<FlixHQMovieSearchEntry>? fqMovies;
  List<FlixHQMovieInfoEntries>? fqEpi;
  List<DCVASearchEntry>? dcMovies;
  List<DCVAInfoEntries>? dcEpi;
  List<DCVASearchEntry>? vaMovies;
  List<DCVAInfoEntries>? vaEpi;
  List<ZoroSearchEntry>? zoroMovies;
  List<ZoroInfoEntries>? zoroEpi;

  FlixHQStreamSources? fqMovieVideoSources;
  SuperstreamStreamSources? superstreamVideoSources;
  DCVAStreamSources? dramacoolVideoSources;
  DCVAStreamSources? viewasianVideoSources;
  ZoroStreamSources? zoroVideoSources;
  List<RegularVideoLinks>? movieVideoLinks;
  List<RegularSubtitleLinks>? movieVideoSubs;

  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  /// TMDB Route
  FlixHQMovieInfoTMDBRoute? episode;

  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  late int foundIndex;
  late String currentProvider;

  @override
  void initState() {
    super.initState();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());
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

  void loadVideo() async {
    try {
      for (int i = 0; i < videoProviders.length; i++) {
        if (mounted) {
          setState(() {
            currentProvider = videoProviders[i].fullName;
          });
        }
        if (videoProviders[i].codeName == 'flixhq') {
          if (widget.route == StreamRoute.flixHQ) {
            await loadFlixHQNormalRoute();
            if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(movieVideoSubs!);
              break;
            }
            if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
              break;
            }
          } else {
            await loadFlixHQTMDBRoute();
            if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(movieVideoSubs!);
              break;
            }
            if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
              break;
            }
          }
        } else if (videoProviders[i].codeName == 'superstream') {
          await loadSuperstream();
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(movieVideoSubs!);
            break;
          }
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'dramacool') {
          await loadDramacool();
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(movieVideoSubs!);
            break;
          }
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'viewasian') {
          await loadViewasian();
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(movieVideoSubs!);
            break;
          }
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'zoro') {
          await loadZoro();
          if (movieVideoSubs != null && movieVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(movieVideoSubs!);
            break;
          }
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            break;
          }
        }
      }

      if ((movieVideoLinks == null || movieVideoLinks!.isEmpty) && mounted) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onBackground,
            ),
            height: 150,
            width: 190,
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
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(fontSize: 15),
                        children: [
                      TextSpan(
                          text: 'Fetching: ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.background,
                              fontFamily: 'Poppins')),
                      TextSpan(
                          text: currentProvider,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontFamily: 'PoppinsBold',
                          ))
                    ])),
                Visibility(
                  visible:
                      settings.defaultSubtitleLanguage != '' ? false : true,
                  child: Text(
                    'Subtitle load progress: ${loadProgress.toStringAsFixed(0).toString()}%',
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

  void convertVideoLinks(List<RegularVideoLinks> vids) {
    for (int k = 0; k < vids.length; k++) {
      if (vids[k].quality! == 'unknown quality') {
        videos.addAll({
          "${vids[k].quality!} $k": vids[k].url!,
        });
      } else {
        videos.addAll({
          vids[k].quality!: vids[k].url!,
        });
      }
    }
  }

  Future<void> subtitleParserFetcher(
      List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();
    if (subtitles.isNotEmpty) {
      if (supportedLanguages[foundIndex].englishName == '') {
        for (int i = 0; i < subtitles.length - 1; i++) {
          if (mounted) {
            setState(() {
              loadProgress = (i / subtitles.length) * 100;
            });
          }
          await getVttFileAsString(subtitles[i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: subtitles[i].language!,
                  selectedByDefault: subtitles[i].language == 'English' ||
                      subtitles[i].language == 'English - English' ||
                      subtitles[i].language == 'English - SDH' ||
                      subtitles[i].language == 'English 1' ||
                      subtitles[i].language == 'English - English [CC]' ||
                      subtitles[i].language == 'en',
                  content: subtitles[i].url!.endsWith('srt')
                      ? value
                      : processVttFileTimestamps(value),
                  type: BetterPlayerSubtitlesSourceType.memory),
            });
          });
        }
      } else {
        if (subtitles
                .where((element) => element.language!
                    .startsWith(supportedLanguages[foundIndex].englishName))
                .isNotEmpty ||
            subtitles
                .where((element) =>
                    element.language ==
                    supportedLanguages[foundIndex].languageCode)
                .isNotEmpty) {
          if (settings.fetchSpecificLangSubs) {
            for (int i = 0; i < subtitles.length; i++) {
              if (subtitles[i]
                      .language!
                      .startsWith(supportedLanguages[foundIndex].englishName) ||
                  subtitles[i].language! ==
                      supportedLanguages[foundIndex].languageCode) {
                await getVttFileAsString(subtitles[i].url!).then((value) {
                  subs.add(
                    BetterPlayerSubtitlesSource(
                        name: subtitles[i].language,
                        selectedByDefault: true,
                        content: processVttFileTimestamps(value),
                        type: BetterPlayerSubtitlesSourceType.memory),
                  );
                });
              }
            }
          } else {
            await getVttFileAsString((subtitles.where((element) =>
                        element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName) ||
                        element.language! ==
                            supportedLanguages[foundIndex].languageCode))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: subtitles
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
                  widget.metadata.movieId!, "en"),
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
        }
      }
    }
  }

  Future<void> loadFlixHQTMDBRoute() async {
    if (mounted) {
      await getMovieStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
              widget.metadata.movieId!.toString(), "movie", appDep.consumetUrl))
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
          await getMovieStreamLinksAndSubsFlixHQ(
                  Endpoints.getMovieTVStreamLinksTMDB(
                      appDep.consumetUrl,
                      episode!.episodeId!,
                      episode!.id!,
                      appDep.streamingServerFlixHQ))
              .then((value) {
            if (mounted) {
              if (value.messageExists == null &&
                  value.videoLinks != null &&
                  value.videoLinks!.isNotEmpty) {
                setState(() {
                  fqMovieVideoSources = value;
                });
              } else if (value.messageExists != null ||
                  value.videoLinks == null ||
                  value.videoLinks!.isEmpty) {
                return;
              }
            }
            if (mounted) {
              movieVideoLinks = fqMovieVideoSources!.videoLinks;
              movieVideoSubs = fqMovieVideoSources!.videoSubtitles;
              if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
                convertVideoLinks(movieVideoLinks!);
              }
            }
          });
        }
      });
    }
  }

  Future<void> loadDramacool() async {
    if (mounted) {
      await fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamDramacool(
              removeCharacters(widget.metadata.movieName!).toLowerCase(),
              appDep.consumetUrl))
          .then((value) async {
        if (mounted) {
          setState(() {
            dcMovies = value;
          });
        }

        if (dcMovies == null || dcMovies!.isEmpty) {
          return;
        }

        for (int i = 0; i < dcMovies!.length; i++) {
          if (removeCharacters(dcMovies![i].title!).toLowerCase().contains(
                  removeCharacters(widget.metadata.movieName!.toString())
                      .toLowerCase()) ||
              dcMovies![i]
                  .title!
                  .contains(widget.metadata.movieName!.toString())) {
            await getMovieTVStreamEpisodesDCVA(
                    Endpoints.getMovieTVStreamInfoDramacool(
                        dcMovies![i].id!, appDep.consumetUrl))
                .then((value) async {
              setState(() {
                dcEpi = value;
              });
              if (dcMovies != null && dcMovies!.isNotEmpty) {
                await getMovieTVStreamLinksAndSubsDCVA(
                        Endpoints.getMovieTVStreamLinksDramacool(
                            dcEpi![0].id!,
                            dcMovies![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServerDCVA))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        dramacoolVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    movieVideoLinks = dramacoolVideoSources!.videoLinks;
                    movieVideoSubs = dramacoolVideoSources!.videoSubtitles;
                    if (movieVideoLinks != null &&
                        movieVideoLinks!.isNotEmpty) {
                      convertVideoLinks(movieVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }

  Future<void> loadViewasian() async {
    if (mounted) {
      await fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamViewasian(
              removeCharacters(widget.metadata.movieName!).toLowerCase(),
              appDep.consumetUrl))
          .then((value) async {
        if (mounted) {
          setState(() {
            vaMovies = value;
          });
        }

        if (vaMovies == null || vaMovies!.isEmpty) {
          return;
        }

        for (int i = 0; i < vaMovies!.length; i++) {
          if (removeCharacters(vaMovies![i].title!).toLowerCase().contains(
                  removeCharacters(widget.metadata.movieName!.toString())
                      .toLowerCase()) ||
              vaMovies![i]
                  .title!
                  .contains(widget.metadata.movieName!.toString())) {
            await getMovieTVStreamEpisodesDCVA(
                    Endpoints.getMovieTVStreamInfoViewasian(
                        vaMovies![i].id!, appDep.consumetUrl))
                .then((value) async {
              setState(() {
                vaEpi = value;
              });
              if (vaMovies != null && vaMovies!.isNotEmpty) {
                await getMovieTVStreamLinksAndSubsDCVA(
                        Endpoints.getMovieTVStreamLinksViewasian(
                            vaEpi![0].id!,
                            vaMovies![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServerDCVA))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        viewasianVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    movieVideoLinks = viewasianVideoSources!.videoLinks;
                    movieVideoSubs = viewasianVideoSources!.videoSubtitles;
                    if (movieVideoLinks != null &&
                        movieVideoLinks!.isNotEmpty) {
                      convertVideoLinks(movieVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }

  Future<void> loadFlixHQNormalRoute() async {
    if (mounted) {
      await fetchMoviesForStreamFlixHQ(Endpoints.searchMovieTVForStreamFlixHQ(
              removeCharacters(widget.metadata.movieName!).toLowerCase(),
              appDep.consumetUrl))
          .then((value) async {
        if (mounted) {
          setState(() {
            fqMovies = value;
          });
        }

        if (fqMovies == null || fqMovies!.isEmpty) {
          return;
        }

        for (int i = 0; i < fqMovies!.length; i++) {
          if (fqMovies![i].releaseDate ==
                  widget.metadata.releaseYear!.toString() &&
              fqMovies![i].type == 'Movie' &&
              (removeCharacters(fqMovies![i].title!).toLowerCase().contains(
                      removeCharacters(widget.metadata.movieName.toString())
                          .toLowerCase()) ||
                  fqMovies![i]
                      .title!
                      .contains(widget.metadata.movieName!.toString()))) {
            await getMovieStreamEpisodesFlixHQ(
                    Endpoints.getMovieTVStreamInfoFlixHQ(
                        fqMovies![i].id!, appDep.consumetUrl))
                .then((value) async {
              setState(() {
                fqEpi = value;
              });
              if (fqEpi != null && fqEpi!.isNotEmpty) {
                await getMovieStreamLinksAndSubsFlixHQ(
                        Endpoints.getMovieTVStreamLinksFlixHQ(
                            fqEpi![0].id!,
                            fqMovies![i].id!,
                            appDep.consumetUrl,
                            appDep.streamingServerFlixHQ))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        fqMovieVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    movieVideoLinks = fqMovieVideoSources!.videoLinks;
                    movieVideoSubs = fqMovieVideoSources!.videoSubtitles;
                    if (movieVideoLinks != null &&
                        movieVideoLinks!.isNotEmpty) {
                      convertVideoLinks(movieVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }

  Future<void> loadSuperstream() async {
    if (mounted) {
      await getSuperstreamStreamingLinks(Endpoints.getSuperstreamStreamMovie(
              appDep.flixquestAPIURL, widget.metadata.movieId!))
          .then((value) {
        if (mounted) {
          if (value.messageExists == null &&
              value.videoLinks != null &&
              value.videoLinks!.isNotEmpty) {
            setState(() {
              superstreamVideoSources = value;
            });
          } else if (value.messageExists != null ||
              value.videoLinks == null ||
              value.videoLinks!.isEmpty) {
            return;
          }
        }
        if (mounted) {
          movieVideoLinks = superstreamVideoSources!.videoLinks;
          movieVideoSubs = superstreamVideoSources!.videoSubtitles;
          if (movieVideoLinks != null && movieVideoLinks!.isNotEmpty) {
            convertVideoLinks(movieVideoLinks!);
          }
        }
      });
    }
  }

  Future<void> loadZoro() async {
    if (mounted) {
      await fetchMovieTVForStreamZoro(Endpoints.searchZoroMoviesTV(
        appDep.consumetUrl,
        removeCharacters(widget.metadata.movieName!).toLowerCase(),
      )).then((value) async {
        if (mounted) {
          setState(() {
            zoroMovies = value;
          });
        }

        if (zoroMovies == null || zoroMovies!.isEmpty) {
          return;
        }

        for (int i = 0; i < zoroMovies!.length; i++) {
          if ((removeCharacters(zoroMovies![i].title!).toLowerCase().contains(
                      widget.metadata.movieName!.toString().toLowerCase()) ||
                  zoroMovies![i]
                      .title!
                      .contains(widget.metadata.movieName!.toString())) &&
              zoroMovies![i].type == 'MOVIE') {
            await getMovieTVStreamEpisodesZoro(Endpoints.getMovieTVInfoZoro(
                    appDep.consumetUrl, zoroMovies![i].id!))
                .then((value) async {
              setState(() {
                zoroEpi = value;
              });
              if (zoroMovies != null && zoroMovies!.isNotEmpty) {
                await getMovieTVStreamLinksAndSubsZoro(
                        Endpoints.getMovieTVStreamLinksZoro(appDep.consumetUrl,
                            zoroEpi![0].id!, appDep.streamingServerFlixHQ))
                    .then((value) {
                  if (mounted) {
                    if (value.messageExists == null &&
                        value.videoLinks != null &&
                        value.videoLinks!.isNotEmpty) {
                      setState(() {
                        zoroVideoSources = value;
                      });
                    } else if (value.messageExists != null ||
                        value.videoLinks == null ||
                        value.videoLinks!.isEmpty) {
                      return;
                    }
                  }
                  if (mounted) {
                    movieVideoLinks = zoroVideoSources!.videoLinks;
                    movieVideoSubs = zoroVideoSources!.videoSubtitles;
                    if (movieVideoLinks != null &&
                        movieVideoLinks!.isNotEmpty) {
                      convertVideoLinks(movieVideoLinks!);
                    }
                  }
                });
              }
            });

            break;
          }
        }
      });
    }
  }
}
