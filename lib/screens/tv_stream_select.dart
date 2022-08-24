// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';
import '../provider/darktheme_provider.dart';
import 'tv_stream.dart';

class TVStreamSelect extends StatefulWidget {
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
  State<TVStreamSelect> createState() => _TVStreamSelectState();
}

class _TVStreamSelectState extends State<TVStreamSelect> {
  var startAppSdkTVStreamSelect = StartAppSdk();
  StartAppBannerAd? bannerAdTVStreamSelect;

  void getBannerADForTVStreamSelect() {
    startAppSdkTVStreamSelect
        .loadBannerAd(
      StartAppBannerType.BANNER,
    )
        .then((bannerAd) {
      setState(() {
        bannerAdTVStreamSelect = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    getBannerADForTVStreamSelect();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch: ${widget.tvSeriesName} ${widget.seasonNumber <= 9 ? 'S0${widget.seasonNumber}' : 'S${widget.seasonNumber}'} | '
          '${widget.episodeNumber <= 9 ? 'E0${widget.episodeNumber}' : 'E${widget.episodeNumber}'}'
          ', ${widget.episodeName}',
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
                          'https://www.2embed.to/embed/tmdb/tv?id=${widget.tvSeriesId}&s=${widget.seasonNumber}&e=${widget.episodeNumber}',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream two (multiple player options)',
                      streamLink:
                          'https://api.123movie.cc/tmdb_api.php?se=${widget.seasonNumber}&ep=${widget.episodeNumber}&tmdb=${widget.tvSeriesId}&server_name=vcu',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream three (360p)',
                      streamLink:
                          'https://database.gdriveplayer.us/player.php?type=series&tmdb=${widget.tvSeriesId}&season=${widget.seasonNumber}&episode=${widget.episodeNumber}',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream four (multiple player options)',
                      streamLink:
                          'https://openvids.io/tmdb/episode/${widget.tvSeriesId}-${widget.seasonNumber}-${widget.episodeNumber}',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream five (multiple player options)',
                      streamLink:
                          'https://fsapi.xyz/tv-tmdb/${widget.tvSeriesId}-${widget.seasonNumber}-${widget.episodeNumber}',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    StreamListWidget(
                      streamName: 'Stream six (multiple player options)',
                      streamLink:
                          'https://imdbembed.xyz/tv/tmdb/${widget.tvSeriesId}-${widget.seasonNumber}-${widget.episodeNumber}',
                      tvSeriesName: widget.tvSeriesName,
                    ),
                    bannerAdTVStreamSelect != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: StartAppBanner(
                                bannerAdTVStreamSelect!,
                              ),
                            ),
                          )
                        : Container(),
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
    final isDark = Provider.of<DarkthemeProvider>(context).darktheme;
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
          Divider(
            color: isDark ? Colors.white54 : Colors.black54,
          )
        ],
      ),
    );
  }
}
