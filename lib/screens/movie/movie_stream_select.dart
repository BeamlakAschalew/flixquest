// ignore_for_file: avoid_unnecessary_containers
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('watch_movie', namedArgs: {'movie': widget.movieName})),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: [
                          StreamListWidget(
                            streamName: 'Stream one (multiple player options)',
                            streamLink:
                                'https://2embed.biz/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          Visibility(
                            visible: widget.movieImdbId == null ? false : true,
                            child: StreamListWidget(
                              streamName:
                                  'Stream two (multiple player options)',
                              streamLink:
                                  'https://api.123movie.cc/imdb.php?imdb=${widget.movieImdbId}&server=vcu',
                              movieName: widget.movieName,
                            ),
                          ),
                          StreamListWidget(
                            streamName:
                                'Stream three (multiple player options)',
                            streamLink:
                                'https://www.2embed.to/embed/tmdb/movie?id=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream four (multiple player options)',
                            streamLink:
                                'https://onionflix.org/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream five (multiple player options)',
                            streamLink:
                                'https://hub.smashystream.com/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream six (multiple player options)',
                            streamLink:
                                'https://embedworld.xyz/public/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'Stream seven (multiple player options)',
                            streamLink:
                                'https://cinedb.top/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'Stream eight (multiple player options)',
                            streamLink:
                                'https://fembed.ro/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream nine (multiple player options)',
                            streamLink:
                                'https://moviehab.com/embed/movie?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream ten (multiple player options)',
                            streamLink:
                                'https://vidsrc.me/embed/${widget.movieId}/',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName: 'Stream eleven (360p)',
                            streamLink:
                                'https://databasegdriveplayer.co/player.php?tmdb=${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                          StreamListWidget(
                            streamName:
                                'Stream twelve (multiple player options)',
                            streamLink:
                                'https://openvids.io/tmdb/movie/${widget.movieId}',
                            movieName: widget.movieName,
                          ),
                        ],
                      ),
                    ],
                  ),
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
    final themeMode = Provider.of<SettingsProvider>(context).appTheme;
    return GestureDetector(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return MovieStream(
        //     streamUrl: streamLink,
        //     movieName: movieName,
        //   );
        // }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.play_circle_outline_rounded),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    child: Text(
                      streamName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          const TextStyle(fontFamily: 'Figtree', fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: themeMode == 'dark' || themeMode == 'amoled'
                ? Colors.white54
                : Colors.black54,
          )
        ],
      ),
    );
  }
}
