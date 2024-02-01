// ignore_for_file: use_build_context_synchronously
import 'package:flixquest/functions/function.dart';
import 'package:flixquest/models/tv_stream_metadata.dart';
import 'package:flixquest/video_providers/superstream.dart';
import '../../controllers/recently_watched_database_controller.dart';
import '../../provider/recently_watched_provider.dart';
import '../../services/globle_method.dart';
import '../../video_providers/common.dart';
import '../../video_providers/flixhq.dart';
import '../../video_providers/flixhq_flixquest.dart';
import '../../video_providers/names.dart';
import '../../video_providers/zoro.dart';
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

  final TVStreamMetadata metadata;
  final bool download;
  final StreamRoute route;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  RecentlyWatchedEpisodeController recentlyWatchedEpisodeController =
      RecentlyWatchedEpisodeController();

  List<FlixHQTVSearchEntry>? fqShows;
  List<FlixHQTVInfoEntries>? fqEpi;
  List<DCVASearchEntry>? dcShows;
  List<DCVAInfoEntries>? dcEpi;
  List<DCVASearchEntry>? vaShows;
  List<DCVAInfoEntries>? vaEpi;
  List<ZoroSearchEntry>? zoroShows;
  List<ZoroInfoEntries>? zoroEpi;

  FlixHQStreamSources? fqTVVideoSources;
  SuperstreamStreamSources? superstreamVideoSources;
  FlixHQFlixQuestSources? flixHQFlixQuestStreamSources;
  DCVAStreamSources? dramacoolVideoSources;
  DCVAStreamSources? viewasianVideoSources;
  ZoroStreamSources? zoroVideoSources;

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

  late int foundIndex;

  Map<String, String> videos = {};
  List<BetterPlayerSubtitlesSource> subs = [];

  late String currentProvider = "";

  @override
  void initState() {
    super.initState();
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());
    loadVideo();
  }

  void loadVideo() async {
    try {
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
      for (int i = 0; i < videoProviders.length; i++) {
        setState(() {
          currentProvider = videoProviders[i].fullName;
        });
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
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'viewasian') {
          await loadViewasian();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'zoro') {
          await loadZoro();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        } else if (videoProviders[i].codeName == 'flixhqS2') {
          await loadFlixHQFlixQuestApi();
          if (tvVideoSubs != null && tvVideoSubs!.isNotEmpty) {
            await subtitleParserFetcher(tvVideoSubs!);
            break;
          }
          if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
            break;
          }
        }
      }

      if ((tvVideoLinks == null || tvVideoLinks!.isEmpty) && mounted) {
        Navigator.pop(context);
        showModalBottomSheet(
            builder: (context) {
              return ReportErrorWidget(
                error: tr("tv_vid_404"),
                hideButton: true,
              );
            },
            context: context);
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

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

  Future<void> loadDramacool() async {
    try {
      if (mounted) {
        await fetchMovieTVForStreamDCVA(
                Endpoints.searchMovieTVForStreamDramacool(
                        removeCharacters(widget.metadata.seriesName!),
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
            if (removeCharacters(dcShows![i].title!).toLowerCase().contains(
                    removeCharacters(widget.metadata.seriesName!.toString())
                        .toLowerCase()) ||
                dcShows![i]
                    .title!
                    .contains(widget.metadata.seriesName!.toString())) {
              await getMovieTVStreamEpisodesDCVA(
                      Endpoints.getMovieTVStreamInfoDramacool(
                          dcShows![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  dcEpi = value;
                });
                if (dcEpi != null && dcEpi!.isNotEmpty) {
                  bool doesntExist = dcEpi!
                      .where((element) =>
                          element.episode ==
                          widget.metadata.episodeNumber!.toString())
                      .isEmpty;
                  if (doesntExist) {
                    return;
                  }
                  await getMovieTVStreamLinksAndSubsDCVA(
                          Endpoints.getMovieTVStreamLinksDramacool(
                              dcEpi!
                                  .where((element) =>
                                      element.episode ==
                                      widget.metadata.episodeNumber!.toString())
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(
          e, context, 'Dramacool');
    }
  }

  Future<void> loadSuperstream() async {
    try {
      if (mounted) {
        await getSuperstreamStreamingLinks(Endpoints.getSuperstreamStreamTV(
                appDep.flixquestAPIURL,
                widget.metadata.tvId!,
                widget.metadata.seasonNumber!,
                widget.metadata.episodeNumber!))
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(
          e, context, 'Superstream');
    }
  }

  Future<void> loadFlixHQNormalRoute() async {
    late int totalSeasons;
    try {
      if (mounted) {
        await fetchTVDetails(
                Endpoints.tvDetailsUrl(widget.metadata.tvId!, "en"))
            .then(
          (value) async {
            totalSeasons = value.numberOfSeasons!;
            await fetchTVForStreamFlixHQ(Endpoints.searchMovieTVForStreamFlixHQ(
                    removeCharacters(widget.metadata.seriesName!).toLowerCase(),
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
                    (removeCharacters(fqShows![i].title!)
                            .toLowerCase()
                            .contains(
                                removeCharacters(widget.metadata.seriesName!)
                                    .toString()
                                    .toLowerCase()) ||
                        fqShows![i].title!.contains(
                            widget.metadata.seriesName!.toString()))) {
                  await getTVStreamEpisodesFlixHQ(
                          Endpoints.getMovieTVStreamInfoFlixHQ(
                              fqShows![i].id!, appDep.consumetUrl))
                      .then((value) async {
                    setState(() {
                      tvInfo = value;
                      fqEpi = tvInfo!.episodes;
                    });
                    if (fqEpi != null && fqEpi!.isNotEmpty) {
                      for (int k = 0; k < fqEpi!.length; k++) {
                        if (fqEpi![k].episode ==
                                widget.metadata.episodeNumber! &&
                            fqEpi![k].season == widget.metadata.seasonNumber!) {
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
                              if (tvVideoLinks != null &&
                                  tvVideoLinks!.isNotEmpty) {
                                convertVideoLinks(tvVideoLinks!);
                              }
                            }
                          });
                          break;
                        }
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
                    if (fqEpi != null && fqEpi!.isNotEmpty) {
                      for (int k = 0; k < fqEpi!.length; k++) {
                        if (fqEpi![k].episode ==
                                widget.metadata.episodeNumber! &&
                            fqEpi![k].season == widget.metadata.seasonNumber!) {
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
                              if (tvVideoLinks != null &&
                                  tvVideoLinks!.isNotEmpty) {
                                convertVideoLinks(tvVideoLinks!);
                              }
                            }
                          });
                          break;
                        }
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, 'FlixHQ');
    }
  }

  Future<void> loadFlixHQTMDBRoute() async {
    try {
      if (mounted) {
        await getTVStreamEpisodesTMDB(Endpoints.getMovieTVStreamInfoTMDB(
                widget.metadata.tvId!.toString(), "tv", appDep.consumetUrl))
            .then((value) async {
          setState(() {
            tvInfoTMDB = value;
          });
          if (widget.metadata.seasonNumber! != 0) {
            if (tvInfoTMDB!.id != null &&
                tvInfoTMDB!.seasons != null &&
                tvInfoTMDB!.seasons![widget.metadata.seasonNumber! - 1]
                        .episodes![widget.metadata.episodeNumber! - 1].id !=
                    null) {
              await getTVStreamLinksAndSubsFlixHQ(
                      Endpoints.getMovieTVStreamLinksTMDB(
                          appDep.consumetUrl,
                          tvInfoTMDB!
                              .seasons![widget.metadata.seasonNumber! - 1]
                              .episodes![widget.metadata.episodeNumber! - 1]
                              .id!,
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, 'FlixHQ');
    }
  }

  Future<void> loadFlixHQFlixQuestApi() async {
    try {
      if (mounted) {
        await getFlixHQFlixQuestLinks(Endpoints.getTVLinksFlixHQFQ(
                appDep.flixquestAPIURL,
                widget.metadata.episodeNumber!,
                widget.metadata.seasonNumber!,
                widget.metadata.tvId!))
            .then((value) {
          if (mounted) {
            if (value.messageExists == null &&
                value.videoLinks != null &&
                value.videoLinks!.isNotEmpty) {
              setState(() {
                flixHQFlixQuestStreamSources = value;
              });
            } else if (value.messageExists != null ||
                value.videoLinks == null ||
                value.videoLinks!.isEmpty) {
              return;
            }
          }
          if (mounted) {
            tvVideoLinks = flixHQFlixQuestStreamSources!.videoLinks;
            tvVideoSubs = flixHQFlixQuestStreamSources!.videoSubtitles;
            if (tvVideoLinks != null && tvVideoLinks!.isNotEmpty) {
              convertVideoLinks(tvVideoLinks!);
            }
          }
        });
      }
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(
          e, context, 'FlixHQ_S2');
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

  Future<void> subtitleParserFetcher(
      List<RegularSubtitleLinks> subtitles) async {
    getAppLanguage();

    try {
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
                if (subtitles[i].language!.startsWith(
                        supportedLanguages[foundIndex].englishName) ||
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
              for (int i = 0; i < subtitles.length; i++) {
                if (subtitles[i].language!.startsWith(
                        supportedLanguages[foundIndex].englishName) ||
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
                  break;
                }
              }
            }
          } else {
            if (appDep.useExternalSubtitles) {
              await fetchSocialLinks(
                Endpoints.getExternalLinksForTV(widget.metadata.tvId!, "en"),
              ).then((value) async {
                if (value.imdbId != null) {
                  await getExternalSubtitle(
                          Endpoints.searchExternalEpisodeSubtitles(
                              value.imdbId!,
                              widget.metadata.episodeNumber!,
                              widget.metadata.seasonNumber!,
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerGeneral(e, context);
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
    try {
      if (mounted) {
        await fetchMovieTVForStreamDCVA(
                Endpoints.searchMovieTVForStreamViewasian(
                    removeCharacters(widget.metadata.seriesName!).toLowerCase(),
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
            if (removeCharacters(vaShows![i].title!).toLowerCase().contains(
                    removeCharacters(widget.metadata.seriesName!.toString())
                        .toLowerCase()) ||
                vaShows![i]
                    .title!
                    .contains(widget.metadata.seriesName!.toString())) {
              await getMovieTVStreamEpisodesDCVA(
                      Endpoints.getMovieTVStreamInfoViewasian(
                          vaShows![i].id!, appDep.consumetUrl))
                  .then((value) async {
                setState(() {
                  vaEpi = value;
                });
                if (vaEpi != null && vaEpi!.isNotEmpty) {
                  bool doesntExist = vaEpi!
                      .where((element) =>
                          element.episode ==
                          widget.metadata.episodeNumber!.toString())
                      .isEmpty;
                  if (doesntExist) {
                    return;
                  }
                  await getMovieTVStreamLinksAndSubsDCVA(
                          Endpoints.getMovieTVStreamLinksViewasian(
                              vaEpi!
                                  .where((element) =>
                                      element.episode ==
                                      widget.metadata.episodeNumber!.toString())
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(
          e, context, 'ViewAsian');
    }
  }

  Future<void> loadZoro() async {
    try {
      if (mounted) {
        await fetchMovieTVForStreamZoro(Endpoints.searchZoroMoviesTV(
          appDep.consumetUrl,
          removeCharacters(widget.metadata.seriesName!).toLowerCase(),
        )).then((value) async {
          if (mounted) {
            setState(() {
              zoroShows = value;
            });
          }

          if (zoroShows == null || zoroShows!.isEmpty) {
            return;
          }

          for (int i = 0; i < zoroShows!.length; i++) {
            if ((removeCharacters(zoroShows![i].title!).toLowerCase().contains(
                        widget.metadata.seriesName!.toString().toLowerCase()) ||
                    zoroShows![i]
                        .title!
                        .contains(widget.metadata.seriesName!.toString())) &&
                zoroShows![i].type == 'TV') {
              await getMovieTVStreamEpisodesZoro(Endpoints.getMovieTVInfoZoro(
                      appDep.consumetUrl, zoroShows![i].id!))
                  .then((value) async {
                setState(() {
                  zoroEpi = value;
                });
                if (zoroEpi != null && zoroEpi!.isNotEmpty) {
                  bool doesntExist = zoroEpi!
                      .where((element) =>
                          element.episode ==
                          widget.metadata.episodeNumber!.toString())
                      .isEmpty;
                  if (doesntExist) {
                    return;
                  }
                  await getMovieTVStreamLinksAndSubsZoro(
                          Endpoints.getMovieTVStreamLinksZoro(
                              appDep.consumetUrl,
                              zoroEpi!
                                  .where((element) =>
                                      element.episode ==
                                      widget.metadata.episodeNumber!.toString())
                                  .first
                                  .id!,
                              appDep.streamingServerZoro))
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
                      tvVideoLinks = zoroVideoSources!.videoLinks;
                      tvVideoSubs = zoroVideoSources!.videoSubtitles;
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
    } on Exception catch (e) {
      GlobalMethods.showErrorScaffoldMessengerMediaLoad(e, context, 'Zoro');
    }
  }
}
