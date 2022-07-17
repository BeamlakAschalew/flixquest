// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';

import 'movie_stream.dart';

class MovieStreamSelect extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch $movieName',
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
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
                          'https://www.2embed.to/embed/tmdb/movie?id=$movieId',
                    ),
                    StreamListWidget(
                      streamName: 'Stream two (multiple player options)',
                      streamLink:
                          'https://api.123movie.cc/imdb.php?imdb=$movieImdbId&server=vcu',
                    ),
                    StreamListWidget(
                      streamName: 'Stream three (360p)',
                      streamLink:
                          'http://database.gdriveplayer.us/player.php?tmdb=$movieId',
                    ),
                    StreamListWidget(
                      streamName: 'Stream four (multiple player options)',
                      streamLink: 'https://fsapi.xyz/tmdb-movie/$movieId',
                    ),
                    StreamListWidget(
                      streamName:
                          'Stream five (360p/480p/720p/1080p - might have ads)',
                      streamLink:
                          'https://api.123movie.cc/imdb.php?imdb=$movieImdbId&server=hydrax',
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
  const StreamListWidget({
    Key? key,
    required this.streamName,
    required this.streamLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MovieStream(
            streamUrl: streamLink,
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
          const Divider(
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
