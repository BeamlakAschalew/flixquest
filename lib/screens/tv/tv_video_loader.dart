// ignore_for_file: use_build_context_synchronously
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/models/movie_stream.dart';
import 'package:video_viewer/video_viewer.dart';
import '../../models/tv_stream.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import '../../screens/common/player.dart';
import 'dart:convert';

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

  Future<String> getVttFileAsString(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final decoded = utf8.decode(bytes);
      return decoded;
    } else {
      throw Exception('Failed to load VTT file');
    }
  }

  void loadVideo() async {
    await fetchTVForStream(Endpoints.searchMovieTVForStream(widget.videoTitle))
        .then((value) {
      setState(() {
        tvShows = value;
      });
    });

    for (int i = 0; i < tvShows!.length; i++) {
      if (tvShows![i].seasons == widget.seasons &&
          tvShows![i].type == 'TV Series') {
        await getTVStreamEpisodes(
                Endpoints.getMovieTVStreamInfo(tvShows![i].id!))
            .then((value) {
          setState(() {
            epi = value;
          });
        });
        for (int i = 0; i < epi!.length; i++) {
          if (epi![i].episode == widget.episodeNumber &&
              epi![i].season == widget.seasonNumber) {
            await getTVStreamLinksAndSubs(Endpoints.getMovieTVStreamLinks(
                    epi![i].id!, tvShows![0].id!))
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

    Map<String, VideoSource> videos = {};
    Map<String, VideoViewerSubtitle> subs = {};

    for (int i = 0; i < tvVideoSubs!.length; i++) {
      getVttFileAsString(tvVideoSubs![i].url!).then((value) {
        subs.addAll({
          tvVideoSubs![i].language!: VideoViewerSubtitle.content(
              processVttFileTimestamps(value),
              type: SubtitleType.webvtt)
        });
      });
    }

    for (int k = 0; k < tvVideoLinks!.length; k++) {
      videos.addAll({
        tvVideoLinks![k].quality!: VideoSource(
          video: VideoPlayerController.network(tvVideoLinks![k].url!),
          subtitle: subs,
        ),
      });
    }

    List<MapEntry<String, VideoSource>> reversedVideoList =
        videos.entries.toList().reversed.toList();
    Map<String, VideoSource> reversedVids = Map.fromEntries(reversedVideoList);

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return Player(
          sources: reversedVids,
          subs: subs,
          thumbnail: widget.thumbnail,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    SpinKitChasingDots spinKitChasingDots = const SpinKitChasingDots(
      color: Colors.white,
      size: 60,
    );

    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spinKitChasingDots,
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Initializing player',
                  style: kTextSmallHeaderStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
