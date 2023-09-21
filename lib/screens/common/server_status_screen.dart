import 'package:cinemax/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/function.dart';
import '../../models/movie_stream.dart';

class ServerStatusScreen extends StatefulWidget {
  const ServerStatusScreen({Key? key}) : super(key: key);

  @override
  State<ServerStatusScreen> createState() => _ServerStatusScreenState();
}

class _ServerStatusScreenState extends State<ServerStatusScreen> {
  List<MovieVideoLinks>? movieVideoLinks;
  MovieVideoSources? movieVideoSources;
  bool checking = false;
  String resultMessage = "";
  String waitingMessage = "";

  void checkServer() async {
    setState(() {
      waitingMessage = tr("checking_server");
      resultMessage = "";
      movieVideoLinks = null;
      checking = true;
    });
    await getMovieStreamLinksAndSubs(
            "${appDependencyProvider.consumetUrl}movies/flixhq/watch?episodeId=97708&mediaId=movie/watch-no-hard-feelings-97708")
        .then((value) {
      if (mounted) {
        setState(() {
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
                    style: TextStyle(
                        color:
                            movieVideoLinks == null || movieVideoLinks!.isEmpty
                                ? Colors.red
                                : Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  Visibility(
                    visible: !checking,
                    child: ElevatedButton(
                        onPressed: () {
                          checkServer();
                        },
                        child: Text(tr("check"))),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
