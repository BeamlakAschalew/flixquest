// ignore_for_file: avoid_unnecessary_containers
import 'package:cinemax/provider/darktheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';
import 'movie_stream.dart';

class MovieStreamSelect extends StatefulWidget {
  final String movieName;
  final int movieId;
  final String? movieImdbId;
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
  var startAppSdk = StartAppSdk();
  StartAppInterstitialAd? interstitialAd;

  @override
  void initState() {
    getInterstitialAdAfterStreaming();
    super.initState();
  }

  void getInterstitialAdAfterStreaming() {
    startAppSdk.loadInterstitialAd().then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return WillPopScope(
      onWillPop: () async {
        print('backbutton pressed');
        if (interstitialAd != null) {
          interstitialAd!.show().then((shown) {
            if (shown) {
              setState(() {
                interstitialAd = null;

                getInterstitialAdAfterStreaming();
              });
            }

            return null;
          }).onError((error, stackTrace) {
            debugPrint("Error showing Interstitial ad: $error");
          });
        }
        return true;
      },
      child: Scaffold(
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
              if (interstitialAd != null) {
                interstitialAd!.show().then((shown) {
                  if (shown) {
                    setState(() {
                      interstitialAd = null;
                      getInterstitialAdAfterStreaming();
                    });
                  }

                  return null;
                }).onError((error, stackTrace) {
                  debugPrint("Error showing Interstitial ad: $error");
                });
              }
            },
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                    ],
                  ),
                ),
              )
            ],
          ),
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
