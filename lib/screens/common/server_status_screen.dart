import 'package:provider/provider.dart';
import '../../provider/app_dependency_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../functions/network.dart';
import '../../video_providers/flixhq.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({Key? key}) : super(key: key);

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  List<FlixHQVideoLinks>? movieVideoLinks;
  FlixHQStreamSources? movieVideoSources;
  bool checking = false;
  String resultMessage = "";
  String waitingMessage = "";
  String ping = "";
  DateTime? start;
  DateTime? end;

  late AppDependencyProvider appDependency =
      Provider.of<AppDependencyProvider>(context, listen: false);

  void checkServer() async {
    setState(() {
      waitingMessage = tr("checking_server");
      resultMessage = "";
      ping = "";
      movieVideoLinks = null;
      checking = true;
    });
    setState(() {
      start = DateTime.now();
    });
    await getMovieStreamLinksAndSubs(
            "${appDependency.consumetUrl}movies/flixhq/watch?episodeId=97708&mediaId=movie/watch-no-hard-feelings-97708&server=${appDependency.streamingServer}")
        .then((value) {
      if (mounted) {
        setState(() {
          end = DateTime.now();
          ping = end!.difference(start!).inMilliseconds.toString();
          movieVideoSources = value;
          waitingMessage = tr("server_check_complete");
          checking = false;
        });
      }
      movieVideoLinks = movieVideoSources!.videoLinks;

      if (mounted) {
        if (movieVideoLinks == null || movieVideoLinks!.isEmpty) {
          setState(() {
            resultMessage = "${tr("server_down")} ${tr("admin_notified")}";
          });
        } else {
          setState(() {
            resultMessage = tr("server_working");
          });
        }
      }
    });
  }

  @override
  void initState() {
    checkServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tr("check_server")),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    waitingMessage,
                    style: kTextHeaderStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    resultMessage,
                    style: kTextHeaderStyle.copyWith(
                        color:
                            movieVideoLinks == null || movieVideoLinks!.isEmpty
                                ? Colors.red
                                : Colors.green,
                        fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  Visibility(
                    visible: !checking,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          tr("latency", namedArgs: {"l": ping}),
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              checkServer();
                            },
                            child: Text(tr("check"))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
