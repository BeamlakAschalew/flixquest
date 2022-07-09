// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'tv_stream.dart';

class TVStreamSelect extends StatelessWidget {
  final String tvSeriesName;
  final int tvSeriesId;
  final String? tvSeriesImdbId;
  final int seasonNumber;
  final String episodeName;
  final int episodeNumber;
  const TVStreamSelect({
    Key? key,
    required this.tvSeriesName,
    required this.tvSeriesId,
    required this.episodeName,
    this.tvSeriesImdbId,
    required this.episodeNumber,
    required this.seasonNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch $tvSeriesName ${seasonNumber <= 9 ? 'S0$seasonNumber' : 'S$seasonNumber'} | '
          '${episodeNumber <= 9 ? 'E0$episodeNumber' : 'E$episodeNumber'}'
          ', $episodeName',
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
                          'https://2embed.org/embed/series?tmdb=$tvSeriesId&sea=$seasonNumber&epi=$episodeNumber',
                      tvSeriesName: tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream two (multiple player options)',
                      streamLink:
                          'https://api.123movie.cc/tmdb_api.php?se=$seasonNumber&ep=$episodeNumber&tmdb=$tvSeriesId&server_name=vcu',
                      tvSeriesName: tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream three (360p)',
                      streamLink:
                          'https://database.gdriveplayer.us/player.php?type=series&tmdb=$tvSeriesId&season=$seasonNumber&episode=$episodeNumber',
                      tvSeriesName: tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream four (multiple player options)',
                      streamLink:
                          'https://openvids.io/tmdb/episode/$tvSeriesId-$seasonNumber-$episodeNumber',
                      tvSeriesName: tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream five (multiple player options)',
                      streamLink:
                          'https://fsapi.xyz/tv-tmdb/$tvSeriesId-$seasonNumber-$episodeNumber',
                      tvSeriesName: tvSeriesName,
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
  final String tvSeriesName;
  const StreamListWidget({
    Key? key,
    required this.streamName,
    required this.streamLink,
    required this.tvSeriesName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TVStream(
            streamUrl: streamLink,
            tvSeriesName: tvSeriesName,
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
                      maxLines: 2,
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
