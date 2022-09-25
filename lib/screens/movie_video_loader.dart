// ignore_for_file: use_build_context_synchronously

import 'package:cinemax/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pod_player/pod_player.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';

import '../constants/api_constants.dart';
import 'player.dart';

class MovieVideoLoader extends StatefulWidget {
  const MovieVideoLoader({required this.imdbID, Key? key}) : super(key: key);
  final String imdbID;

  @override
  State<MovieVideoLoader> createState() => _MovieVideoLoaderState();
}

class _MovieVideoLoaderState extends State<MovieVideoLoader> {
  List<VideoQalityUrls>? videoUrls = [];
  late Uri completem3u8;
  final webScraper = WebScraper(TWOEMBED_BASE_URL);
  List<Map<String, dynamic>>? videoSrc;
  SpinKitChasingDots spinKitChasingDots = SpinKitChasingDots(
    color: Colors.white,
    size: 60,
  );

  @override
  void initState() {
    parseHls();
    super.initState();
  }

  Future<void> parseHls([HlsMasterPlaylist? masterPlaylist]) async {
    if (await webScraper.loadWebPage('/play/movie.php?imdb=${widget.imdbID}')) {
      setState(() {
        videoSrc = webScraper.getElement('#player > source', ['src', 'type']);
        print('https://2embed.biz/play/'
            '${videoSrc![0]['attributes']['src']}');
      });
    }
    HlsPlaylist playlist;
    var dio = Dio();
    completem3u8 = await dio
        .getUri(
          Uri.parse('https://2embed.biz/play/'
              '${videoSrc![0]['attributes']['src']}'),
        )
        .then((value) => value.redirects[0].location);
    final data = await http.get(completem3u8).then((res) => res.body);
    final bodyLength =
        await http.get(completem3u8).then((value) => value.bodyBytes.length);
    if (bodyLength <= 110) {
      videoUrls!.add(VideoQalityUrls(quality: 0, url: completem3u8.toString()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) {
        return PlayVideoFromNetworkQualityUrls(
          videoUrl: videoUrls!,
        );
      })));
    }
    playlist = await HlsPlaylistParser.create(masterPlaylist: masterPlaylist)
        .parseString(completem3u8, data);
    if (playlist is HlsMasterPlaylist) {
      // master m3u8 file
      playlist.variants
        ..sort((a, b) => b.format.bitrate! - a.format.bitrate!)
        ..forEach((v) {
          setState(() {
            videoUrls!.add(VideoQalityUrls(
                quality: v.format.height!, url: v.url.toString()));
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: ((context) {
              return PlayVideoFromNetworkQualityUrls(
                videoUrl: videoUrls!,
              );
            })));
          });
        });
      videoUrls!
          .insert(0, VideoQalityUrls(quality: 0, url: completem3u8.toString()));

      return parseHls(playlist);
    } else if (playlist is HlsMediaPlaylist) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              spinKitChasingDots,
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
