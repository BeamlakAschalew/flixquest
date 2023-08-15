// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/models/movie_stream.dart';
import 'package:cinemax/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../models/download_manager.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader(
      {required this.download, required this.metadata, Key? key})
      : super(key: key);

  final bool download;
  final List metadata;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<MovieResults>? movies;
  List<MovieEpisodes>? epi;
  MovieVideoSources? movieVideoSources;
  List<MovieVideoLinks>? movieVideoLinks;
  List<MovieVideoSubtitles>? movieVideoSubs;
  double loadProgress = 0.00;
  late int maxBuffer;
  late int seekDuration;
  late int videoQuality;
  late String subLanguage;
  late bool autoFS;

  @override
  void initState() {
    super.initState();
    loadVideo();
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
    setState(() {
      maxBuffer = Provider.of<SettingsProvider>(context, listen: false)
          .defaultMaxBufferDuration;
      seekDuration = Provider.of<SettingsProvider>(context, listen: false)
          .defaultSeekDuration;
      videoQuality = Provider.of<SettingsProvider>(context, listen: false)
          .defaultVideoResolution;
      subLanguage = Provider.of<SettingsProvider>(context, listen: false)
          .defaultSubtitleLanguage;
      autoFS =
          Provider.of<SettingsProvider>(context, listen: false).defaultViewMode;
    });
    try {
      await fetchMoviesForStream(
              Endpoints.searchMovieTVForStream(widget.metadata.elementAt(1)))
          .then((value) {
        if (mounted) {
          setState(() {
            movies = value;
          });
        }
      });

      for (int i = 0; i < movies!.length; i++) {
        if (movies![i].releaseDate == widget.metadata.elementAt(3).toString() &&
            movies![i].type == 'Movie') {
          await getMovieStreamEpisodes(
                  Endpoints.getMovieTVStreamInfo(movies![i].id!))
              .then((value) {
            setState(() {
              epi = value;
            });
          });
          await getMovieStreamLinksAndSubs(
                  Endpoints.getMovieTVStreamLinks(epi![0].id!, movies![i].id!))
              .then((value) {
            setState(() {
              movieVideoSources = value;
            });
            movieVideoLinks = movieVideoSources!.videoLinks;
            movieVideoSubs = movieVideoSources!.videoSubtitles;
          });

          break;
        }
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      if (movieVideoSubs != null) {
        if (subLanguage == '') {
          for (int i = 0; i < movieVideoSubs!.length - 1; i++) {
            setState(() {
              loadProgress = (i / movieVideoSubs!.length) * 100;
            });
            await getVttFileAsString(movieVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs![i].language!,
                    //  urls: [movieVideoSubs![i].url],
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
          }
        } else {
          if (movieVideoSubs!
              .where((element) => element.language!.startsWith(subLanguage))
              .isNotEmpty) {
            await getVttFileAsString((movieVideoSubs!.where(
                        (element) => element.language!.startsWith(subLanguage)))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: movieVideoSubs!
                        .where((element) =>
                            element.language!.startsWith(subLanguage))
                        .first
                        .language,
                    //  urls: [movieVideoSubs![i].url],
                    selectedByDefault: true,
                    content: processVttFileTimestamps(value),
                    type: BetterPlayerSubtitlesSourceType.memory),
              });
            });
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

      void streamSelectBottomSheet({
        required Map vids,
      }) {
        final downloadProvider =
            Provider.of<DownloadProvider>(context, listen: false);
        vids.removeWhere((key, value) => key == 'auto');
        showModalBottomSheet(
          context: context,
          builder: (builder) {
            final mixpanel = Provider.of<SettingsProvider>(context).mixpanel;
            return Container(
                padding: const EdgeInsets.all(8),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Download: "${widget.metadata.elementAt(1)}"',
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Choose resolution:',
                      style: kTextSmallHeaderStyle,
                    ),
                    Column(
                      children: [
                        for (var entry in vids.entries)
                          InkWell(
                            child: ListTile(
                              onTap: () {
                                Directory? appDir = Directory(
                                    "storage/emulated/0/Cinemax/Backdrops");

                                // String outputPath =
                                //     "${appDir!.path}/output1.mp4";
                                Download dwn = Download(
                                    input: entry.value,
                                    output:
                                        '${appDir.path}/${widget.metadata.elementAt(1)}_${entry.key}p_Downloaded_from_Cinemax.mp4',
                                    progress: 0.0);
                                downloadProvider.addDownload(dwn);
                                downloadProvider.startDownload(dwn);
                              },
                              title: Text(entry.key),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
                      ],
                    )
                  ],
                ));
          },
        );
      }

      if (movieVideoLinks != null && movieVideoSubs != null) {
        if (widget.download) {
          Navigator.pop(context);
          streamSelectBottomSheet(vids: reversedVids);
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return PlayerOne(
                sources: reversedVids,
                subs: subs,
                thumbnail: widget.metadata.elementAt(2),
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.background
                ],
                videoProperties: [
                  maxBuffer,
                  seekDuration,
                  videoQuality,
                  autoFS
                ],
                metadata: [
                  widget.metadata.elementAt(0),
                  widget.metadata.elementAt(1),
                  widget.metadata.elementAt(2),
                  widget.metadata.elementAt(3)
                ],
              );
            },
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The movie couldn\'t be found on our servers :(',
              maxLines: 3,
              style: kTextSmallBodyStyle,
            ),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The movie couldn\'t be found on our servers :( Error: ${e.toString()}',
            maxLines: 3,
            style: kTextSmallBodyStyle,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
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
              'assets/images/logo_shadow.png',
              height: 65,
              width: 65,
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(width: 160, child: LinearProgressIndicator()),
            Visibility(
              visible: subLanguage != '' ? false : true,
              child: Text(
                '${loadProgress.toStringAsFixed(0).toString()}%',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
