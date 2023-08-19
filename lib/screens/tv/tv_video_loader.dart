// ignore_for_file: use_build_context_synchronously
import 'package:better_player/better_player.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/models/function.dart';
import 'package:provider/provider.dart';
import '../../models/tv_stream.dart';
import '../../provider/settings_provider.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../screens/common/player.dart';

class TVVideoLoader extends StatefulWidget {
  const TVVideoLoader(
      {required this.videoTitle,
      required this.thumbnail,
      required this.seasons,
      required this.episodeNumber,
      required this.seasonNumber,
      Key? key})
      : super(key: key);

  final String videoTitle;
  final int seasons;
  final String? thumbnail;
  final int episodeNumber;
  final int seasonNumber;

  @override
  State<TVVideoLoader> createState() => _TVVideoLoaderState();
}

class _TVVideoLoaderState extends State<TVVideoLoader> {
  List<TVResults>? tvShows;
  List<TVEpisodes>? epi;
  TVVideoSources? tvVideoSources;
  List<TVVideoLinks>? tvVideoLinks;
  List<TVVideoSubtitles>? tvVideoSubs;
  TVInfo? tvInfo;
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
      await fetchTVForStream(
              Endpoints.searchMovieTVForStream(widget.videoTitle))
          .then((value) {
        if (mounted) {
          setState(() {
            tvShows = value;
          });
        }
      });

      for (int i = 0; i < tvShows!.length; i++) {
        if (tvShows![i].seasons == widget.seasons &&
            tvShows![i].type == 'TV Series') {
          await getTVStreamEpisodes(
                  Endpoints.getMovieTVStreamInfo(tvShows![i].id!))
              .then((value) {
            setState(() {
              tvInfo = value;
              epi = tvInfo!.episodes;
            });
          });
          for (int k = 0; k < epi!.length; k++) {
            if (epi![k].episode == widget.episodeNumber &&
                epi![k].season == widget.seasonNumber) {
              await getTVStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks(
                      epi![k].id!, tvShows![i].id!))
                  .then((value) {
                setState(() {
                  tvVideoSources = value;
                });
                tvVideoLinks = tvVideoSources!.videoLinks;
                tvVideoSubs = tvVideoSources!.videoSubtitles;
              });
              break;
            }
          }

          break;
        }
      }

      Map<String, String> videos = {};
      List<BetterPlayerSubtitlesSource> subs = [];

      if (tvVideoSubs != null) {
        if (subLanguage == '') {
          for (int i = 0; i < tvVideoSubs!.length - 1; i++) {
            setState(() {
              loadProgress = (i / tvVideoSubs!.length) * 100;
            });
            await getVttFileAsString(tvVideoSubs![i].url!).then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: tvVideoSubs![i].language!,
                    content: processVttFileTimestamps(value),
                    selectedByDefault: tvVideoSubs![i].language == 'English' ||
                            tvVideoSubs![i].language == 'English - English' ||
                            tvVideoSubs![i].language == 'English - SDH' ||
                            tvVideoSubs![i].language == 'English 1'
                        ? true
                        : false,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
        } else {
          if (tvVideoSubs!
              .where((element) => element.language!.startsWith(subLanguage))
              .isNotEmpty) {
            await getVttFileAsString(tvVideoSubs!
                    .where(
                        (element) => element.language!.startsWith(subLanguage))
                    .first
                    .url!)
                .then((value) {
              subs.addAll({
                BetterPlayerSubtitlesSource(
                    name: tvVideoSubs!
                        .where((element) =>
                            element.language!.startsWith(subLanguage))
                        .first
                        .language,
                    content: processVttFileTimestamps(value),
                    selectedByDefault: true,
                    type: BetterPlayerSubtitlesSourceType.memory)
              });
            });
          }
        }
      }

      if (tvVideoLinks != null) {
        for (int k = 0; k < tvVideoLinks!.length; k++) {
          videos.addAll({tvVideoLinks![k].quality!: tvVideoLinks![k].url!});
        }
      }

      List<MapEntry<String, String>> reversedVideoList =
          videos.entries.toList().reversed.toList();
      Map<String, String> reversedVids = Map.fromEntries(reversedVideoList);

      if (tvVideoLinks != null && tvVideoSubs != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return PlayerOne(
              sources: reversedVids,
              subs: subs,
              thumbnail: widget.thumbnail,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.background
              ],
              videoProperties: [maxBuffer, seekDuration, videoQuality, autoFS],
            );
          },
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The TV episode couldn\'t be found on our servers :(',
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
            'The TV episode couldn\'t be found on our servers :( Error: ${e.toString()}',
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
