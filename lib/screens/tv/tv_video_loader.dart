// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/video_providers/superstream.dart';
import 'package:startapp_sdk/startapp.dart';
import '../../video_providers/common.dart';
import '../../video_providers/flixhq.dart';
import '../../video_providers/names.dart';
import '/api/endpoints.dart';
import '/functions/network.dart';
import '/widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import '../../models/sub_languages.dart';
import '../../provider/app_dependency_provider.dart';
import '../../provider/settings_provider.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.metadata,
      required this.download,
      required this.route,
      Key? key})
      : super(key: key);

  final List metadata;
  final bool download;
  final StreamRoute route;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  String route = 'viewasian';
  List<String> providers = ['dramacool', 'superstream', 'viewasian', 'flixhq'];
  List<FlixHQTVSearchEntry>? fqShows;
  List<FlixHQTVInfoEntries>? fqEpi;
  List<DCVASearchEntry>? dcShows;
  List<DCVAInfoEntries>? dcEpi;
  List<DCVASearchEntry>? vaShows;
  List<DCVAInfoEntries>? vaEpi;

  FlixHQStreamSources? fqTVVideoSources;
  SuperstreamStreamSources? superstreamVideoSources;
  DCVAStreamSources? dramacoolVideoSources;
  DCVAStreamSources? viewasianVideoSources;

  List<RegularVideoLinks>? tvVideoLinks;
  List<RegularSubtitleLinks>? tvVideoSubs;

  FlixHQTVInfo? tvInfo;
  double loadProgress = 0.00;
  late SettingsProvider settings =
      Provider.of<SettingsProvider>(context, listen: false);
  late AppDependencyProvider appDep =
      Provider.of<AppDependencyProvider>(context, listen: false);
  List<VideoProvider> videoProviders = [];
  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  /// TMDB Route
  FlixHQTVInfoTMDBRoute? tvInfoTMDB;

  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  late int foundIndex;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

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
        if (videoProviders[i].codeName == 'flixhq') {
          if (widget.route == StreamRoute.flixHQ) {
            await loadFlixHQNormalRoute();
            if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(tvVideoSubs!);
              break;
            }

            if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
              break;
            }
          } else {
            await loadFlixHQTMDBRoute();
            if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
              await subtitleParserFetcher(tvVideoSubs!);
              break;
            }
            if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
              break;
            }
          }
        } else if (videoProviders[i].codeName == 'superstream') {
          await loadSuperstream();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'dramacool') {
          await loadDramacool();
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'viewasian') {
          await loadViewasian();
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        }
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (tvVideoLinks != null && mounted) {
        if (interstitialAd != null) {
          interstitialAd!.show();
          loadInterstitialAd().whenComplete(
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return PlayerOne(
                          mediaType: MediaType.tvShow,
                          sources: reversedVids,
                          subs: subs,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.background
                          ],
                          settings: settings,
                          tvMetadata: widget.metadata);
                    },
                  )));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return PlayerOne(
                  mediaType: MediaType.tvShow,
                  sources: reversedVids,
                  subs: subs,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.background
                  ],
                  settings: settings,
                  tvMetadata: widget.metadata);
            },
          ));
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showModalBottomSheet(
              builder: (context) {
                return ReportErrorWidget(
                  error: tr("tv_vid_404"),
                  hideButton: true,
                );
              },
              context: context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       tr("tv_vid_404"),
          //       maxLines: 3,
          //       style: kTextSmallBodyStyle,
          //     ),
          //     duration: const Duration(seconds: 3),
          //   ),
          // );
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

  Future<void> loadDramacool() async {
    await fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamDramacool(
                removeCharacters(widget.metadata.elementAt(1)),
                appDep.consumetUrl)
            .toLowerCase())
        .then((value) async {
      if (mounted) {
        setState(() {
          dcShows = value;
        });
      }

      if (dcShows == null || dcShows!.isEmpty) {
        return;
      }

      for (int i = 0; i < dcShows!.length; i++) {
        if (dcShows![i]
            .title!
            .toLowerCase()
            .contains(widget.metadata.elementAt(1).toString().toLowerCase())) {
          await getMovieTVStreamEpisodesDCVA(
                  Endpoints.getMovieTVStreamInfoDramacool(
                      dcShows![i].id!, appDep.consumetUrl))
              .then((value) async {
            setState(() {
              dcEpi = value;
            });
            if (dcShows != null && dcShows!.isNotEmpty) {
              await getMovieTVStreamLinksAndSubsDCVA(
                      Endpoints.getMovieTVStreamLinksDramacool(
                          dcEpi!
                              .where((element) =>
                                  element.episode ==
                                  widget.metadata.elementAt(3).toString())
                              .first
                              .id!,
                          dcShows![i].id!,
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
                  tvVideoLinks = dramacoolVideoSources!.videoLinks;
                  tvVideoSubs = dramacoolVideoSources!.videoSubtitles;
                  if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                    convertVideoLinks(tvVideoLinks!);
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

  Future<void> loadSuperstream() async {
    await getSuperstreamStreamingLinks(Endpoints.getSuperstreamStreamTV(
            'https://flixquest-api.vercel.app/',
            widget.metadata.elementAt(7),
            widget.metadata.elementAt(4),
            widget.metadata.elementAt(3)))
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
        tvVideoLinks = superstreamVideoSources!.videoLinks;
        tvVideoSubs = superstreamVideoSources!.videoSubtitles;
        if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
          convertVideoLinks(tvVideoLinks!);
        }
      }
    });
  }

  Future<void> loadFlixHQNormalRoute() async {
    late int totalSeasons;
    await fetchTVDetails(
            Endpoints.tvDetailsUrl(widget.metadata.elementAt(7), "en"))
        .then(
      (value) async {
        totalSeasons = value.numberOfSeasons!;
        await fetchTVForStreamFlixHQ(Endpoints.searchMovieTVForStreamFlixHQ(
                removeCharacters(widget.metadata.elementAt(1)).toLowerCase(),
                appDep.consumetUrl))
            .then((value) async {
          if (mounted) {
            setState(() {
              fqShows = value;
            });
          }
          if (fqShows == null || fqShows!.isEmpty) {
            return;
          }
          for (int i = 0; i < fqShows!.length; i++) {
            if (fqShows![i].seasons == totalSeasons &&
                fqShows![i].type == 'TV Series' &&
                fqShows![i].title!.toLowerCase().contains(
                    widget.metadata.elementAt(1).toString().toLowerCase())) {
              await getTVStreamEpisodesFlixHQ(
                      Endpoints.getMovieTVStreamInfoFlixHQ(
                          fqShows![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  tvInfo = value;
                  fqEpi = tvInfo!.episodes;
                });

                for (int k = 0; k < fqEpi!.length; k++) {
                  if (fqEpi![k].episode == widget.metadata.elementAt(3) &&
                      fqEpi![k].season == widget.metadata.elementAt(4)) {
                    await getTVStreamLinksAndSubsFlixHQ(
                            Endpoints.getMovieTVStreamLinksFlixHQ(
                                fqEpi![k].id!,
                                fqShows![i].id!,
                                appDep.consumetUrl,
                                appDep.streamingServerFlixHQ))
                        .then((value) {
                      if (value.messageExists == null &&
                          value.videoLinks != null &&
                          value.videoLinks!.isNotEmpty) {
                        if (mounted) {
                          setState(() {
                            fqTVVideoSources = value;
                          });
                        }
                      } else if (value.messageExists != null ||
                          value.videoLinks == null ||
                          value.videoLinks!.isEmpty) {
                        return;
                      }
                      if (mounted) {
                        tvVideoLinks = fqTVVideoSources!.videoLinks;
                        tvVideoSubs = fqTVVideoSources!.videoSubtitles;
                        if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                          convertVideoLinks(tvVideoLinks!);
                        }
                      }
                    });
                    break;
                  }
                }
              });

              break;
            }

            if (fqShows![i].seasons == (totalSeasons - 1) &&
                fqShows![i].type == 'TV Series') {
              await getTVStreamEpisodesFlixHQ(
                      Endpoints.getMovieTVStreamInfoFlixHQ(
                          fqShows![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  tvInfo = value;
                  fqEpi = tvInfo!.episodes;
                });

                for (int k = 0; k < fqEpi!.length; k++) {
                  if (fqEpi![k].episode == widget.metadata.elementAt(3) &&
                      fqEpi![k].season == widget.metadata.elementAt(4)) {
                    await getTVStreamLinksAndSubsFlixHQ(
                            Endpoints.getMovieTVStreamLinksFlixHQ(
                                fqEpi![k].id!,
                                fqShows![i].id!,
                                appDep.consumetUrl,
                                appDep.streamingServerFlixHQ))
                        .then((value) {
                      setState(() {
                        fqTVVideoSources = value;
                      });
                      if (mounted) {
                        tvVideoLinks = fqTVVideoSources!.videoLinks;
                        tvVideoSubs = fqTVVideoSources!.videoSubtitles;
                        if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                          convertVideoLinks(tvVideoLinks!);
                        }
                      }
                    });
                    break;
                  }
                }
              });

              break;
            }
          }
        });
      },
    );
  }

  Future<void> loadFlixHQTMDBRoute() async {
    await getTVStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
            widget.metadata.elementAt(7).toString(), "tv", appDep.consumetUrl))
        .then((value) async {
      setState(() {
        tvInfoTMDB = value;
      });
      if (widget.metadata.elementAt(4) != 0) {
        if (tvInfoTMDB!.id != null &&
            tvInfoTMDB!.seasons != null &&
            tvInfoTMDB!.seasons![widget.metadata.elementAt(4) - 1]
                    .episodes![widget.metadata.elementAt(3) - 1].id !=
                null) {
          await getTVStreamLinksAndSubsFlixHQ(
                  Endpoints.getMovieTVStreamLinksTMDB(
                      appDep.consumetUrl,
                      tvInfoTMDB!.seasons![widget.metadata.elementAt(4) - 1]
                          .episodes![widget.metadata.elementAt(3) - 1].id!,
                      tvInfoTMDB!.id!,
                      appDep.streamingServerFlixHQ))
              .then((value) {
            if (value.messageExists == null &&
                value.videoLinks != null &&
                value.videoLinks!.isNotEmpty) {
              if (mounted) {
                setState(() {
                  fqTVVideoSources = value;
                });
              }
            } else if (value.messageExists != null ||
                value.videoLinks == null ||
                value.videoLinks!.isEmpty) {
              return;
            }
            if (mounted) {
              tvVideoLinks = fqTVVideoSources!.videoLinks;
              tvVideoSubs = fqTVVideoSources!.videoSubtitles;
              if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                convertVideoLinks(tvVideoLinks!);
              }
            }
          });
        }
      }
    });
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

  Future<void> subtitleParserFetcher(
      List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();
    if (subtitles.isNotEmpty) {
      if (supportedLanguages[foundIndex].englishName == '') {
        for (int i = 0; i < subtitles.length - 1; i++) {
          setState(() {
            loadProgress = (i / subtitles.length) * 100;
          });
          await getVttFileAsString(subtitles[i].url!).then((value) {
            subs.addAll({
              BetterPlayerSubtitlesSource(
                  name: subtitles[i].language!,
                  content: processVttFileTimestamps(value),
                  selectedByDefault: subtitles[i].language == 'English' ||
                          subtitles[i].language == 'English - English' ||
                          subtitles[i].language == 'English - SDH' ||
                          subtitles[i].language == 'English 1' ||
                          subtitles[i].language == 'English - English [CC]' ||
                          subtitles[i].language == 'en'
                      ? true
                      : false,
                  type: BetterPlayerSubtitlesSourceType.memory)
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
            await getVttFileAsString(subtitles
                    .where((element) =>
                        element.language!.startsWith(
                            supportedLanguages[foundIndex].englishName) ||
                        element.language! ==
                            supportedLanguages[foundIndex].languageCode)
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
                    content: processVttFileTimestamps(value),
                    selectedByDefault: true,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
        } else {
          if (appDep.useExternalSubtitles) {
            await fetchSocialLinks(
              Endpoints.getExternalLinksForTV(
                  widget.metadata.elementAt(7), "en"),
            ).then((value) async {
              if (value.imdbId != null) {
                await getExternalSubtitle(
                        Endpoints.searchExternalEpisodeSubtitles(
                            value.imdbId!,
                            widget.metadata.elementAt(3),
                            widget.metadata.elementAt(4),
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

  Future<void> loadViewasian() async {
    await fetchMovieTVForStreamDCVA(Endpoints.searchMovieTVForStreamViewasian(
            removeCharacters(widget.metadata.elementAt(1)).toLowerCase(),
            appDep.consumetUrl))
        .then((value) async {
      if (mounted) {
        setState(() {
          vaShows = value;
        });
      }

      if (vaShows == null || vaShows!.isEmpty) {
        return;
      }

      for (int i = 0; i < vaShows!.length; i++) {
        if (vaShows![i]
            .title!
            .toLowerCase()
            .contains(widget.metadata.elementAt(1).toString().toLowerCase())) {
          await getMovieTVStreamEpisodesDCVA(
                  Endpoints.getMovieTVStreamInfoViewasian(
                      vaShows![i].id!, appDep.consumetUrl))
              .then((value) async {
            setState(() {
              vaEpi = value;
            });
            if (vaShows != null && vaShows!.isNotEmpty) {
              await getMovieTVStreamLinksAndSubsDCVA(
                      Endpoints.getMovieTVStreamLinksViewasian(
                          vaEpi!
                              .where((element) =>
                                  element.episode ==
                                  widget.metadata.elementAt(3).toString())
                              .first
                              .id!,
                          vaShows![i].id!,
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
                  tvVideoLinks = viewasianVideoSources!.videoLinks;
                  tvVideoSubs = viewasianVideoSources!.videoSubtitles;
                  if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
                    convertVideoLinks(tvVideoLinks!);
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
