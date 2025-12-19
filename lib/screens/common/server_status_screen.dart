// ignore_for_file: use_build_context_synchronously

import 'package:flixquest/video_providers/common.dart';
import 'package:provider/provider.dart';
import '../../functions/function.dart';
import '../../provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../functions/network.dart';
import '../../provider/settings_provider.dart';
import '../../video_providers/names.dart';
import '../../services/globle_method.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({super.key});

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  List<RegularVideoLinks>? videoLinks;
  List<VideoStatusCheck> videoProvidersCheck = [];
  String ping = '';
  DateTime? start;
  DateTime? end;
  bool checking = false;

  List<VideoProvider> videoProviders = [];
  List<String> messageStrings = [];

  late SettingsProvider prefString =
      Provider.of<SettingsProvider>(context, listen: false);

  late AppDependencyProvider appDependency =
      Provider.of<AppDependencyProvider>(context, listen: false);

  Future<void> _checkSingleServer(int index) async {
    final provider = videoProviders[index];
    List<RegularVideoLinks>? videoLinks;
    DateTime start = DateTime.now();

    try {
      if (provider.codeName == 'flixhq') {
        final result = await getMovieStreamLinksAndSubsFlixHQ(
            '${appDependency.consumetUrl}movies/flixhq/watch?episodeId=97708&mediaId=movie/watch-no-hard-feelings-97708&server=${appDependency.streamingServerFlixHQ}');
        videoLinks = result.videoLinks;
      } else if (provider.codeName == 'myflixerz') {
        final result = await getMovieStreamLinksAndSubsFlixHQNew(
            '${appDependency.newFlixHQUrl}movie/884605');
        videoLinks = result.videoLinks;
      } else if (provider.codeName == 'pstream') {
        print('${appDependency.flixApiUrl}pstream/stream-movie?tmdbId=884605');
        final result = await getMovieTVStreamLinksAndSubsFlixAPI(
            '${appDependency.flixApiUrl}pstream/stream-movie?tmdbId=884605');
        print(result.success);
        videoLinks = [
          RegularVideoLinks(
              url: result.stream!.playlist,
              isM3U8: result.stream!.playlist!.endsWith('.m3u8'))
        ];
        print(videoLinks);
      } else if (provider.codeName == 'goku') {
        final result = await getMovieStreamLinksAndSubsGoku(
            '${appDependency.consumetUrl}movies/goku/watch?episodeId=1353085&mediaId=watch-movie/watch-no-hard-feelings-97708&server=${appDependency.gokuServer}');
        videoLinks = result.videoLinks;
      } else if (provider.codeName == 'sflix') {
        final result = await getMovieStreamLinksAndSubsSflix(
            '${appDependency.consumetUrl}movies/sflix/watch?episodeId=97708&mediaId=movie/free-no-hard-feelings-hd-97708&server=${appDependency.sflixServer}');
        videoLinks = result.videoLinks;
      } else if (provider.codeName == 'himovies') {
        final result = await getMovieStreamLinksAndSubsHimovies(
            '${appDependency.consumetUrl}movies/himovies/watch?episodeId=97708&mediaId=movie/watch-no-hard-feelings-97708&server=${appDependency.himoviesServer}');
        videoLinks = result.videoLinks;
      }
    } catch (e) {
      // Error handling - server is down
      if (mounted) {
        GlobalMethods.showErrorScaffoldMessengerMediaLoad(
            e as Exception, context, provider.fullName);
      }
    }

    DateTime end = DateTime.now();
    String ping = end.difference(start).inMilliseconds.toString();

    if (mounted) {
      setState(() {
        videoProvidersCheck[index].ping = ping;
        videoProvidersCheck[index].isWaiting = false;

        if (videoLinks == null || videoLinks.isEmpty) {
          videoProvidersCheck[index].isWorking = false;
          videoProvidersCheck[index].resultMessage =
              "${provider.fullName} ${tr("server_down")}";
        } else {
          videoProvidersCheck[index].isWorking = true;
          videoProvidersCheck[index].resultMessage =
              '${provider.fullName} ${tr("server_working")}';
        }
      });
    }
  }

  void checkServer() async {
    setState(() {
      checking = true;
      videoProvidersCheck = [];
    });

    // Initialize all providers
    for (int i = 0; i < videoProviders.length; i++) {
      videoProvidersCheck.add(VideoStatusCheck(
          codeName: videoProviders[i].codeName,
          fullName: videoProviders[i].fullName,
          end: null,
          isWaiting: true,
          isWorking: false,
          ping: '',
          resultMessage: '',
          start: null,
          waitingMessage:
              '${tr("checking_server")} ${videoProviders[i].fullName}'));
    }

    // Check all servers simultaneously
    await Future.wait(
      List.generate(
        videoProviders.length,
        (index) => _checkSingleServer(index),
      ),
    );

    setState(() {
      checking = false;
    });
  }

  @override
  void initState() {
    videoProviders.addAll(
        parseProviderPrecedenceString(prefString.proPreference)
            .where((provider) => provider != null)
            .cast<VideoProvider>());

    checkServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr('check_server')),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (checking)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              tr('checking_server'),
                              style: const TextStyle(
                                fontFamily: 'FigtreeSB',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: videoProviders.length,
                      itemBuilder: ((context, index) {
                        final status = videoProvidersCheck[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            elevation: 3,
                            color: status.isWaiting!
                                ? Colors.yellow.withOpacity(0.15)
                                : status.isWorking!
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: status.isWaiting!
                                    ? Colors.yellow.withOpacity(0.3)
                                    : status.isWorking!
                                        ? Colors.green.withOpacity(0.5)
                                        : Colors.red.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: status.isWaiting!
                                              ? Colors.grey.withOpacity(0.2)
                                              : status.isWorking!
                                                  ? Colors.green
                                                      .withOpacity(0.2)
                                                  : Colors.red.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: status.isWaiting!
                                            ? const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Icon(
                                                status.isWorking!
                                                    ? Icons.check_circle
                                                    : Icons.error,
                                                color: status.isWorking!
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              videoProviders[index].fullName,
                                              style: const TextStyle(
                                                fontFamily: 'FigtreeSB',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (status.isWaiting!)
                                              Text(
                                                status.waitingMessage!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[400],
                                                ),
                                              )
                                            else
                                              Text(
                                                status.resultMessage!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: status.isWorking!
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (!status.isWaiting!)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getLatencyColor(
                                                    int.tryParse(
                                                            status.ping!) ??
                                                        0)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.speed,
                                                size: 16,
                                                color: _getLatencyColor(
                                                    int.tryParse(
                                                            status.ping!) ??
                                                        0),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${status.ping}ms',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getLatencyColor(
                                                      int.tryParse(
                                                              status.ping!) ??
                                                          0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
                  const SizedBox(height: 20),
                  if (!checking)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          checkServer();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          tr('check'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  Color _getLatencyColor(int latency) {
    if (latency < 3000) {
      return Colors.green;
    } else if (latency < 4000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class VideoStatusCheck {
  String? waitingMessage;
  String? codeName;
  String? fullName;
  bool? isWorking;
  DateTime? start;
  DateTime? end;
  String? ping;
  String? resultMessage;
  bool? isWaiting;

  VideoStatusCheck(
      {required this.codeName,
      required this.fullName,
      required this.end,
      required this.isWaiting,
      required this.isWorking,
      required this.ping,
      required this.resultMessage,
      required this.start,
      required this.waitingMessage});
}
