// ignore_for_file: avoid_unnecessary_containers

import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';
import 'movie_stream.dart';

class MovieStreamSelect extends StatefulWidget {
  final String movieName;
  final int movieId;
  final dynamic movieImdbId;
  const MovieStreamSelect({
    Key? key,
    required this.movieName,
    required this.movieId,
    this.movieImdbId,
  }) : super(key: key);

  @override
  State<MovieStreamSelect> createState() => _MovieStreamSelectState();
}

class _MovieStreamSelectState extends State<MovieStreamSelect> {
  var startAppSdk4 = StartAppSdk();
  StartAppBannerAd? bannerAd4;

  @override
  void initState() {
    getBannerADForMovieStreamSelect();
    super.initState();
  }

  void getBannerADForMovieStreamSelect() {
    startAppSdk4
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAd4 = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch: ${widget.movieName}',
        ),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        color: isDark ? const Color(0xFF202124) : const Color(0xFFF7F7F7),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        StreamListWidget(
                          streamName: 'Stream one (multiple player options)',
                          streamLink:
                              'https://www.2embed.to/embed/tmdb/movie?id=${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        Visibility(
                          visible: widget.movieImdbId == null ? false : true,
                          child: StreamListWidget(
                            streamName: 'Stream two (multiple player options)',
                            streamLink:
                                'https://api.123movie.cc/imdb.php?imdb=${widget.movieImdbId}&server=vcu',
                            movieName: widget.movieName,
                          ),
                        ),
                        StreamListWidget(
                          streamName: 'Stream three (multiple player options)',
                          streamLink:
                              'https://moviehungershaven.xyz/tplayer/plr7.php?id=${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        StreamListWidget(
                          streamName: 'Stream four (360p)',
                          streamLink:
                              'https://databasegdriveplayer.co/player.php?tmdb=${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        StreamListWidget(
                          streamName: 'Stream five (multiple player options)',
                          streamLink:
                              'https://openvids.io/tmdb/movie/${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        StreamListWidget(
                          streamName: 'Stream six (multiple player options)',
                          streamLink:
                              'https://fsapi.xyz/tmdb-movie/${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        StreamListWidget(
                          streamName: 'Stream seven (multiple player options)',
                          streamLink:
                              'https://api.movieshunters.com/api/movie?id=${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        StreamListWidget(
                          streamName: 'Stream eight (multiple player options)',
                          streamLink:
                              'https://imdbembed.xyz/movie/tmdb/${widget.movieId}',
                          movieName: widget.movieName,
                        ),
                        Visibility(
                          visible: widget.movieImdbId == null ? false : true,
                          child: StreamListWidget(
                            streamName:
                                'Stream nine (360p/480p/720p/1080p - might have ads)',
                            streamLink:
                                'https://api.123movie.cc/imdb.php?imdb=${widget.movieImdbId}&server=hydrax',
                            movieName: widget.movieName,
                          ),
                        ),
                        bannerAd4 != null
                            ? StartAppBanner(
                                bannerAd4!,
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StreamListWidget extends StatelessWidget {
  final String streamName;
  final String streamLink;
  final String movieName;
  const StreamListWidget({
    Key? key,
    required this.streamName,
    required this.streamLink,
    required this.movieName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MovieStream(
            streamUrl: streamLink,
            movieName: movieName,
          );
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.play_circle_outline),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    child: Text(
                      streamName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: isDark ? Colors.white54 : Colors.black54,
          )
        ],
      ),
    );
  }
}
