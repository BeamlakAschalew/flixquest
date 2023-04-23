// ignore_for_file: use_build_context_synchronously

import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/models/function.dart';
import 'package:cinemax/models/movie_stream.dart';
import 'package:video_viewer/video_viewer.dart';
import '/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import '../../screens/common/player.dart';
import 'dart:convert';

class MovieVideoLoader extends StatefulWidget {
  MovieVideoLoader(
      {required this.videoTitle,
      required this.thumbnail,
      required this.releaseYear,
      Key? key})
      : super(key: key);

  final String videoTitle;
  final int releaseYear;
  final String? thumbnail;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<MovieResults>? movies;
  List<MovieEpisodes>? epi;
  MovieVideoSources? movieVideoSources;
  List<MovieVideoLinks>? movieVideoLinks;
  List<MovieVideoSubtitles>? movieVideoSubs;

  @override
  void initState() {
    super.initState();
    load();
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

  void load() async {
    await fetchMoviesForStream(
            Endpoints.searchMovieTVForStream(widget.videoTitle))
        .then((value) {
      setState(() {
        movies = value;
      });
      print('moviessss ${movies!.length}');
    });
    for (int i = 0; i < movies!.length; i++) {
      if (movies![i].releaseDate == widget.releaseYear.toString()) {
        print('titleeeeeee: ${movies![i].title!}');
        await getMovieStreamEpisodes(
                Endpoints.getMovieTVStreamInfo(movies![i].id!))
            .then((value) {
          //   print(movies![i].id);
          setState(() {
            epi = value;
          });
          //  print('epiiiiiii ${epi!.length}');
        });
        await getMovieStreamLinksAndSubs(
                Endpoints.getMovieTVStreamLinks(epi![0].id!, movies![i].id!))
            .then((value) {
          setState(() {
            movieVideoSources = value;
            print('huwefhu ${movieVideoSources!.videoLinks}');
          });
          movieVideoLinks = movieVideoSources!.videoLinks;
          movieVideoSubs = movieVideoSources!.videoSubtitles;
        });

        //  print('linkkkkkkkkkk ${movieVideoLinks!.first.url}');
        break;
      }
      // break;
    }
    Map<String, VideoSource> videos = {};
    Map<String, VideoViewerSubtitle> subs = {};

    for (int i = 0; i < movieVideoSubs!.length; i++) {
      getVttFileAsString(movieVideoSubs![i].url!).then((value) {
        subs.addAll({
          movieVideoSubs![i].language!: VideoViewerSubtitle.content(
              processVttFileTimestamps(value),
              type: SubtitleType.webvtt)
        });
      });
    }

    for (int k = 0; k < movieVideoLinks!.length; k++) {
      videos.addAll({
        movieVideoLinks![k].quality!: VideoSource(
          video: VideoPlayerController.network(movieVideoLinks![k].url!),
          subtitle: subs,
        ),
      });
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return Player(
          sources: videos,
          subs: subs,
          thumbnail: widget.thumbnail,
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    SpinKitChasingDots spinKitChasingDots = SpinKitChasingDots(
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
